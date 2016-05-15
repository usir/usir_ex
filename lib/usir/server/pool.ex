defprotocol Usir.Server.Pool do
  def init(pool)
  def call(pool, call)
  def handle_info(pool, message)
  def size(pool)
end

defmodule Usir.Server.Pool.Spawn do
  defstruct pending: %{}
end

defimpl Usir.Server.Pool, for: Usir.Server.Pool.Spawn do
  require Logger

  def init(pool) do
    :erlang.process_flag(:trap_exit, true)
    pool
  end

  def call(%{pending: pending} = pool, {module, function, arguments}) do
    pid = spawn_link(fn ->
      value = try do
        apply(module, function, arguments)
      catch
        _, %Usir.Message.Server.Error{} = error ->
          Exception.format(:error, error, System.stacktrace)
          |> Logger.error()
          error
        class, error ->
          Exception.format(class, error, System.stacktrace)
          |> Logger.error()
          %Usir.Message.Server.Error{info: Exception.format_banner(class, error)}
      end
      exit({@for, value})
    end)

    {:await, %{pool | pending: Map.put(pending, pid, true)}}
  end

  def handle_info(%{pending: pending} = pool, {:EXIT, pid, {@for, value}}) do
    {value, %{pool | pending: Map.delete(pending, pid)}}
  end

  def size(%{pending: pending}) do
    map_size(pending)
  end
end
