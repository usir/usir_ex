defmodule Usir.Format.Term do
  defstruct([])
end

defimpl Usir.Format, for: Usir.Format.Term do
  def encode(_, terms) do
    terms
  end

  def decode(_, terms) do
    terms
  end

  def message_type(_) do
    :binary
  end
end
