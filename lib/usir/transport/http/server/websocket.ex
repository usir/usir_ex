defmodule Usir.Transport.HTTP.Server.Websocket do
  alias Usir.Protocol.Stateful, as: Protocol
  alias :cowboy_req, as: Request
  require Logger

  def init(req, {acceptor, protocol_opts}) do
    accepts = Request.parse_header("sec-websocket-protocol", req) |> format_protocols([])

    info = request_info(req)
    {format, conn} = Usir.Acceptor.init(acceptor, accepts, info)
    state = Protocol.init(conn, protocol_opts)

    req = set_websocket_protocol(req, "usir|#{format}")

    {:cowboy_websocket, req, state, protocol_opts[:conn_timeout] || 60_000}
  rescue
    error in Usir.Acceptor.Error.Unacceptable ->
      # TODO is this the best way to tell the client?
      supported = Map.keys(error.provides) |> Enum.map(&"usir|#{&1}") |> Enum.join(", ")
      req = set_websocket_protocol(req, supported)
      req = Request.reply(400, req)
      {:ok, req, nil}
  end

  def websocket_handle({type, msg}, req, state) when type in [:text, :binary] do
    state
    |> Protocol.handle_packet(msg)
    |> reply(req)
  end
  def websocket_handle(_other, req, state) do
    {:ok, req, state}
  end

  def websocket_info(msg, req, state) do
    state
    |> Protocol.handle_info(msg)
    |> reply(req)
  end

  def terminate(_, _, nil) do
    :ok
  end
  def terminate(reason, _req, state) do
    state
    |> Protocol.terminate(reason)
    :ok
  end

  defp reply({:reply, message, state}, req) do
    {:reply, message, req, state}
  end
  defp reply({:ok, state}, req) do
    {:ok, req, state}
  end

  defp request_info(req) do
    peer = {remote_ip, _} = Request.peer(req)
    %Usir.Protocol{
      headers: Request.headers(req),
      host: Request.host(req),
      owner: self(),
      path: Request.path(req),
      params: Request.parse_qs(req) |> :maps.from_list(),
      peer: peer,
      port: Request.port(req),
      protocol: Protocol,
      remote_ip: remote_ip,
      scheme: Request.scheme(req) |> format_scheme()
    }
  end

  defp format_scheme("https"), do: :wss
  defp format_scheme(_), do: :ws

  defp set_websocket_protocol(req, protocol) do
    Request.set_resp_header("sec-websocket-protocol", protocol, req)
  end

  defp format_protocols([], acc) do
    :lists.reverse(acc)
  end
  defp format_protocols(["usir|" <> format | rest], acc) do
    format_protocols(rest, [format | acc])
  end
  defp format_protocols([_ | rest], acc) do
    format_protocols(rest, acc)
  end
  defp format_protocols(_, _) do
    []
  end
end
