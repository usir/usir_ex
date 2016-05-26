defmodule Usir.Format.JSON do
  defstruct pretty: false

  def fetch(opts, key) do
    Map.fetch(opts, key)
  end
end

defimpl Usir.Format, for: Usir.Format.JSON do
  def decode(opts, bin) do
    bin
    |> Poison.decode!(opts)
    |> Enum.map(&decode_message/1)
  end

  def encode(opts, msg) do
    msg
    |> Enum.map(&encode_message/1)
    |> Poison.encode!([pretty: opts.pretty])
  end

  messages = [
    {Usir.Message.Client.Resolve, 0, [:path]},
    {Usir.Message.Client.Authenticate, 1, [:method, :token]},
    {Usir.Message.Client.Message, 2, [:path, :affordance, :body]},
    {Usir.Message.Client.ChangeLocales, 3, [:locales]},
    {Usir.Message.Client.Body.Message, 4, [:input]},

    {Usir.Message.Server.Resolved, 63, [:path, :state, :etag, :body]},
    {Usir.Message.Server.Unresolved, 64, [:path]},
    {Usir.Message.Server.AuthenticationRequired, 65, [:path]},
    {Usir.Message.Server.AuthenticationInvalid, 66, [:method]},
    {Usir.Message.Server.Unauthorized, 67, [:path]},
    {Usir.Message.Server.MessageInvalid, 68, [:path, :affordance, :info]},
    {Usir.Message.Server.Error, 69, [:path, :info]}
  ]

  for {message, id, fields} <- messages do
    field_vars = Enum.map(fields, &Macro.var(&1, nil))
    struct_vars = Enum.map(fields, &{&1, Macro.var(&1, nil)})
    defp decode_message([unquote(id), unquote_splicing(field_vars)]) do
      %unquote(message){unquote_splicing(struct_vars)}
    end

    defp encode_message(%unquote(message){unquote_splicing(struct_vars)}) do
      [unquote(id), unquote_splicing(field_vars)]
    end
  end
end
