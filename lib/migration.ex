defmodule HelixScylla.Migration do
  @moduledoc """
  Base module for ScyllaDB migrations.
  """

  @callback up(connection :: term()) ::
              :ok | {:ok, term()} | {:error, term()}

  @callback down(connection :: term()) ::
              :ok | {:ok, term()} | {:error, term()}

  defmacro __using__(_opts) do
    quote do
      @behaviour HelixScylla.Migration

      import HelixScylla.Migration
    end
  end

  def execute!(adapter, connection, cql) do
    case adapter.execute(connection, cql) do
      {:ok, result} ->
        result

      :ok ->
        :ok

      {:error, reason} ->
        raise HelixScylla.MigrationError,
          message: """
          Scylla migration query failed.

          Query:
          #{cql}

          Reason:
          #{inspect(reason)}
          """
    end
  end
end
