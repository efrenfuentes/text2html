defmodule Text2Html.MixProject do
  use Mix.Project

  def project do
    [
      app: :text2html,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Text2Html",
      source_url: "https://github.com/efrenfuentes/text2html",
      homepage_url: "https://github.com/efrenfuentes/text2html",
      docs: [
        main: "Text2Html"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_html, "~> 2.11 or ~> 3.0 or ~> 4.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp description() do
    "Text2Html transform text into HTML.."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "text2html",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/efrenfuentes/text2html"}
    ]
  end
end
