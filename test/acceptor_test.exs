defmodule Test.Usir.Acceptor do
  use ExUnit.Case
  alias Usir.Acceptor
  alias Usir.Protocol

  defmodule ServerHandler do
    def init(_, _) do
      {:ok, nil}
    end
  end

  test "acceptable first" do
    {"msgpack", _conn} = Acceptor.init(create_acceptor(), ["msgpack", "json"], %Protocol{})
  end

  test "acceptable second" do
    {"json", _conn} = Acceptor.init(create_acceptor(), ["foo", "json"], %Protocol{})
  end

  test "unacceptable list" do
    assert_raise Acceptor.Error.Unacceptable, fn ->
      Acceptor.init(create_acceptor(), ["foo", "bar"], %Protocol{})
    end
  end

  test "unacceptable empty" do
    assert_raise Acceptor.Error.Unacceptable, fn ->
      Acceptor.init(create_acceptor(), [], %Protocol{})
    end
  end

  defp create_acceptor() do
    Acceptor.new(Usir.Server, %{
      "msgpack" => %{},
      "json" => %{}
    }, ServerHandler)
  end
end
