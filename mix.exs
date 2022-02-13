defmodule CqrsToolsDdd.MixProject do
  use Mix.Project

  def project do
    [
      app: :cqrs_tools_ddd,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        description: "DDD semantics for cqrs_tools",
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/elixir-cqrs/cqrs_tools_ddd"}
      ],
      source_url: "https://github.com/elixir-cqrs/cqrs_tools_ddd",
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cqrs_tools, path: "../cqrs_tools"},
      {:etso, "~> 0.1.6", only: [:test]},
      {:faker, "~> 0.17.0", optional: true},
      {:ex_machina, "~> 2.7", optional: true},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:elixir_uuid, "~> 1.6", override: true, hex: :uuid_utils, only: :test}
    ]
  end
end
