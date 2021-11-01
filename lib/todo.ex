defmodule Todo do
  @moduledoc """
    Struct and functions for operating on ToDos
  """

  @enforce_keys [:description]
  defstruct additional_fields: %{},
            completion_date: :none,
            contexts: [],
            creation_date: :none,
            description: nil,
            done: false,
            due_date: :none,
            pomodori: :none,
            priority: :none,
            projects: []

  @doc """
  converts a Todo struct into a string that would be found in a todo.txt file.
  The inverse of the parse_todo function

  ## Examples
      iex> Todo.to_string(%Todo{description: "done", done: true})
      "x done"

      iex> Todo.to_string(%Todo{description: "done on time", done: true, completion_date: ~D[2020-09-13]})
      "x 2020-09-13 done on time"

      iex> Todo.to_string(%Todo{description: "top priority", priority: :A })
      "(A) top priority"

      iex> Todo.to_string(%Todo{description: "context task: @context1", contexts: [:context1, :context2] })
      "context task: @context1 @context2"

      iex> Todo.to_string(%Todo{description: "project task: +project1", projects: [:project1, :project2] })
      "project task: +project1 +project2"

      iex> Todo.to_string(%Todo{description: "created on time", creation_date: ~D[2021-09-13]})
      "2021-09-13 created on time"

      iex> Todo.to_string(%Todo{description: "done on time", done: true, completion_date: ~D[2020-09-13], creation_date: ~D[2020-09-12]})
      "x 2020-09-13 2020-09-12 done on time"

      iex> Todo.to_string(%Todo{description: "due on time", due_date: ~D[2021-09-13]})
      "due on time due:2021-09-13"

      iex> Todo.to_string(%Todo{description: "additional fields task", additional_fields: %{"key1" => "value1", "key2" => "value2"}})
      "additional fields task key1:value1 key2:value2"

      iex> Todo.to_string(%Todo{description: "pomodoro task", pomodori: {1, 3}})
      "pomodoro task (#pomo: 1/3)"

  """
  def to_string(todo) do
    %Todo{
      additional_fields: additional_fields,
      completion_date: completion_date,
      contexts: contexts,
      creation_date: creation_date,
      description: description,
      done: done,
      due_date: due_date,
      pomodori: pomodori,
      priority: priority,
      projects: projects
    } = todo

    description
    |> todo_date_to_string(creation_date)
    |> todo_date_to_string(completion_date)
    |> (fn str -> if priority == :none, do: str, else: "(#{priority}) #{str}" end).()
    |> (fn str -> if done, do: "x #{str}", else: str end).()
    |> add_atom_list("@", contexts)
    |> add_atom_list("+", projects)
    |> todo_due_date_to_string(due_date)
    |> append_additional_fields(additional_fields)
    |> add_pomo(pomodori)
  end

  defp add_pomo(str, :none), do: str

  defp add_pomo(str, {completed, total}) do
    "#{str} (#pomo: #{completed}/#{total})"
  end

  defp add_atom_list(str, _, []), do: str

  defp add_atom_list(str, prefix, atom_list) do
    prefixed_string_list = Enum.map(atom_list, &(prefix <> Atom.to_string(&1)))
    Enum.reduce(prefixed_string_list, str, &append_unless_contains/2)
  end

  defp append_unless_contains(string_to_append, output_string) do
    if String.contains?(output_string, string_to_append) do
      output_string
    else
      output_string <> " " <> string_to_append
    end
  end

  defp todo_date_to_string(str, date) do
    case date do
      %Date{} -> "#{date} #{str}"
      :none -> str
      _ -> str
    end
  end

  defp todo_due_date_to_string(str, date) do
    case date do
      %Date{} -> "#{str} due:#{date}"
      :none -> str
      _ -> str
    end
  end

  defp append_additional_fields(str, additional_fields) do
    field_to_string = fn {key, value}, acc -> "#{acc} #{key}:#{value}" end
    Enum.reduce(additional_fields, str, field_to_string)
  end
end
