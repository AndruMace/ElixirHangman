defmodule ComputerTest do
  use ExUnit.Case
  doctest Computer

  test "starts" do
    assert Computer.start() == :okie
  end
end
