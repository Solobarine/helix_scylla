defmodule HelixScylla.XandraAdapter do
  @behaviour HelixScylla.Adapter

  @impl true
  def execute(connection, cql) do
    Xandra.execute(connection, cql)
  end

  @impl true
  def query(connection, cql) do
    Xandra.execute(connection, cql)
  end
end
