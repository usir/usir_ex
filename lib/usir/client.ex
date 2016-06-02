defmodule Usir.Client do
  defstruct cache: %{}

  def new(opts \\ %{}) do
    %__MODULE__{
      cache: opts[:cache] || %{}
    }
  end
end

defimpl Usir.Conn, for: Usir.Client do
  alias Usir.Client.Cache
  alias Usir.Message

  def handle_info(conn, _handler, message) do
    {message, conn}
  end

  def handle_message(client = %{cache: cache}, _handler, message, _queue) do
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
end
