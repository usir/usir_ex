defmodule Usir.Transport.HTTP.Client do
  alias __MODULE__.Websocket

  def ws(url, acceptor, protocol_opts, websocket_options \\ []) do
    Websocket.start_link(url, acceptor, protocol_opts, websocket_options)
  end

  def close(pid) do
    Websocket.close(pid)
  end
end
