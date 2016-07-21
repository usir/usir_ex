defmodule Test.Usir.Client do
  use ExUnit.Case

  for {struct, _, _} <- Usir.Message.Server.messages do
    test "accepts #{inspect(struct)} message" do
      struct = %unquote(struct){}
      {:ok, _} = Usir.Client.handle_message(struct)
    end
  end

  for {struct, _, _} <- Usir.Message.Client.messages do
    test "denies #{inspect(struct)} message" do
      struct = %unquote(struct){}
      :error = Usir.Client.handle_message(struct)
    end
  end
end
