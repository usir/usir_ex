defmodule Usir.Server.Handler do
  use Behaviour
  alias Usir.Message.{Client,Server}

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
      require Logger

      def handle_error(handler, kind, %Server.Error{} = error, stacktrace, _) do
        info = Exception.format(kind, error, stacktrace)
        Logger.error(info)
        {:ok, error, handler}
      end
      def handle_error(handler, kind, error, stacktrace, %{path: path}) do
        info = Exception.format(kind, error, stacktrace)
        Logger.error(info)
        message = %Server.Error{info: info,
                                path: path}
        {:ok, message, handler}
      end

      def terminate(_, _) do
        :ok
      end

      defoverridable [handle_error: 5,
                      terminate: 2]
    end
  end

  @opaque return ::
    {:ok, Server.message | [Server.message], any} |
    {:noreply, any} |
    no_return

  defcallback init(map, Usir.Protocol.t) :: {:ok, any} | no_return
  defcallback mount(any, Client.Mount.t) :: return
  defcallback unmount(any, Client.Unmount.t) :: return
  defcallback authenticate(any, Client.Authenticate.t) :: return
  defcallback action(any, Client.Action.t) :: return
  defcallback handle_info(any, any) :: return
  defcallback handle_error(any, kind :: atom, error :: term, stacktrace :: list, message :: Client.message) :: return
  defcallback terminate(any, term) :: :ok
end
