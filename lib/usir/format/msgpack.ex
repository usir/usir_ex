defmodule Usir.Format.MSGPACK do
  defstruct([])

  def fetch(opts, key) do
    Map.fetch(opts, key)
  end
end

defimpl Usir.Format, for: Usir.Format.MSGPACK do
  import Usir.Format.Serializer

  def decode(opts, bin) do
    bin
    |> Msgpax.unpack!(opts)
    |> Enum.map(&decode_message/1)
  end

  def encode(_opts, msg) do
    msg
    |> Enum.map(&encode_message/1)
    |> Msgpax.pack!()
  end

  def message_type(_) do
    :binary
  end
end
