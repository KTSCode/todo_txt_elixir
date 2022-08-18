defmodule TodoTxt.ServerTest do
  use ExUnit.Case
  doctest TodoTxt.Server

  describe "start_link/1" do
    test "accepts a TodoTxt.State on start" do
      assert {:ok, _pid} = TodoTxt.Server.start_link(%TodoTxt.State{})
    end
  end
end
