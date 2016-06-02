defprotocol Usir.Format do
  def decode(format, bin)
  def encode(format, msg)
  def message_type(format)
end

defimpl Usir.Format, for: Atom do
  def decode(module, bin) do
    Usir.Format.decode(struct(module, []), bin)
  end

  def encode(module, msg) do
    Usir.Format.encode(struct(module, []), msg)
  end

  def message_type(module) do
    Usir.Format.encode(struct(module, []))
  end
end
