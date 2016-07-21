defmodule Usir.Protocol.Stateful do
  alias Usir.Conn
  @behaviour Usir.Protocol

  defstruct [buffer: [],
             conn: nil,
             max_buffer_size: nil,
             max_timeout: nil,
             timeout: nil]

  def init(conn, opts) do
    %__MODULE__{
      conn: conn,
      max_buffer_size: opts[:max_buffer_size] || 10,
      max_timeout: opts[:max_timeout] || 10
    }
  end

  def handle_packet(%{conn: conn, buffer: buffer} = state, msg) do
    {messages, conn} = Conn.decode_packet(conn, msg)

    %{state | conn: conn, buffer: buffer ++ messages}
    |> reply()
  end

  def handle_info(state, {__MODULE__, :flush}) do
    send_packet(state)
  end
  def handle_info(state, msg) do
    msg
    |> handle_message(state)
    |> reply()
  end

  def terminate(%{conn: conn}, reason) do
    Conn.terminate(conn, reason)
    :ok
  end

  defp handle_message(msg, %{buffer: buffer, conn: conn} = state) do
    {messages, conn} = Conn.handle_info(conn, msg)
    %{state | conn: conn, buffer: buffer ++ messages}
  end

  defp send_packet(%{buffer: buffer, conn: conn, timeout: timeout} = state) do
    packet = Conn.encode_packet(conn, buffer)
    state = %{state | buffer: [], timeout: clear_timeout(timeout)}

    {:reply, packet, state}
  end

  defp reply(%{buffer: []} = state) do
    {:ok, state}
  end
  defp reply(%{buffer: buffer, max_buffer_size: max_buffer_size} = state) when length(buffer) >= max_buffer_size do
    send_packet(state)
  end
  defp reply(%{timeout: nil, max_timeout: max_timeout} = state) do
    ref = :erlang.send_after(max_timeout, self(), {__MODULE__, :flush})
    {:ok, %{state | timeout: ref}}
  end
  defp reply(state) do
    {:ok, state}
  end

  defp clear_timeout(nil) do
    nil
  end
  defp clear_timeout(ref) do
    :erlang.cancel_timer(ref)
    nil
  end
end
