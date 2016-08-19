defmodule Usir.Message.Client do
  @type message :: Mount.t
                 | Unmount.t
                 | Authenticate.t
                 | Action.t

  defmodule Mount do
    defstruct [instance: nil,
               path: "/",
               state: nil,
               props: %{}]
  end

  defmodule Unmount do
    defstruct [instance: nil]
  end

  defmodule Authenticate do
    defstruct [instance: nil,
               method: nil,
               token: nil]
  end

  defmodule Action do
    defstruct [instance: nil,
               ref: nil,
               body: nil]
  end

  defmodule CallResponse do
    defstruct [instance: nil,
               ref: nil,
               data: nil]
  end

  def messages do
    [
      {Mount, 0, [:instance, :path, :state, :props]},
      {Unmount, 1, [:instance]},
      {Authenticate, 2, [:instance, :method, :token]},
      {Action, 3, [:instance, :ref, :body]},
      {CallResponse, 4, [:instance, :ref, :data]},
    ]
  end
end
