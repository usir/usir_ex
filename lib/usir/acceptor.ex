defmodule Usir.Acceptor do
  defstruct [backend: nil,
             handler: nil,
             handler_opts: %{},
             formats: %{}]

  alias Usir.Conn

  def new(backend, formats, handler, handler_opts \\ %{}) do
    %__MODULE__{
      backend: backend,
      handler: handler,
      handler_opts: handler_opts,
      formats: formats
    }
  end

  def init(%{formats: formats, backend: backend, handler: handler, handler_opts: handler_opts}, accepts, protocol_info) do
    case accept(accepts, formats) do
      nil ->
        raise __MODULE__.Error.Unacceptable, provides: formats, requested: accepts
      {format, formatter} ->
        {format, Conn.init(backend, formatter, handler, handler_opts, protocol_info)}
    end
  end

  defp accept([], _) do
    nil
  end
  defp accept([accept | accepts], formats) do
    case Map.fetch(formats, accept) do
      :error ->
        accept(accepts, formats)
      {:ok, formatter} ->
        {accept, formatter}
    end
  end
end
