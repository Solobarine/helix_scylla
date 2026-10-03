defmodule HelixScylla.Config do
  def fetch!(app) do
    case Application.fetch_env(app, :helix_scylla) do
      {:ok, config} ->
        config

      :error ->
        raise """
        Missing :scylla configuration for #{app}
        """
    end
  end
end
