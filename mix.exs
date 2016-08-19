defmodule Usir.Mixfile do
  use Mix.Project

  def project do
    [app: :usir,
     version: "0.2.0",
     elixir: "~> 1.2",
     description: "Elixir implementation of the usir protocol",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:cowboy, github: "ninenines/cowboy", optional: true},
     {:websocket_client, github: "jeremyong/websocket_client", optional: true},
     {:poison, "~> 2.2", optional: true},
     {:msgpax, "~> 0.8", optional: true},
     {:mix_test_watch, "~> 0.2", only: :dev},]
  end

  defp package do
    [files: ["lib", "mix.exs", "README*"],
     maintainers: ["Cameron Bytheway"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/usir/usir_ex"}]
  end
end
