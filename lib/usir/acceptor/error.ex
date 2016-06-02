defmodule Usir.Acceptor.Error.Unacceptable do
  defexception [:provides, :requested]

  def message(_) do
    "Unacceptable request format"
  end
end
