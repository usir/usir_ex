defmodule Usir.Protocol.Stateful.Server do
  alias Usir.Server.Conn
  alias Usir.Server.Pool
  alias Usir.Server.Queue

  defstruct [buffer: [],
             conn: nil,
             max_buffer_size: nil,
             max_timeout: nil,
             message_type: :binary,
             pool: nil,
             queue: nil,
             timeout: nil]

  def init(server, accepts, locales, auth, opts) do
    {format, conn} = Usir.Server.init(server, accepts, locales, auth)

    state = %__MODULE__{conn: conn,
                        max_buffer_size: opts[:max_buffer_size] || 10,
                        max_timeout: opts[:max_timeout] || 10,
                        pool: Pool.init(opts[:pool] || %Pool.Spawn{}),
                        queue: opts[:queue] || []}

    {format, state}
  end

  def handle_packet(%{conn: conn, queue: queue} = state, msg) do
    {conn, queue} = Conn.handle_packet(conn, msg, queue)

    %{state | conn: conn, queue: queue}
    |> call()
    |> reply()
  end

  def handle_info(state, {__MODULE__, :flush}) do
    send_packet(state)
  end
  def handle_info(state, msg) do
    msg
    |> handle_message(state)
    |> call()
    |> reply()
  end

  def terminate(_state) do
    # TODO shutdown everything
    nil
  end

  defp call(%{pool: pool, queue: queue} = state) do
    case Queue.pop(queue, Pool.size(pool)) do
      :empty ->
        %{state | queue: queue}
      {call, queue} ->
        case Pool.call(pool, call) do
          {:await, pool} ->
            call(%{state | pool: pool, queue: queue})
          {:ok, msg, pool} ->
            msg
            |> handle_message(%{state | pool: pool, queue: queue})
            |> call()
        end
    end
  end

  defp handle_message(msg, %{buffer: buffer, conn: conn, pool: pool} = state) do
    case Pool.handle_info(pool, msg) do
      nil ->
        state
      {msg, pool} ->
        {msg, conn} = Conn.handle_info(conn, msg)
        %{state | conn: conn, pool: pool, buffer: [msg | buffer]}
    end
  end

  defp send_packet(%{buffer: buffer, conn: conn, timeout: timeout, message_type: message_type} = state) do
    buffer = :lists.reverse(buffer)
    packet = Conn.encode_packet(conn, buffer)
    state = %{state | buffer: [], timeout: clear_timeout(timeout)}

    {:reply, {message_type, packet}, state}
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
