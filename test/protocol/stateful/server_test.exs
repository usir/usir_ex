defmodule Test.Usir.Protocol.Stateful.Server do
  use ExUnit.Case
  alias Usir.Message
  alias Usir.Protocol.Stateful.Server, as: Protocol

  defmodule Handler do
    def resolve(["error"] = path, _, _, _, _) do
      throw %Message.Server.Error{path: path, info: "foobar"}
    end
    def resolve(path, _, _, _, _) do
      %Message.Server.Resolved{path: path}
    end
  end

  test "resolve" do
    create_server()
    |> send_packet([%Message.Client.Resolve{path: [{"foo", nil, nil}, {"bar", nil, nil}, {"baz", nil, nil}]}])
    |> await(3)
    |> assert_reply(3)
  end

  test "max buffer" do
    create_server(%{max_buffer_size: 2})
    |> send_packet([%Message.Client.Resolve{path: [{"foo", nil, nil}, {"bar", nil, nil}, {"baz", nil, nil}]}])
    |> await(1)
    |> assert_reply(2)
    |> await(1)
    |> assert_reply(1)
  end

  test "error" do
    create_server()
    |> send_packet([%Message.Client.Resolve{path: [{"error", nil, nil}]}])
    |> await(1)
    |> assert_reply(1)
  end

  defp create_server(opts \\ %{}, accept \\ "term", handler \\ Handler, formats \\ %{"term" => %Usir.Format.Term{}}) do
    Usir.Server.new(handler, formats)
    |> Protocol.init(%{accept: [accept]} |> Map.merge(opts))
    |> assert_accept(accept)
  end

  defp assert_accept({actual, server}, expected) do
    assert actual == expected
    server
  end

  defp assert_ok({:ok, state}) do
    state
  end

  defp assert_reply({:reply, {_, actual}, state}, expected) do
    assert length(actual) == expected
    state
  end
  defp assert_reply(state, count) when is_map(state) do
    state
    |> await()
    |> assert_reply(count)
  end

  defp send_packet(state, packet) do
    state
    |> Protocol.handle_packet(packet)
    |> assert_ok()
  end

  defp await(state, 0) do
    state
  end
  defp await(state, count) do
    state
    |> await()
    |> assert_ok()
    |> await(count - 1)
  end

  defp await(state) do
    receive do
      message ->
        Protocol.handle_info(state, message)
    after
      1000 ->
        throw :timeout
    end
  end
end
