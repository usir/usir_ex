defmodule Usir.Format.Serializer do
  messages = [
    {Usir.Message.Client.Resolve, 0, [:path]},
    {Usir.Message.Client.Authenticate, 1, [:method, :token]},
    {Usir.Message.Client.Message, 2, [:path, :affordance, :body]},
    {Usir.Message.Client.ChangeLocales, 3, [:locales]},
    {Usir.Message.Client.Body.Message, 4, [:input]},

    {Usir.Message.Server.Resolved, 16, [:path, :state, :etag, :body]},
    {Usir.Message.Server.Unresolved, 17, [:path]},
    {Usir.Message.Server.AuthenticationRequired, 18, [:path]},
    {Usir.Message.Server.AuthenticationInvalid, 19, [:method]},
    {Usir.Message.Server.Unauthorized, 20, [:path]},
    {Usir.Message.Server.MessageInvalid, 21, [:path, :affordance, :info]},
    {Usir.Message.Server.Error, 22, [:path, :info]}
  ]

  for {message, id, fields} <- messages do
    field_vars = Enum.map(fields, &Macro.var(&1, nil))
    struct_vars = Enum.map(fields, &{&1, Macro.var(&1, nil)})
    def decode_message([unquote(id), unquote_splicing(field_vars)]) do
      %unquote(message){unquote_splicing(struct_vars)}
    end

    def encode_message(%unquote(message){unquote_splicing(struct_vars)}) do
      [unquote(id), unquote_splicing(field_vars)]
    end
  end
end
