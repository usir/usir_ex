## Client

defmodule Usir.Message.Client.Resolve do
  defstruct path: []
end

defmodule Usir.Message.Client.Authenticate do
  defstruct method: nil,
            token: nil
end

defmodule Usir.Message.Client.Message do
  defstruct path: [],
            affordance: nil,
            body: nil
end

defmodule Usir.Message.Client.ChangeLocales do
  defstruct locales: []
end

defmodule Usir.Message.Client.Body.Message do
  defstruct input: %{}
end

## Server

defmodule Usir.Message.Server.Resolved do
  defstruct path: [],
            state: nil,
            etag: nil,
            _locale: nil,
            _provided_locales: nil,
            body: nil
end

defmodule Usir.Message.Server.Unresolved do
  defstruct path: []
end

defmodule Usir.Message.Server.AuthenticationRequired do
  defstruct path: []
end

defmodule Usir.Message.Server.AuthenticationInvalid do
  defstruct method: nil
end

defmodule Usir.Message.Server.Unauthorized do
  defstruct path: []
end

defmodule Usir.Message.Server.MessageInvalid do
  defstruct affordance: nil,
            info: nil
end

defmodule Usir.Message.Server.Error do
  defstruct path: [],
            info: nil
end

defmodule Usir.Message.Server.Body.Component do
  defstruct type: nil,
            locale: nil,
            props: %{},
            affordances: %{}
end

defmodule Usir.Message.Server.Body.Affordance do
  defstruct id: nil,
            path: [],
            input: %{}
end
