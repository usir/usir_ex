defmodule Test.Usir.Server.Conn do
  use ExUnit.Case
  alias Usir.Message
  alias Usir.Server.Conn
  alias Usir.Server.Queue

  test "Message.Client.Resolve" do
    {_, q} = create_conn()
    |> Conn.handle_packet([
      %Message.Client.Resolve{path: [
        {"foo", "state1", "tag1"},
        {"bar", "state2", "tag2"},
        {"baz", "state3", "tag3"}
      ]
    }], [])

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
    %Conn{handler: handler,
          format: format,
          locales: locales}
  end
end
