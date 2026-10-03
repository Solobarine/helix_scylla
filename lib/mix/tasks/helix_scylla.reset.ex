defmodule Mix.Tasks.HelixScylla.Reset do
  @shortdoc "Rolls back all ScyllaDB migrations"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    if args != [] do
      Mix.raise("""
      Usage:

          mix helix_scylla.reset
      """)
    end

    app = Mix.Project.config()[:app]
    config = HelixScylla.Config.fetch!(app)
    HelixScylla.MigrationRunner.rollback_all(config)
  end
end
