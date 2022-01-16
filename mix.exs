defmodule RclexBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :rclex_bench,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.target()),
      start_permanent: Mix.env() == :prod,
      deps: deps(Mix.target())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps(:rclex051) do
    [
      {:rclex, path: "../rclex_051/rclex"}
    ]
  end
  defp deps(:rclexcm) do
    [
      {:rclex, path: "../rclex"}
    ]
  end

  defp elixirc_paths(:rclex051), do: ["lib", "lib_051"]
  defp elixirc_paths(:rclexcm), do: ["lib", "lib_cm"]
end
