defmodule Test.Usir.Server do
  use ExUnit.Case
  alias Usir.Server

  test "acceptable first" do
    {"msgpack", _conn} = Server.init(create_server(), ["msgpack", "json"], ["en"])
  end

  test "acceptable second" do
    {"json", _conn} = Server.init(create_server(), ["json", "foo"], ["en"])
  end

  test "unacceptable" do
    assert_raise Server.Error.Unacceptable, fn ->
      Server.init(create_server(), [], ["en"])
    end
  end

  defp create_server() do
    Server.new(nil, %{
      "msgpack" => %{},
      "json" => %{}
    })
  end
end
