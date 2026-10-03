defmodule HelixScylla.Adapter do
  @moduledoc """
  Behaviour implemented by database adapters used by HelixScylla.
  """

  @callback execute(connection :: term(), cql :: String.t()) ::
              :ok | {:ok, term()} | {:error, term()}

  @callback query(connection :: term(), cql :: String.t()) ::
              {:ok, term()} | {:error, term()}
end
