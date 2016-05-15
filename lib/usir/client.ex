defmodule Usir.Client do
  defstruct format: nil,
            cache: nil

  alias Usir.Client.Cache
  alias Usir.Message
  alias Usir.Format

  def new(format, opts \\ %{}) do
    %__MODULE__{format: format,
                cache: opts[:cache] || %{}}
  end

  def resolve(%{cache: cache}, path) do
    message = %Message.Client.Resolve{path: join_path(path, cache)}
    {Cache.get(cache, path), message}
  end

  def authenticate(_, method, token) do
    %Message.Client.Authenticate{method: method, token: token}
  end

  def message(%{cache: cache}, path, affordance, body) do
    %Message.Client.Message{path: join_path(path, cache),
                            affordance: affordance,
                            body: body}
  end

  def encode_packet(%{format: format}, messages) do
    Format.encode(format, messages)
  end

  def handle_packet(client = %{format: format}, packet) do
    format
    |> Format.decode(packet)
    |> Enum.map(&handle_message(client, &1))
  end

  defp handle_message(client = %{cache: cache}, message) do
    case message do
      %Message.Server.Resolved{path: path, state: state, etag: etag, body: body} = m ->
        {m, %{client | cache: Cache.put(cache, path, {state, etag}, body)}}
      %Message.Server.Unresolved{path: path} = m ->
        {m, %{client | cache: Cache.delete(cache, path)}}
      %Message.Server.AuthenticationRequired{path: path} = m ->
        {m, %{client | cache: Cache.delete(cache, path)}}
      %Message.Server.AuthenticationInvalid{} = m ->
        {m, client}
      %Message.Server.Unauthorized{path: path} = m ->
        {m, %{client | cache: Cache.delete(cache, path)}}
      %Message.Server.MessageInvalid{} = m ->
        {m, client}
      %Message.Server.Error{} = m ->
        {m, client}
    end
  end

  defp join_path(components, cache) do
    Enum.reduce(components, {[], []}, fn(component, {prev, acc}) when is_binary(component) ->
      path = prev ++ [component]
      case Cache.get_info(cache, path) do
        {state, etag} ->
          {path, [{component, state, etag} | acc]}
        nil ->
          {path, [{component, nil, nil} | acc]}
      end
    end)
    |> elem(1)
    |> :lists.reverse()
  end
end
