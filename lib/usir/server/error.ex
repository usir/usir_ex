defmodule Usir.Server.Error.Unacceptable do
  defexception [:provides, :requested]

  def message(_) do
    "Unacceptable request format"
  end
end
