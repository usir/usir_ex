defmodule Usir.Mixfile do
  use Mix.Project

  def project do
    [app: :usir,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:cowboy, github: "camshaft/cowboy", optional: true},
     {:websocket_client, github: "jeremyong/websocket_client", optional: true},
     {:poison, "~> 2.2", optional: true},
     {:msgpax, "~> 0.8", optional: true},
     {:mix_test_watch, "~> 0.2", only: :dev},]
  end
end
