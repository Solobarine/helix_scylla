defmodule HelixScylla.MigrationLoader do
  def load!(path) do
    path
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(&load_file!/1)
  end

  defp load_file!(path) do
    [{module, _}] = Code.require_file(path)

    version =
      path
      |> Path.basename(".exs")
      |> String.split("_", parts: 2)
      |> List.first()

    %{
      version: version,
      module: module,
      path: path
    }
  end
end
