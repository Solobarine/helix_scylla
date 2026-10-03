defmodule HelixScylla.MigrationStore do
  @table "scylla_schema_migrations"

  def ensure_table!(adapter, connection, keyspace) do
    adapter.execute(
      connection,
      """
      CREATE TABLE IF NOT EXISTS #{keyspace}.#{@table} (
        version text PRIMARY KEY,
        inserted_at timestamp
      )
      """
    )
    |> unwrap!()
  end

  def all(adapter, connection, keyspace) do
    case adapter.execute(
           connection,
           "SELECT version FROM #{keyspace}.#{@table}"
         ) do
      {:ok, %{rows: rows}} ->
        Enum.map(rows, fn
          [version] -> version
          %{version: version} -> version
        end)

      {:error, reason} ->
        raise "Unable to read Scylla migration state: #{inspect(reason)}"
    end
  end

  def insert!(adapter, connection, keyspace, version) do
    adapter.execute(
      connection,
      """
      INSERT INTO #{keyspace}.#{@table} (version, inserted_at)
      VALUES ('#{version}', toTimestamp(now()))
      """
    )
    |> unwrap!()
  end

  def delete!(adapter, connection, keyspace, version) do
    adapter.execute(
      connection,
      """
      DELETE FROM #{keyspace}.#{@table}
      WHERE version = '#{version}'
      """
    )
    |> unwrap!()
  end

  defp unwrap!(:ok), do: :ok
  defp unwrap!({:ok, _}), do: :ok

  defp unwrap!({:error, reason}) do
    raise "Scylla migration metadata operation failed: #{inspect(reason)}"
  end
end
