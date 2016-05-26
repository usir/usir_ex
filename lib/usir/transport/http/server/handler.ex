defmodule Usir.Transport.HTTP.Server.Handler do
  alias :cowboy_req, as: Request
  alias Usir.Transport.HTTP.Server.Websocket

  def init(%{headers: %{"upgrade" => _}} = req, opts) do
    Websocket.init(req, opts)
  end
  ## TODO handle normal http connections

  defdelegate websocket_handle(msg, req, state), to: Websocket
  defdelegate websocket_info(msg, req, state), to: Websocket
end
