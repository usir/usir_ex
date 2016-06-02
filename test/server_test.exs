defmodule Test.Usir.Server do
  use ExUnit.Case
  alias Usir.Message
  alias Usir.Conn
  alias Usir.Queue

  test "Message.Client.Resolve" do
    {_, q} = create_conn()
    |> Conn.decode_packet([
      %Message.Client.Resolve{path: [
        {"foo", "state1", "tag1"},
        {"bar", "state2", "tag2"},
        {"baz", "state3", "tag3"}
      ]
    }], %Usir.Queue.ErlQueue{})

    {{Foo, :resolve, [["foo"], "state1", "tag1", %{}, ["en"]]}, q} = Queue.pop(q)
    {{Foo, :resolve, [["foo", "bar"], "state2", "tag2", %{}, ["en"]]}, q} = Queue.pop(q)
    {{Foo, :resolve, [["foo", "bar", "baz"], "state3", "tag3", %{}, ["en"]]}, q} = Queue.pop(q)
    :empty = Queue.pop(q)
  end

  test "Message.Server.Resolved" do
    {message, _} = create_conn()
    |> Conn.handle_info(%Message.Server.Resolved{
      path: ["foo", "bar", "baz"],
      state: "state",
      etag: "etag"
    })

    assert ["foo", "bar", "baz"] = message.path
  end

  defp create_conn(handler \\ Foo, format \\ %Usir.Format.Term{}, locales \\ ["en"]) do
    Usir.Server.new(%{locales: locales})
    |> Conn.new(handler, format)
  end
end
