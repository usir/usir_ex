defmodule Usir.Acceptor do
  defstruct backend: nil,
            handler: nil,
            formats: %{}

  alias Usir.Conn

  def new(backend, handler, formats) do
    %__MODULE__{
      backend: backend,
      handler: handler,
      formats: formats
    }
  end

  def init(%{handler: handler, formats: formats, backend: backend}, accepts, opts) do
    case accept(accepts, formats) do
      nil ->
        raise __MODULE__.Error.Unacceptable, provides: formats, requested: accepts
      {format, formatter} ->
        backend = backend.new(opts)
        {format, Conn.new(backend, handler, formatter)}
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
