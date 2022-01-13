defmodule RclexBenchTest do
  use ExUnit.Case
  doctest RclexBench

  test "greets the world" do
    assert RclexBench.hello() == :world
  end
end
