defmodule Usir.Server.Conn do
  defstruct handler: nil,
            format: nil,
            locales: [],
            auth: %{},
            pointers: %{}

  alias Usir.Format
  alias Usir.Message
  alias Usir.Server.Queue

  def handle_packet(conn = %{format: format}, packet, queue) do
    format
    |> Format.decode(packet)
    |> Enum.reduce({conn, queue}, &handle_message(&1, &2))
  end

  defp handle_message(message, {conn, queue}) do
    case message do
      %Message.Client.Resolve{path: path} ->
        resolve(conn, path, queue)
      %Message.Client.Authenticate{method: method, token: token} ->
        {conn, Queue.push(queue, {conn.handler, :authenticate, [method, token]})}
      %Message.Client.Message{path: path, affordance: affordance, body: body} ->
        {conn, Queue.push(queue, {conn.handler, :message, [path, affordance, body]})}
      %Message.Client.ChangeLocales{locales: locales} ->
        change_locales(%{conn | locales: locales}, queue)
    end
  end

  def handle_info(conn, message) do
    case handle_info_process(conn, message) do
      nil ->
        :error
      conn ->
        {message, conn}
    end
  end

  def encode_packet(%{format: format}, messages) do
    Format.encode(format, messages)
  end

  def handle_info_process(conn = %{pointers: pointers}, %Message.Server.Resolved{path: path,
                                                                                 state: state,
                                                                                 etag: etag,
                                                                                 _locale: locale,
                                                                                 _provided_locales: provided_locales}) do
    %{conn | pointers: Map.put(pointers, path, {state, etag, locale, provided_locales})}
  end
  def handle_info_process(conn = %{pointers: pointers}, %Message.Server.Unresolved{path: path}) do
    %{conn | pointers: Map.delete(pointers, path)}
  end
  def handle_info_process(conn = %{pointers: pointers}, %Message.Server.AuthenticationRequired{path: path}) do
    %{conn | pointers: Map.delete(pointers, path)}
  end
  def handle_info_process(conn, %Message.Server.AuthenticationInvalid{}) do
    conn
  end
  def handle_info_process(conn = %{pointers: pointers}, %Message.Server.Unauthorized{path: path}) do
    %{conn | pointers: Map.delete(pointers, path)}
  end
  def handle_info_process(conn, %Message.Server.MessageInvalid{}) do
    conn
  end
  def handle_info_process(conn, %Message.Server.Error{}) do
    conn
  end
  def handle_info_process(_, _) do
    nil
  end

  defp resolve(%{handler: handler, locales: locales, auth: auth} = conn, components, queue) do
    queue = Enum.reduce(components, {[], queue}, fn({component, state, etag}, {prev, queue}) ->
      path = prev ++ [component]
      queue = Queue.push(queue, {handler, :resolve, [path, state, etag, auth, locales]})
      {path, queue}
    end)
    |> elem(1)

    {conn, queue}
  end

  defp change_locales(%{handler: handler, locales: locales, auth: auth, pointers: pointers} = conn, queue) do
    queue = Enum.reduce(pointers, queue, fn({path, {state, etag, _locale, _provided_locales}}, queue) ->
      ## TOOD make this more effecient by comparing the previous locale and provided_locales
      Queue.push(queue, {handler, :resolve, [path, state, etag, auth, locales]})
    end)

    {conn, queue}
  end
end
