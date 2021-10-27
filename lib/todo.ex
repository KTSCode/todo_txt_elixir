defmodule Todo do
  @moduledoc """
    Struct and functions for operating on ToDos
  """

  @enforce_keys [:description]
  defstruct done: false,
            priority: :none,
            completion_date: :none,
            creation_date: :none,
            description: nil,
            projects: [],
            contexts: [],
            due_date: :none,
            additional_fields: %{}

  @doc """
  converts a Todo struct into a string that would be found in a todo.txt file.
  The inverse of the parse_todo function

  ## Examples
      iex> Todo.to_string(%Todo{description: "done", done: true})
      "x done"

      iex> Todo.to_string(%Todo{description: "done", done: true, completion_date: ~D[2020-09-13]})
      "x 2020-09-13 done"

      iex> Todo.to_string(%Todo{description: "top priority", priority: :A })
      "(A) top priority"


  """
  def to_string(todo) do
    %{description: description, done: done, completion_date: completion_date, priority: priority} =
      todo

    description
    |> todo_completion_date_to_string(completion_date)
    |> (fn str -> if done, do: "x #{str}", else: str end).()
    |> (fn str -> if priority == :none, do: str, else: "(#{priority}) #{str}" end).()
  end

  defp todo_completion_date_to_string(str, completion_date) do
    case completion_date do
      %Date{} -> "#{completion_date} #{str}"
      :none -> str
      _ -> str
    end
  end
end
