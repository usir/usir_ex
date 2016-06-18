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
    [{:cowboy, github: "ninenines/cowboy", optional: true},
     {:poison, "~> 2.1.0"},
     {:msgpax, "~> 0.8", optional: true}]
  end
end
