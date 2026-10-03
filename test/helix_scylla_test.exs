defmodule HelixScyllaTest do
  use ExUnit.Case
  doctest HelixScylla

  test "greets the world" do
    assert HelixScylla.hello() == :world
  end
end
