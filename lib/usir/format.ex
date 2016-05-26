defprotocol Usir.Format do
  def decode(format, bin)
  def encode(format, msg)
end

defimpl Usir.Format, for: Atom do
  def decode(module, bin) do
    Usir.Format.decode(struct(module, []), bin)
  end

  def encode(module, msg) do
    Usir.Format.encode(struct(module, []), msg)
  end
end
