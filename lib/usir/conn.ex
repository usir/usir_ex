defmodule Usir.Conn do
  defstruct [format: nil,
             backend: nil,
             handler: nil,
             handler_state: nil]

  require Logger
  alias Usir.Format

  def init(backend, format, handler, handler_opts, protocol_info) do
    case handler.init(handler_opts, protocol_info) do
      {:ok, state} ->
        %__MODULE__{
          backend: backend,
          handler: handler,
          handler_state: state,
          format: format
        }
    end
  end

  def encode_packet(%{format: format}, messages) do
    {Format.message_type(format), Format.encode(format, messages)}
    ## TODO we should catch errors here as well
  end

  def decode_packet(conn = %{format: format, backend: backend, handler: handler}, packet) do
    format
    |> Format.decode(packet)
    |> Enum.reduce({:ok, [], conn}, fn
      (message, {:ok, acc, conn}) ->
        case apply(backend, :handle_message, [message]) do
          {:ok, fun} ->
            call(conn, fun, message, acc)
          :error ->
            Logger.warn("Invalid message received for #{inspect(handler)}: #{inspect(message)}")
  {acc, conn}
        end
      (_, {:close, conn}) ->
        {:close, conn}
    end)
    ## TODO we should probably catch errors when decoding packets and send down errors
    ##      - don't want to shutdown the whole connection just cause of one bad packet, right?
  end

  def handle_info(conn, message) do
    call(conn, :handle_info, message, [])
  rescue
    error ->
      handle_error(conn, :error, error, message, [], System.stacktrace)
  catch
    kind, error ->
      handle_error(conn, kind, error, message, [], System.stacktrace)
  end

  def terminate(%{handler: handler, handler_state: state}, reason) do
    apply(handler, :terminate, [state, reason])
  catch
    _, _ ->
      :ok
  end

  defp call(conn = %{handler: handler, handler_state: handler_state}, fun, message, acc) do
    case apply(handler, fun, [handler_state, message]) do
      {:ok, [], handler_state} ->
        {:ok, acc, %{conn | handler_state: handler_state}}
      {:ok, messages, handler_state} when is_list(messages) ->
        {:ok, acc ++ messages, %{conn | handler_state: handler_state}}
      {:ok, %{:__struct__ => _} = message, handler_state} ->
        {:ok, acc ++ [message], %{conn | handler_state: handler_state}}
      {:noreply, handler_state} ->
        {:ok, acc, %{conn | handler_state: handler_state}}
      {:close, handler_state} ->
        {:close, %{conn | handler_state: handler_state}}
    end
  rescue
    error ->
      handle_error(conn, :error, error, message, acc, System.stacktrace)
  catch
    kind, error ->
      handle_error(conn, kind, error, message, acc, System.stacktrace)
  end

  defp handle_error(conn = %{handler: handler, handler_state: handler_state}, kind, error, message, acc, stacktrace) do
    case apply(handler, :handle_error, [handler_state, kind, error, stacktrace, message]) do
      {:ok, [], handler_state} ->
        {:ok, acc, %{conn | handler_state: handler_state}}
      {:ok, messages, handler_state} when is_list(messages) ->
        {:ok, acc ++ messages, %{conn | handler_state: handler_state}}
      {:ok, %{:__struct__ => _} = message, handler_state} ->
        {:ok, acc ++ [message], %{conn | handler_state: handler_state}}
      {:noreply, handler_state} ->
        {:ok, acc, %{conn | handler_state: handler_state}}
      {:close, handler_state} ->
        {:close, %{conn | handler_state: handler_state}}
    end
  catch
    _, _ ->
      cond do
        kind == :error ->
          reraise error, stacktrace
        kind == :throw ->
          throw error
        kind == :exit ->
          exit(error)
      end
  end
end
