defmodule Usir.Format.JSON do
  defstruct pretty: false

  def fetch(opts, key) do
    Map.fetch(opts, key)
  end
end

# defimpl Usir.Format, for: Usir.Format.JSON do
#   import Usir.Format.Serializer

#   def decode(opts, bin) do
#     bin
#     |> Poison.decode!(opts)
#     |> Enum.map(&decode_message/1)
#   end

#   def encode(opts, msg) do
#     msg
#     |> Enum.map(&encode_message/1)
#     |> Poison.encode!([pretty: opts.pretty])
#   end

#   def message_type(_) do
#     :text
#   end
# end
