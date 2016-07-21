defmodule Usir.Protocol do
  use Behaviour

  defstruct [host:        "www.example.com",
             owner:       nil,
             path:        nil,
             params:      %{},
             port:        0,
             private:     %{},
             protocol:    nil,
             peer:        nil,
             remote_ip:   nil,
             headers:     [],
             scheme:      :http]

  @opaque return ::
    {:ok, protocol :: any} |
    {:reply, packet :: term, protocol :: any} |
    no_return

  defcallback init(Usir.Conn.t, map | list) :: (protocol :: any)
  defcallback handle_packet(protocol :: any, packet :: term) :: return
  defcallback handle_info(protocol :: any, info :: term) :: return
  defcallback terminate(protocol :: any, reason :: term) :: return
end
