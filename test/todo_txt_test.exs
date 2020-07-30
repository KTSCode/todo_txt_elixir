defmodule TodoTxtTest do
  use ExUnit.Case
  doctest TodoTxt

  test "greets the world" do
    assert TodoTxt.hello() == :world
  end
end
