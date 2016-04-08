defmodule Usir.Server do
  defstruct handler: nil,
            formats: %{}

  def new(handler, formats, _opts \\ %{}) do
    %__MODULE__{handler: handler,
                formats: formats}
  end

  def init(%{handler: handler, formats: formats}, accepts, locales, auth \\ %{}) do
    case accept(accepts, formats) do
      nil ->
        raise __MODULE__.Error.Unacceptable, provides: formats, requested: accepts
      {format, formatter} ->
        {format, %__MODULE__.Conn{handler: handler,
                                  format: formatter,
                                  locales: locales,
                                  auth: auth}}
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
