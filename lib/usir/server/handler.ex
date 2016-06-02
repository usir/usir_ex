defmodule Usir.Server.Handler do
  use Behaviour

  @type message :: map

  defcallback authenticate(message)
  defcallback resolve(message)
  defcallback handle_message(message)
end
