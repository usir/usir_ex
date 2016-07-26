defmodule Usir.Message.Server do
  @type message :: Mounted.t
                 | Unmounted.t
                 | NotFound.t
                 | AuthenticationRequired.t
                 | AuthenticationInvalid.t
                 | Unauthorized.t
                 | ActionAcknowledged.t
                 | ActionInvalid.t
                 | Error.t

  defmodule Mounted do
    defstruct [instance: nil,
               path: "/",
               state: nil,
               body: nil]
  end

  defmodule Unmounted do
    defstruct [instance: nil,
               state: nil]
  end

  defmodule NotFound do
    defstruct [instance: nil,
               path: "/"]
  end

  defmodule AuthenticationRequired do
    defstruct [instance: nil,
               methods: []]
  end

  defmodule AuthenticationInvalid do
    defstruct [instance: nil,
               method: nil]
  end

  defmodule Unauthorized do
    defstruct [instance: nil,
               info: nil]
  end

  defmodule AuthenticationAcknowledged do
    defstruct [instance: nil,
               method: nil]
  end

  defmodule ActionAcknowledged do
    defstruct [instance: nil,
               ref: nil]
  end

  defmodule ActionInvalid do
    defstruct [instance: nil,
               ref: nil,
               info: nil]
  end

  defmodule Error do
    defexception [instance: nil,
                  path: nil,
                  info: nil]

    def message(%{intstance: instance, info: info}) when info in [nil, ""] do
      "Got error in instance #{inspect(instance)}"
    end
    def message(%{instance: instance, info: info}) do
      "Got error #{inspect(info)} in instance #{inspect(instance)}"
    end
  end

  def messages do
    [
      {Mounted, 4, [:instance, :path, :state, :body]},
      {Unmounted, 5, [:instance]},
      {NotFound, 6, [:instance, :path]},
      {AuthenticationRequired, 7, [:instance, :methods]},
      {AuthenticationInvalid, 8, [:instance, :method]},
      {Unauthorized, 9, [:instance, :info]},
      {AuthenticationAcknowledged, 10, [:instance, :method]},
      {ActionAcknowledged, 11, [:instance, :ref]},
      {ActionInvalid, 12, [:instance, :ref, :info]},
      {Error, 13, [:instance, :path, :info]}
    ]
  end
end
