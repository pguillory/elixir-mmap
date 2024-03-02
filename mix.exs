defmodule Mmap.MixProject do
  use Mix.Project

  def project do
    [
      app: :mmap,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  defp package do
    [
      description: "Replacement for File.read using mmap",
      licenses: ["MIT"],
      maintainers: ["pguillory@gmail.com"],
      links: %{
        "GitHub" => "https://github.com/pguillory/elixir-mmap"
      }
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
