defmodule FarmbotOS.MixProject do
  use Mix.Project

  @all_targets [:rpi3, :rpi0, :rpi]
  @version Path.join([__DIR__, "..", "VERSION"]) |> File.read!() |> String.trim()
  @branch System.cmd("git", ~w"rev-parse --abbrev-ref HEAD") |> elem(0) |> String.trim()
  @commit System.cmd("git", ~w"rev-parse --verify HEAD") |> elem(0) |> String.trim()
  System.put_env("NERVES_FW_VCS_IDENTIFIER", @commit)
  System.put_env("NERVES_FW_MISC", @branch)
  @elixir_version Path.join([__DIR__, "..", "ELIXIR_VERSION"]) |> File.read!() |> String.trim()

  System.put_env("NERVES_FW_VCS_IDENTIFIER", @commit)

  def project do
    [
      app: :farmbot,
      elixir: @elixir_version,
      version: @version,
      branch: @branch,
      commit: @commit,
      releases: [{:farmbot, release()}],
      elixirc_options: [warnings_as_errors: true, ignore_module_conflict: true],
      archives: [nerves_bootstrap: "~> 1.6"],
      start_permanent: Mix.env() == :prod,
      build_embedded: false,
      compilers: [:elixir_make | Mix.compilers()],
      aliases: [loadconfig: [&bootstrap/1]],
      elixirc_paths: elixirc_paths(Mix.env(), Mix.target()),
      deps_path: "deps/#{Mix.target()}",
      build_path: "_build/#{Mix.target()}",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_target: [run: :host, test: :host],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "democookie",
      include_erts: &Nerves.Release.erts/0,
      strip_beams: Mix.env() == :prod,
      steps: [&Nerves.Release.init/1, :assemble]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {FarmbotOS, []},
      extra_applications: [:logger, :runtime_tools, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Farmbot stuff
      {:farmbot_core, path: "../farmbot_core", env: Mix.env()},
      {:farmbot_ext, path: "../farmbot_ext", env: Mix.env()},

      # Configurator stuff
      {:cors_plug, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_html, "~> 2.13"},

      # Nerves stuff.
      {:nerves, "~> 1.5", runtime: false},
      {:nerves_hub_cli, "~> 0.7", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.8"},

      # Host/test only dependencies.
      {:excoveralls, "~> 0.10", only: [:test], targets: [:host]},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], targets: [:host], runtime: false},
      {:ex_doc, "~> 0.19", only: [:dev], targets: [:host], runtime: false},
      {:elixir_make, "~> 0.5", runtime: false},

      # Target only deps
      {:nerves_runtime, "~> 0.10", targets: @all_targets},
      {:nerves_time, "~> 0.2", targets: @all_targets},
      {:nerves_hub, "~> 0.7", targets: @all_targets},
      {:nerves_firmware_ssh, "~> 0.4", targets: @all_targets},
      {:circuits_gpio, "~> 0.4", targets: @all_targets},
      {:toolshed, "~> 0.2", targets: @all_targets},
      {:vintage_net, "~> 0.5", targets: @all_targets},
      {:mdns_lite, "~> 0.1.0", targets: @all_targets},
      {:busybox, "~> 0.1.2", targets: @all_targets},
      {:farmbot_system_rpi3, "1.8.0-farmbot.2", runtime: false, targets: :rpi3},
      {:farmbot_system_rpi0, "1.8.0-farmbot.0", runtime: false, targets: :rpi0},
      {:farmbot_system_rpi, "1.8.0-farmbot.0", runtime: false, targets: :rpi}
    ]
  end

  defp elixirc_paths(:test, :host) do
    ["./lib", "./platform/host", "./test/support"]
  end

  defp elixirc_paths(_, :host) do
    ["./lib", "./platform/host"]
  end

  defp elixirc_paths(_env, _target) do
    ["./lib", "./platform/target"]
  end
end
