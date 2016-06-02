defmodule Usir.Server do
  defstruct locales: [],
            auth: %{},
            pointers: %{}

  def new(opts \\ %{}) do
    %__MODULE__{
      locales: opts[:locales] || [],
      auth: opts[:auth] || %{}
    }
  end
end

defimpl Usir.Conn, for: Usir.Server do
  alias Usir.Message
  alias Usir.Queue

  def handle_info(conn, _handler, message) do
    case handle_info_process(conn, message) do
      nil ->
        {:error, :bad_message, conn}
      conn ->
        {message, conn}
    end
  end

  def handle_message(conn, handler, message, queue) do
    case message do
      %Message.Client.Resolve{path: path} ->
        resolve(conn, handler, path, queue)
      %Message.Client.Authenticate{method: method, token: token} ->
        {conn, Queue.push(queue, {handler, :authenticate, [method, token]})}
      %Message.Client.Message{path: path, affordance: affordance, body: body} ->
        {conn, Queue.push(queue, {handler, :message, [path, affordance, body]})}
      %Message.Client.ChangeLocales{locales: locales} ->
        change_locales(%{conn | locales: locales}, queue)
    end
  end

  defp handle_info_process(conn = %{pointers: pointers}, %Message.Server.Resolved{path: path,
                                                                                 state: state,
                                                                                 etag: etag,
                                                                                 _locale: locale,
                                                                                 _provided_locales: provided_locales}) do
    %{conn | pointers: Map.put(pointers, path, {state, etag, locale, provided_locales})}
  end
  defp handle_info_process(conn = %{pointers: pointers}, %Message.Server.Unresolved{path: path}) do
    %{conn | pointers: Map.delete(pointers, path)}
  end
  defp handle_info_process(conn = %{pointers: pointers}, %Message.Server.AuthenticationRequired{path: path}) do
    %{conn | pointers: Map.delete(pointers, path)}
  end
  defp handle_info_process(conn, %Message.Server.AuthenticationInvalid{}) do
    conn
  end
  defp handle_info_process(conn = %{pointers: pointers}, %Message.Server.Unauthorized{path: path}) do
    %{conn | pointers: Map.delete(pointers, path)}
  end
  defp handle_info_process(conn, %Message.Server.MessageInvalid{}) do
    conn
  end
  defp handle_info_process(conn, %Message.Server.Error{}) do
    conn
  end
  defp handle_info_process(_, _) do
    nil
  end

  defp resolve(conn, handler, components, queue) do
    queue = Enum.reduce(components, {[], queue}, fn(component, acc) ->
      resolve_component(component, acc, conn, handler)
    end)
    |> elem(1)

    {conn, queue}
  end

  defp resolve_component(component, acc, conn, handler) when is_binary(component) do
    resolve_component({component, nil, nil}, acc, conn, handler)
  end
  defp resolve_component({component, state, etag}, {prev, queue}, conn, handler) do
    %{auth: auth, locales: locales} = conn
    path = prev ++ [component]
    queue = Queue.push(queue, {handler, :resolve, [path, state, etag, auth, locales]})
    {path, queue}
  end

  defp change_locales(%{handler: handler, locales: locales, auth: auth, pointers: pointers} = conn, queue) do
    queue = Enum.reduce(pointers, queue, fn({path, {state, etag, _locale, _provided_locales}}, queue) ->
      ## TOOD make this more effecient by comparing the previous locale and provided_locales
      Queue.push(queue, {handler, :resolve, [path, state, etag, auth, locales]})
    end)

    {conn, queue}
  end
end
