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
    defstruct [path: "/",
               state: nil,
               body: nil]
  end

  defmodule Unmounted do
    defstruct [path: "/",
               state: nil]
  end

  defmodule NotFound do
    defstruct [path: "/"]
  end

  defmodule AuthenticationRequired do
    defstruct [path: "/",
               methods: []]
  end

  defmodule AuthenticationInvalid do
    defstruct [path: "/",
               method: nil]
  end

  defmodule Unauthorized do
    defstruct [path: "/",
               info: nil]
  end

  defmodule AuthenticationAcknowledged do
    defstruct [path: "/",
               method: nil]
  end

  defmodule ActionAcknowledged do
    defstruct [path: "/",
               ref: nil]
  end

  defmodule ActionInvalid do
    defstruct [path: "/",
               ref: nil,
               info: nil]
  end

  defmodule Error do
    defexception [path: "/",
                  info: nil]

    def message(%{path: path, info: info}) when info in [nil, ""] do
      "Got error at path #{inspect(path)}"
    end
    def message(%{path: path, info: info}) do
      "Got error #{inspect(info)} at path #{inspect(path)}"
    end
  end

  def messages do
    [
      {Mounted, 4, [:path, :state, :body]},
      {Unmounted, 5, [:path]},
      {NotFound, 6, [:path]},
      {AuthenticationRequired, 7, [:path, :methods]},
      {AuthenticationInvalid, 8, [:path, :method]},
      {Unauthorized, 9, [:path, :info]},
      {AuthenticationAcknowledged, 10, [:path, :method]},
      {ActionAcknowledged, 11, [:path, :ref]},
      {ActionInvalid, 12, [:path, :ref, :info]},
      {Error, 13, [:path, :info]}
    ]
  end
end
