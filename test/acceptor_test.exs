defmodule Test.Usir.Acceptor do
  use ExUnit.Case
  alias Usir.Acceptor

  test "acceptable first" do
    {"msgpack", _conn} = Acceptor.init(create_acceptor(), ["msgpack", "json"], ["en"])
  end

  test "acceptable second" do
    {"json", _conn} = Acceptor.init(create_acceptor(), ["foo", "json"], ["en"])
  end

  test "unacceptable list" do
    assert_raise Acceptor.Error.Unacceptable, fn ->
      Acceptor.init(create_acceptor(), ["foo", "bar"], ["en"])
    end
  end

  test "unacceptable empty" do
    assert_raise Acceptor.Error.Unacceptable, fn ->
      Acceptor.init(create_acceptor(), [], ["en"])
    end
  end

  defp create_acceptor() do
    Acceptor.new(Usir.Server, nil, %{
      "msgpack" => %{},
      "json" => %{}
    })
  end
end
