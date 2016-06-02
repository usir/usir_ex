defmodule Usir.Transport.HTTP.Server.Websocket do
  alias Usir.Protocol.Stateful.Server, as: Protocol

  def init(req, {acceptor, protocol_opts}) do
    accepts = :cowboy_req.parse_header("sec-websocket-protocol", req) |> format_protocols([]) || []

    qs = :cowboy_req.parse_qs(req) |> :maps.from_list()
    locales = parse_csl(qs["locales"])

    # TODO handle different auth methods from the connection itself, e.g. ip address
    config = %{
      locales: locales
    }

    {format, conn} = Usir.Acceptor.init(acceptor, accepts, config)

    state = Protocol.init(conn, protocol_opts)

    req = :cowboy_req.set_resp_header("sec-websocket-protocol", "usir|" <> format, req)

    {:cowboy_websocket, req, state, protocol_opts[:conn_timeout] || 60_000}
  rescue
    _e in Usir.Server.Error.Unacceptable ->
      # TODO send appropriate response
      {:ok, req, nil}
  end

  def websocket_handle({type, msg}, req, state) when type in [:text, :binary] do
    state
    |> Protocol.handle_packet(msg)
    |> reply(req)
  rescue
    e ->
      ## TODO return server errors
      IO.puts Exception.format(:error, e, System.stacktrace)
      {:ok, req, state}
  end
  def websocket_handle(_other, req, state) do
    {:ok, req, state}
  end

  def websocket_info(msg, req, state) do
    state
    |> Protocol.handle_info(msg)
    |> reply(req)
  end

  defp reply({:reply, message, state}, req) do
    {:reply, message, req, state}
  end
  defp reply({:ok, state}, req) do
    {:ok, req, state}
  end

  defp format_protocols(:undefined, _) do
    nil
  end
  defp format_protocols([], []) do
    nil
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

  defp parse_csl(val) when val in ["", nil], do: nil
  defp parse_csl(bin), do: String.split(bin, ",")
end
