defmodule Usir.Dispatch.Spawn do
  defstruct pending: %{}
end

defimpl Usir.Dispatch, for: Usir.Dispatch.Spawn do
  require Logger

  def init(dispatch) do
    :erlang.process_flag(:trap_exit, true)
    dispatch
  end

  def call(%{pending: pending} = dispatch, {module, function, arguments}) do
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

    {:await, %{dispatch | pending: Map.put(pending, pid, true)}}
  end

  def handle_info(%{pending: pending} = dispatch, {:EXIT, pid, {@for, value}}) do
    {value, %{dispatch | pending: Map.delete(pending, pid)}}
  end

  def size(%{pending: pending}) do
    map_size(pending)
  end
end
