defmodule Mix.Tasks.HelixScylla.Migrations do
  @shortdoc "Lists ScyllaDB migrations and their status"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    if args != [] do
      Mix.raise("""
      Usage:

          mix helix_scylla.migrations
      """)
    end

    app = Mix.Project.config()[:app]
    config = HelixScylla.Config.fetch!(app)

    HelixScylla.MigrationRunner.status(config)
  end
end
