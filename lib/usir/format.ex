defprotocol Usir.Format do
  def decode(format, bin)
  def encode(format, msg)
end
