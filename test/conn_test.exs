defmodule Test.Usir.Conn do
  use ExUnit.Case
  alias Usir.Conn
  alias Usir.Protocol

  defmodule Handler do
    use Usir.Server.Handler

    def init(opts, _protocol) do
      {:ok, opts}
    end

    def mount(state, _) do
      {:ok, [], state}
    end

    def unmount(state, _) do
      {:ok, [%Usir.Message.Server.Unmounted{}], state}
    end

    def authenticate(state, _) do
      {:noreply, state}
    end

    def action(_, _) do
      throw :action_called
    end

    def handle_info(state, info) do
      {:ok, [info], state}
    end
  end

  test "create server conn" do
    server = create_conn(Usir.Server, :FOO)
    assert :FOO == server.handler_state
  end

  test "create client conn" do
    client = create_conn(Usir.Client, :BAR)
    assert :BAR == client.handler_state
  end

  test "return with empty list" do
    {[], _} = create_conn(Usir.Server)
    |> Conn.decode_packet([
      %Usir.Message.Client.Mount{}
    ])
  end

  test "return with message" do
    {[_], _} = create_conn(Usir.Server)
    |> Conn.decode_packet([
      %Usir.Message.Client.Unmount{}
    ])
  end

  test "return with no response" do
    {[], _} = create_conn(Usir.Server)
    |> Conn.decode_packet([
      %Usir.Message.Client.Authenticate{}
    ])
  end

  test "handle info" do
    {[:foo], _} = create_conn(Usir.Server)
    |> Conn.handle_info(:foo)
  end

  defp create_conn(backend, opts \\ %{}) do
    Conn.init(backend, Usir.Format.Term, Handler, opts, %Protocol{})
  end
end
