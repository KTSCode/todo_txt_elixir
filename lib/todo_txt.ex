# TODO: think about the end user experience before writing anymore code
defmodule TodoTxt do
  @moduledoc """
  This module deals with parsing and structuring todo.txt data
  """
  defstruct todos: [%Todo{description: ""}], done_todos: [%Todo{description: "", done: true}]

  @doc """
  parse todo.txt into a struct

  ## Examples

      iex>
      :world

  """
  def hello do
    :world
  end
end
