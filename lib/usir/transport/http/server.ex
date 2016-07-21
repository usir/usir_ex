defmodule Usir.Transport.HTTP.Server do
  def http(acceptor, protocol_opts \\ %{}, ranch_options \\ [port: 4000], cowboy_options \\ %{}) do
    opts = acceptor
    |> compile_dispatch(protocol_opts)
    |> set_dispatch(cowboy_options)

    acceptor
    |> handle_ref(ranch_options)
    |> start(:start_clear, ranch_options, opts)
  end

  def https(acceptor, protocol_opts \\ %{}, ranch_options \\ [port: 4000], cowboy_options \\ %{}) do
    opts = acceptor
    |> compile_dispatch(protocol_opts)
    |> set_dispatch(cowboy_options)

    acceptor
    |> handle_ref(ranch_options)
    |> start(:start_tls, ranch_options, opts)
  end

  def close(ref) do
    :cowboy.stop_listener(ref)
  end

  defp start(ref, fun, ranch_options, cowboy_options) do
    {:ok, _} = :application.ensure_all_started(:cowboy)
    case apply(:cowboy, fun, [ref, 100, ranch_options, cowboy_options]) do
      {:ok, _} ->
        {:ok, ref}
      error ->
        error
    end
  end

  defp handle_ref(%{handler: handler}, opts) do
    case opts[:port] do
      0 ->
        Module.concat(handler, "HTTP_#{:erlang.unique_integer}")
      port ->
        Module.concat(handler, "HTTP_#{port}")
    end
  end

  defp set_dispatch(dispatch, opts = %{env: env}) do
    %{opts | env: Map.put(env, :dispatch, dispatch)}
  end
  defp set_dispatch(dispatch, cowboy_options) do
    Map.put(cowboy_options, :env, %{dispatch: dispatch})
  end

  defp compile_dispatch(acceptor, protocol_opts) do
    :cowboy_router.compile([
      {:_, [
        {:_, __MODULE__.Router, {acceptor, protocol_opts}}
      ]}
    ])
  end
end
