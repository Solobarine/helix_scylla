defmodule Mix.Tasks.HelixScylla.Rollback do
  @shortdoc "Rolls back ScyllaDB migrations"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, remaining, _invalid} =
      OptionParser.parse(args,
        switches: [
          step: :integer,
          all: :boolean
        ]
      )

    if remaining != [] do
      Mix.raise("Unknown arguments: #{Enum.join(remaining, " ")}")
    end

    app = Mix.Project.config()[:app]
    config = HelixScylla.Config.fetch!(app)

    cond do
      opts[:all] ->
        HelixScylla.MigrationRunner.rollback_all(config)

      opts[:step] ->
        HelixScylla.MigrationRunner.rollback(config, opts[:step])

      true ->
        HelixScylla.MigrationRunner.rollback(config, 1)
    end
  end
end
