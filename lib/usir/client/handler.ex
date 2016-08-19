defmodule Usir.Client.Handler do
  use Behaviour
  alias Usir.Message.{Client,Server}

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      def handle_error(_, _, _, _, _) do
        :error
      end

      def terminate(_, _) do
        :ok
      end

      defoverridable [handle_error: 5,
                      terminate: 2]
    end
  end

  @opaque return ::
    {:ok, Client.message | [Client.message], any} |
    {:noreply, any} |
    no_return

  defcallback init(map, Usir.Protocol.t) :: {:ok, any} | no_return
  defcallback mounted(any, Server.Mounted.t) :: return
  defcallback unmounted(any, Server.Unmounted.t) :: return
  defcallback not_found(any, Server.NotFound.t) :: return
  defcallback authentication_required(any, Server.AuthenticationRequired.t) :: return
  defcallback authentication_invalid(any, Server.AuthenticationInvalid.t) :: return
  defcallback unauthorized(any, Server.Unauthorized.t) :: return
  defcallback authentication_acknowledged(any, Server.AuthenticationAcknowledged.t) :: return
  defcallback action_acknowledged(any, Server.ActionAcknowledged.t) :: return
  defcallback action_invalid(any, Server.ActionInvalid.t) :: return
  defcallback info(any, Server.Info.t) :: return
  defcallback call(any, Server.Call.t) :: return
  defcallback error(any, Server.Error.t) :: return
  defcallback handle_error(any, kind :: atom, error :: term, stacktrace :: list, message :: Server.message) :: return
  defcallback terminate(any, term) :: :ok
end
