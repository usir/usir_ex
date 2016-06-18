defmodule Test.Usir.Server do
  use ExUnit.Case
  alias Usir.Message
  alias Usir.Conn
  alias Usir.Queue

  test "Message.Client.Resolve" do
    message = %Message.Client.Resolve{
      path: "/foo/bar/baz",
      etag: "tag1",
      state: "state1"
    }

    {_, q} = create_conn()
    |> Conn.decode_packet([message], %Usir.Queue.ErlQueue{})

    {{Foo, :resolve, [^message, %{}, ["en"]]}, q} = Queue.pop(q)
    :empty = Queue.pop(q)
  end

  test "Message.Server.Resolved" do
    {message, _} = create_conn()
    |> Conn.handle_info(%Message.Server.Resolved{
      path: "/foo/bar/baz",
      state: "state",
      etag: "etag"
    })

    assert "/foo/bar/baz" = message.path
  end

  defp create_conn(handler \\ Foo, format \\ %Usir.Format.Term{}, locales \\ ["en"]) do
    Usir.Server.new(%{locales: locales})
    |> Conn.new(handler, format)
  end
end
