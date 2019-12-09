defmodule GutenburgWorkerTest do
  use ExUnit.Case
  doctest Gutenburworker

  test "greets the world" do
    assert Gutenburworker.hello() == :world
  end
end
