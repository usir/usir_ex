defmodule Usir.Transport.HTTP.Server.Handler do
  def init(req, {_, _}) do
    {:ok, req, nil}
  end
end
