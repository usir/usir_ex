defmodule Test.Usir.Server do
  use ExUnit.Case
  alias Usir.Server

  test "acceptable first" do
    {"msgpack", _conn} = Server.init(create_server(), ["msgpack", "json"], ["en"])
  end

  test "acceptable second" do
    {"json", _conn} = Server.init(create_server(), ["foo", "json"], ["en"])
  end

  test "unacceptable list" do
    assert_raise Server.Error.Unacceptable, fn ->
      Server.init(create_server(), ["foo", "bar"], ["en"])
    end
  end

  test "unacceptable empty" do
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
