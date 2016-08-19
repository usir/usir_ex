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

  defmodule Info do
    defstruct [instance: nil,
               name: nil,
               data: nil]
  end

  defmodule Call do
    defstruct [instance: nil,
               name: nil,
               data: nil,
               ref: nil]
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
      {Mounted, 8, [:instance, :path, :state, :body]},
      {Unmounted, 9, [:instance]},
      {NotFound, 10, [:instance, :path]},
      {AuthenticationRequired, 11, [:instance, :methods]},
      {AuthenticationInvalid, 12, [:instance, :method]},
      {Unauthorized, 13, [:instance, :info]},
      {AuthenticationAcknowledged, 14, [:instance, :method]},
      {ActionAcknowledged, 15, [:instance, :ref]},
      {ActionInvalid, 16, [:instance, :ref, :info]},
      {Info, 17, [:instance, :name, :data]},
      {Call, 18, [:instance, :name, :data, :ref]},
      {Error, 19, [:instance, :path, :info]}
    ]
  end
end
