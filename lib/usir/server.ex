defmodule Usir.Server do
  alias Usir.Message.Client

  @spec handle_message(Client.message) :: {:ok, atom} | :error
  def handle_message(message) do
    case message do
      %Client.Mount{} ->
        {:ok, :mount}
      %Client.Unmount{} ->
        {:ok, :unmount}
      %Client.Authenticate{} ->
        {:ok, :authenticate}
      %Client.Action{} ->
        {:ok, :action}
      _ ->
        :error
    end
  end
end
