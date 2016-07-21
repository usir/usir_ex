defmodule Usir.Transport.HTTP.Server.Router do
  alias Usir.Transport.HTTP.Server.{Handler,Websocket}

  def init(%{headers: %{"upgrade" => _}} = req, opts) do
    Websocket.init(req, opts)
  end
  def init(req, opts) do
    Handler.init(req, opts)
  end

  defdelegate websocket_handle(msg, req, state), to: Websocket
  defdelegate websocket_info(msg, req, state), to: Websocket
  defdelegate terminate(reason, req, state), to: Websocket
end
