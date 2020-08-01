# TODO: think about the end user experience before writing anymore code
defmodule TodoTxt do
  @moduledoc """
  This module deals with parsing and structuring todo.txt data
  """
  defstruct todos: [%Todo{description: ""}], done_todos: [%Todo{description: "", done: true}]

  @doc """
  parse todo.txt into a struct

  ## Examples

      iex> TodoTxt.parse(["x done", "todo"])
      %TodoTxt{todos: [%Todo{description: "", done: false}], done_todos: [%Todo{description: "", done: true}]}

  """
  def parse(input) do
    input.map(&parse_helper/1)
  end

  defp parse_helper(todo_string) do
    case todo_string do
      "x " <> description ->
        %Todo{description: description, done: true}

      description ->
        %Todo{description: description, done: false}
        model
    end
  end
end
