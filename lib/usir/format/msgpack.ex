defmodule Usir.Format.MSGPACK do
  defstruct([ext: __MODULE__])

  defmodule Error do
    defexception [:value, :struct, :keys]

    def message(%{value: value, struct: struct, keys: keys}) do
      "Error while decoding #{inspect(value)} into #{inspect(struct)}. Expected #{inspect(keys)}"
    end
  end

  def fetch(opts, key) do
    Map.fetch(opts, key)
  end

  def unpack(id, bin, opts \\ %{ext: __MODULE__})
  for {struct, id, keys} <- Usir.Message.messages do
    vars = keys |> Enum.map(&Macro.var(&1, nil))
    kvs = keys |> Enum.map(&{&1, Macro.var(&1, nil)})

    def unpack(unquote(id), bin, opts) do
      case Msgpax.Unpacker.unpack(bin, opts) do
        {:ok, unquote(vars), ""} ->
          {:ok, %unquote(struct){unquote_splicing(kvs)}}
        {:ok, value, _} ->
          raise %Error{value: value, struct: unquote(struct), keys: unquote(keys)}
        {:error, error} ->
          throw error
      end
    end

    defimpl Msgpax.Packer, for: struct do
      def transform(%{unquote_splicing(kvs)}) do
        bin = unquote(vars) |> Msgpax.Packer.transform() |> :erlang.iolist_to_binary()
        Msgpax.Ext.new(unquote(id), bin)
        |> Msgpax.Packer.transform()
      end
    end
  end
  def unpack(_, _, _) do
    :error
  end
end

defimpl Usir.Format, for: Usir.Format.MSGPACK do
  def decode(opts, bin) do
    bin
    |> Msgpax.unpack!(Map.put_new(opts, :ext, @for))
  end

  def encode(_opts, msg) do
    msg
    |> Msgpax.pack!()
  end

  def message_type(_) do
    :binary
  end
end
