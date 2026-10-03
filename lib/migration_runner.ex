defmodule HelixScylla.MigrationRunner do
  alias HelixScylla.MigrationLoader
  alias HelixScylla.MigrationStore

  def status(config) do
    connection = Keyword.fetch!(config, :connection)
    adapter = Keyword.get(config, :adapter, HelixScylla.XandraAdapter)
    migrations_path = Keyword.fetch!(config, :migrations_path)
    keyspace = Keyword.fetch!(config, :keyspace)

    MigrationStore.ensure_table!(
      adapter,
      connection,
      keyspace
    )

    applied =
      MigrationStore.all(
        adapter,
        connection,
        keyspace
      )
      |> MapSet.new()

    MigrationLoader.load!(migrations_path)
    |> Enum.map(fn migration ->
      status =
        if MapSet.member?(applied, migration.version) do
          :up
        else
          :down
        end

      %{
        version: migration.version,
        module: migration.module,
        status: status
      }
    end)
  end

  def migrate(config) do
    connection = Keyword.fetch!(config, :connection)
    adapter = Keyword.get(config, :adapter, HelixScylla.XandraAdapter)
    migrations_path = Keyword.fetch!(config, :migrations_path)
    keyspace = Keyword.fetch!(config, :keyspace)

    MigrationStore.ensure_table!(
      adapter,
      connection,
      keyspace
    )

    applied =
      MigrationStore.all(
        adapter,
        connection,
        keyspace
      )
      |> MapSet.new()

    MigrationLoader.load!(migrations_path)
    |> Enum.reject(fn migration ->
      MapSet.member?(applied, migration.version)
    end)
    |> Enum.each(fn migration ->
      run_up!(
        migration,
        adapter,
        connection,
        keyspace
      )
    end)

    :ok
  end

  def rollback(config, step \\ 1) do
    connection = Keyword.fetch!(config, :connection)
    adapter = Keyword.get(config, :adapter, HelixScylla.XandraAdapter)
    migrations_path = Keyword.fetch!(config, :migrations_path)
    keyspace = Keyword.fetch!(config, :keyspace)

    MigrationStore.ensure_table!(
      adapter,
      connection,
      keyspace
    )

    applied =
      MigrationStore.all(
        adapter,
        connection,
        keyspace
      )
      |> MapSet.new()

    migrations =
      MigrationLoader.load!(migrations_path)
      |> Enum.reverse()
      |> Enum.filter(&MapSet.member?(applied, &1.version))
      |> Enum.take(step)

    Enum.each(migrations, fn migration ->
      run_down!(
        migration,
        adapter,
        connection,
        keyspace
      )
    end)

    :ok
  end

  def rollback_all(config) do
    connection = Keyword.fetch!(config, :connection)
    adapter = Keyword.get(config, :adapter, HelixScylla.XandraAdapter)
    migration_path = Keyword.fetch!(config, :migrations_path)
    keyspace = Keyword.fetch!(config, :keyspace)

    MigrationStore.ensure_table!(
      adapter,
      connection,
      keyspace
    )

    applied =
      MigrationStore.all(
        adapter,
        connection,
        keyspace
      )
      |> MapSet.new()

    migrations =
      MigrationLoader.load!(migration_path)
      |> Enum.reverse()
      |> Enum.filter(&MapSet.member?(applied, &1.version))

    Enum.each(migrations, fn migration ->
      run_down!(
        migration,
        adapter,
        connection,
        keyspace
      )
    end)

    :ok
  end

  defp run_up!(migration, adapter, connection, keyspace) do
    IO.puts("==> Running #{migration.version}")

    case migration.module.up(connection) do
      :ok ->
        MigrationStore.insert!(
          adapter,
          connection,
          keyspace,
          migration.version
        )

      {:ok, _} ->
        MigrationStore.insert!(
          adapter,
          connection,
          keyspace,
          migration.version
        )

      {:error, reason} ->
        raise "Migration #{migration.version} failed: #{inspect(reason)}"

      other ->
        raise "Migration #{migration.version} returned #{inspect(other)}"
    end
  end

  defp run_down!(migration, adapter, connection, keyspace) do
    IO.puts("<== Rolling back #{migration.version}")

    case migration.module.down(connection) do
      :ok ->
        MigrationStore.delete!(
          adapter,
          connection,
          keyspace,
          migration.version
        )

      {:ok, _} ->
        MigrationStore.delete!(
          adapter,
          connection,
          keyspace,
          migration.version
        )

      {:error, reason} ->
        raise "Rollback #{migration.version} failed: #{inspect(reason)}"

      other ->
        raise "Rollback #{migration.version} returned #{inspect(other)}"
    end
  end
end
