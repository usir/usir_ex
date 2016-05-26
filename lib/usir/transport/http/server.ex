defmodule Usir.Transport.HTTP.Server do
  def http(handler, opts \\ %{}, cowboy_options \\ []) do
    server = Usir.Server.new(handler, opts[:formats] || %{"json" => Usir.Format.JSON})
    dispatch = :cowboy_router.compile([
      {:_, [
        {:_, __MODULE__.Handler, Map.put(opts, :server, server)}
      ]}
    ])
    ref = Module.concat(handler, HTTP.Server)
    :cowboy.start_clear(ref, 100, [port: 8080], %{env: %{dispatch: dispatch}})
  end

  def https(plug, opts, cowboy_options \\ []) do
    Plug.Adapters.Cowboy.https(plug, opts, set_dispatch(plug, opts, cowboy_options))
  end

  def shutdown(ref) do
    Plug.Adapters.Cowboy.shutdown(ref)
  end

  def child_spec(scheme, plug, opts, cowboy_options \\ []) do
    cowboy_options = set_dispatch(plug, opts, cowboy_options)
    Plug.Adapters.Cowboy.child_spec(scheme, plug, opts, cowboy_options)
  end

  ## Helpers

  defp set_dispatch(plug, opts, options) do
    Keyword.put(options, :dispatch, dispatch_for(plug, opts, options))
  end

  defp dispatch_for(plug, opts, options) do
    opts = plug.init(opts)
    [{:_, [ {:_, __MODULE__.Handler, {plug, opts}} ]}]
  end
end
