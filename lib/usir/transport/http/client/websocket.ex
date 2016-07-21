defmodule Usir.Transport.HTTP.Client.Websocket do
  alias Usir.Protocol.Stateful, as: Protocol
  alias :websocket_client, as: WS
  alias :websocket_req, as: Request

  def start_link(url, acceptor, protocol_opts, websocket_options) do
    headers = format_headers(acceptor)
    {extra_headers, ws_opts} = Keyword.split(websocket_options, [:extra_headers])
    ws_opts = [{:extra_headers, headers ++ (extra_headers || [])} | ws_opts]
    WS.start_link(url, __MODULE__, {acceptor, protocol_opts}, ws_opts)
  end

  def init(state) do
    send(self, {__MODULE__, :init})
    {:ok, state}
  end
  def init({acceptor, protocol_opts}, req) do
    info = request_info(req)

    # Well... we can't get the accepted format here...
    # Probably gonna have to open a PR
    server_format = Map.keys(acceptor.formats)

    {_, conn} = Usir.Acceptor.init(acceptor, server_format, info)

    state = Protocol.init(conn, protocol_opts)

    {:ok, state}
  end

  def websocket_handle({type, msg}, _, state) when type in [:text, :binary] do
    state
    |> Protocol.handle_packet(msg)
    |> reply()
  end
  def websocket_handle(_other, _, state) do
    {:ok, state}
  end

  def websocket_info({__MODULE__, :init}, req, state) do
    init(state, req)
  end
  def websocket_info(info, _, state) do
    state
    |> Protocol.handle_info(info)
    |> reply()
  end

  def websocket_terminate(reason, _, state) do
    state
    |> Protocol.terminate(reason)
    :ok
  end

  defp reply({:reply, message, state}) do
    {:reply, message, state}
  end
  defp reply({:ok, state}) do
    {:ok, state}
  end

  defp request_info(req) do
    socket = Request.socket(req)
    {:ok, peer = {remote_ip, _}} = :inet.peername(socket)

    %Usir.Protocol{
      host: to_string(Request.host(req)),
      owner: self(),
      path: Request.path(req),
      peer: peer,
      port: Request.port(req),
      protocol: Protocol,
      remote_ip: remote_ip,
      scheme: Request.protocol(req),
    }
  end

  defp format_headers(%{formats: formats}) do
    for format <- formats do
      {"sec-websocket-protocol", "usir|" <> format}
    end
  end
end
