defmodule Usir.Transport.HTTP.Client do
  def ws(url, acceptor, protocol_opts, websocket_options \\ []) do
    __MODULE__.Websocket.start_link(url, acceptor, protocol_opts, websocket_options)
  end
end
