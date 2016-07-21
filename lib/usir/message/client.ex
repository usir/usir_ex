defmodule Usir.Message.Client do
  @type message :: Mount.t
                 | Unmount.t
                 | Authenticate.t
                 | Action.t

  defmodule Mount do
    defstruct [path: "/",
               state: nil,
               props: %{}]
  end

  defmodule Unmount do
    defstruct [path: "/"]
  end

  defmodule Authenticate do
    defstruct [path: "/",
               method: nil,
               token: nil]
  end

  defmodule Action do
    defstruct [path: "/",
               ref: nil,
               body: nil]
  end

  def messages do
    [
      {Mount, 0, [:path, :state, :props]},
      {Unmount, 1, [:path]},
      {Authenticate, 2, [:method, :token]},
      {Action, 3, [:path, :ref, :body]},
    ]
  end
end
