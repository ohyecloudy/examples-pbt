defmodule ExamplesPbtTest do
  use ExUnit.Case
  doctest ExamplesPbt

  test "greets the world" do
    assert ExamplesPbt.hello() == :world
  end
end
