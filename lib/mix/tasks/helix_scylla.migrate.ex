defmodule Mix.Tasks.HelixScylla.Migrate do
  @shortdoc "Runs pending ScyllaDB migrations"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    if args != [] do
      Mix.raise("""
      Usage:

          mix helix_scylla.migrate
      """)
    end

    HelixScylla.MigrationRunner.migrate(args)
  end
end
