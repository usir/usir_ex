defmodule Test.Usir.Protocol.Stateful do
  use ExUnit.Case
  alias Usir.Message
  alias Usir.Protocol.Stateful, as: Protocol

  defmodule Handler do
    def init(_, _) do
      {:ok, %{}}
    end

    def mount(_handler, %{instance: instance, path: "/error" = path}) do
      raise %Message.Server.Error{instance: instance, path: path, info: "foobar"}
    end
    def mount(handler, %{instance: instance, path: path}) do
      {:ok, %Message.Server.Mounted{instance: instance, path: path}, handler}
    end

    def handle_info(handler, message) do
      {:ok, message, handler}
    end

    def handle_error(handler, :error, error = %Message.Server.Error{}, _stacktrace, _message) do
      {:ok, [error], handler}
    end
  end

  test "resolve" do
    create_server()
    |> send_packet([%Message.Client.Mount{instance: 1, path: "/foo/bar/baz"}])
    |> assert_no_reply()
    |> timeout()
    |> assert_reply(1)
  end

  test "max buffer" do
    create_server(%{max_buffer_size: 2})
    |> send_packet([
      %Message.Client.Mount{instance: 1, path: "/foo"},
      %Message.Client.Mount{instance: 2, path: "/foo/bar"},
    ])
    |> assert_reply(2)
  end

  test "error" do
    create_server()
    |> send_packet([%Message.Client.Mount{instance: 1, path: "/error"}])
    |> assert_no_reply()
    |> timeout()
    |> assert_reply(1)
  end

  test "send_info" do
    create_server()
    |> send_info(%Message.Server.Mounted{instance: 1, path: "/foo"})
    |> assert_no_reply()
    |> timeout()
    |> assert_reply(1)
  end

  defp create_server(opts \\ %{}, accept \\ "term", handler \\ Handler, formats \\ %{"term" => %Usir.Format.Term{}}) do
    accepts = [accept]
    Usir.Server
    |> Usir.Acceptor.new(formats, handler, opts)
    |> Usir.Acceptor.init(accepts, %Usir.Protocol{})
    |> assert_accept(accept)
    |> Protocol.init(opts)
  end

  defp assert_accept({actual, server}, expected) do
    assert actual == expected
    server
  end

  defp assert_reply({:reply, {_, actual}, state}, expected) do
    assert length(actual) == expected
    state
  end

  defp assert_no_reply({:ok, state}) do
    state
  end

  defp send_packet(state, packet) do
    state
    |> Protocol.handle_packet(packet)
  end

  defp send_info(state, message) do
    state
    |> Protocol.handle_info(message)
  end

  defp timeout(state) do
    receive do
      message ->
        Protocol.handle_info(state, message)
    after
      1000 ->
        throw :timeout
    end
  end
end
