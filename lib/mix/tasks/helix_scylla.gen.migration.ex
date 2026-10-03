defmodule Mix.Tasks.HelixScylla.Gen.Migration do
  @shortdoc "Generates a ScyllaDB migration"

  @moduledoc """
  Generates a new ScyllaDB migration.

      mix helix_scylla.gen.migration create_playback_events

  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    case args do
      [name] ->
        generate(name)

      _ ->
        Mix.raise("""
        Usage:

            mix helix_scylla.gen.migration NAME

        Example:

            mix helix_scylla.gen.migration create_playback_events
        """)
    end
  end

  defp generate(name) do
    unless Regex.match?(~r/^[a-z][a-z0-9_]*$/, name) do
      Mix.raise("Migration name must contain only lowercase letters, numbers, and underscores.")
    end

    app = Mix.Project.config()[:app]

    config = HelixScylla.Config.fetch!(app)

    migrations_path =
      config
      |> Keyword.get(:migrations_path, "priv/scylla/migrations")
      |> Path.expand()

    File.mkdir_p!(migrations_path)

    timestamp =
      DateTime.utc_now()
      |> Calendar.strftime("%Y%m%d%H%M%S")

    filename = "#{timestamp}_#{name}.exs"
    path = Path.join(migrations_path, filename)

    module_name =
      name
      |> Macro.camelize()

    app_module =
      Mix.Project.config()
      |> Keyword.fetch!(:app)
      |> Atom.to_string()
      |> Macro.camelize()

    module = "#{app_module}.ScyllaMigrations.#{module_name}"

    contents = """
    defmodule #{module} do
      use HelixScylla.Migration

      def up(connection) do
        execute!(
          HelixScylla.ExandraAdapter,
          connection,
          \"\"\"
          -- Write your CQL here
          \"\"\"
        )

        :ok
      end

      def down(connection) do
        execute!(
          HelixScylla.ExandraAdapter,
          connection,
          \"\"\"
          -- Write your rollback CQL here
          \"\"\"
        )

        :ok
      end
    end
    """

    File.write!(path, contents)

    Mix.shell().info("""
    Created ScyllaDB migration:

      #{Path.relative_to_cwd(path)}
    """)
  end
end
