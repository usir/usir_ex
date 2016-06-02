defmodule Usir.Protocol.Stateful do
  alias Usir.Conn
  alias Usir.Dispatch
  alias Usir.Queue

  defstruct [buffer: [],
             conn: nil,
             max_buffer_size: nil,
             max_timeout: nil,
             message_type: :binary,
             dispatch: nil,
             queue: nil,
             timeout: nil]

  def init(conn, opts) do
    %__MODULE__{
      conn: conn,
      max_buffer_size: opts[:max_buffer_size] || 10,
      max_timeout: opts[:max_timeout] || 10,
      dispatch: Dispatch.init(opts[:dispatch] || %Dispatch.Spawn{}),
      queue: opts[:queue] || %Queue.ErlQueue{}
    }
  end

  def handle_packet(%{conn: conn, queue: queue} = state, msg) do
    {conn, queue} = Conn.decode_packet(conn, msg, queue)

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

  defp call(%{dispatch: dispatch, queue: queue} = state) do
    case Queue.pop(queue, Dispatch.size(dispatch)) do
      :empty ->
        %{state | queue: queue}
      {call, queue} ->
        case Dispatch.call(dispatch, call) do
          {:await, dispatch} ->
            call(%{state | dispatch: dispatch, queue: queue})
          {:ok, msg, dispatch} ->
            msg
            |> handle_message(%{state | dispatch: dispatch, queue: queue})
            |> call()
        end
    end
  end

  defp handle_message(msg, %{buffer: buffer, conn: conn, dispatch: dispatch} = state) do
    case Dispatch.handle_info(dispatch, msg) do
      nil ->
        state
      {msg, dispatch} ->
        {msg, conn} = Conn.handle_info(conn, msg)
        %{state | conn: conn, dispatch: dispatch, buffer: [msg | buffer]}
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
