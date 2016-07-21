defmodule Usir.Client do
  alias Usir.Message.Server

  @spec handle_message(Server.message) :: {:ok, atom} | :error
  def handle_message(message) do
    case message do
      %Server.Mounted{} ->
        {:ok, :mounted}
      %Server.Unmounted{} ->
        {:ok, :unmounted}
      %Server.NotFound{} ->
        {:ok, :not_found}
      %Server.AuthenticationRequired{} ->
        {:ok, :authentication_required}
      %Server.AuthenticationInvalid{} ->
        {:ok, :authentication_invalid}
      %Server.Unauthorized{} ->
        {:ok, :unauthorized}
      %Server.AuthenticationAcknowledged{} ->
        {:ok, :authentication_acknowledged}
      %Server.ActionAcknowledged{} ->
        {:ok, :action_acknowledged}
      %Server.ActionInvalid{} ->
        {:ok, :action_invalid}
      %Server.Error{} ->
        {:ok, :error}
      _ ->
        :error
    end
  end
end
