defmodule Todo do
  @moduledoc """
    Struct and functions for operating on ToDos
  """
  import NimbleParsec

  defstruct additional_fields: %{},
            completion_date: :none,
            contexts: [],
            creation_date: :none,
            description: "",
            done: false,
            due_date: :none,
            pomodori: :none,
            priority: :none,
            projects: []

  @doc """
  converts a Todo struct into a string that would be found in a todo.txt file.

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

  @doc """
  parse parses a raw todo string into a Todo struct

  ## Examples

      iex> Todo.parse("x done")
      %Todo{description: "done", done: true}

      iex> Todo.parse("x 2020-09-13 done")
      %Todo{description: "done", done: true, completion_date: ~D[2020-09-13]}

      iex> Todo.parse("(A) top priority")
      %Todo{description: "top priority", priority: :A }

      iex> Todo.parse("todo with @Context1 and @Context_2")
      %Todo{description: "todo with @Context1 and @Context_2", contexts: [:Context1, :Context_2]}

      iex> Todo.parse("todo with +Project_1 and +project2")
      %Todo{description: "todo with +Project_1 and +project2", projects: [:Project_1, :project2]}

      iex> Todo.parse("todo 2020-10-15 with due:2021-09-13")
      %Todo{description: "todo 2020-10-15 with", due_date: ~D[2021-09-13]}

      iex> Todo.parse("2020-10-15 task due:2021-09-13")
      %Todo{description: "task", creation_date: ~D[2020-10-15], due_date: ~D[2021-09-13]}

      iex> Todo.parse("task meta:data meta1:data1")
      %Todo{description: "task", additional_fields: %{"meta" => "data", "meta1" => "data1"}}

      iex> Todo.parse("task due:2021-09-13 meta:data meta1:data1")
      %Todo{description: "task", additional_fields: %{"meta" => "data", "meta1" => "data1"}, due_date: ~D[2021-09-13]}

  """
  def parse(str) do
    case parser(str) do
      {:ok, parsed, "", _, _, _} -> Enum.reduce(parsed, %Todo{}, &set_from_parsed/2)
      {:error, message, _, _, _, _} -> message
    end
  end

  # Reusable Combinators
  ignore_spaces =
    string(" ")
    |> ignore()
    |> repeat()
    |> optional()
    |> label("Ignore spaces")

  date =
    integer(4)
    |> string("-")
    |> integer(1)
    |> integer(1)
    |> string("-")
    |> integer(1)
    |> integer(1)
    |> reduce({Enum, :join, [""]})
    |> label("Parse date")

  # Specific Combinators
  additional_fields =
    ignore_spaces
    |> ascii_string([not: ?:, not: ?\s], min: 1)
    |> ignore(string(":"))
    |> ascii_string([not: ?:, not: ?\s], min: 1)
    |> tag(:additional_fields)

  completion_date =
    ignore_spaces
    |> optional
    |> concat(date)
    |> unwrap_and_tag(:completion_date)
    |> optional

  creation_date =
    ignore_spaces
    |> concat(date)
    |> unwrap_and_tag(:creation_date)
    |> optional

  due_date =
    ignore_spaces
    |> ignore(string("due:"))
    |> concat(date)
    |> unwrap_and_tag(:due_date)

  pomodori =
    ignore_spaces
    |> ignore(string("(#pomo: "))
    |> ascii_string([?0..?9], min: 1)
    |> ignore(string("/"))
    |> ascii_string([?0..?9], min: 1)
    |> ignore(string(")"))
    |> map({String, :to_integer, []})
    |> tag(:pomodori)

  priority =
    ignore_spaces
    |> ignore(string("("))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(")"))
    |> map({String, :to_atom, []})
    |> unwrap_and_tag(:priority)
    |> optional

  done =
    replace(string("x "), true)
    |> unwrap_and_tag(:done)
    |> concat(priority)
    |> concat(completion_date)
    |> concat(creation_date)

  not_done =
    replace(empty(), false)
    |> unwrap_and_tag(:done)
    |> concat(priority)
    |> concat(creation_date)

  description =
    ignore_spaces
    |> utf8_string([not: ?\s], min: 1)
    |> lookahead_not(choice([due_date, additional_fields, pomodori, eos()]))
    |> repeat
    |> optional(ignore(string(" ")))
    |> utf8_string([not: ?\s], min: 0)
    |> reduce({Enum, :join, [" "]})
    |> unwrap_and_tag(:description)
    |> label("Description")

  rest =
    description
    |> optional(due_date)
    |> optional(repeat(additional_fields))
    |> optional(pomodori)

  defparsecp(:parser, choice([done, not_done]) |> concat(rest))

  contexts =
    ignore(string("@"))
    |> ascii_string([not: ?\s], min: 1)
    |> eventually()
    |> repeat
    |> map({String, :to_atom, []})
    |> label("Contexts")

  defparsecp(:context_parser, contexts |> optional)

  projects =
    ignore(string("+"))
    |> ascii_string([not: ?\s], min: 1)
    |> eventually()
    |> repeat
    |> map({String, :to_atom, []})
    |> label("Projects")

  defparsecp(:project_parser, projects |> optional)

  defp set_from_parsed({:additional_fields, [key, value]}, todo) do
    Map.update(todo, :additional_fields, %{key => value}, &Map.put_new(&1, key, value))
  end

  defp set_from_parsed({:completion_date, date}, todo) do
    case Date.from_iso8601(date) do
      {:ok, valid_date} -> Map.put(todo, :completion_date, valid_date)
      _ -> Map.put(todo, :completion_date, {:error, "Invalid completion date #{date}"})
    end
  end

  defp set_from_parsed({:creation_date, date}, todo) do
    case Date.from_iso8601(date) do
      {:ok, valid_date} -> Map.put(todo, :creation_date, valid_date)
      _ -> Map.put(todo, :creation_date, {:error, "Invalid creation date #{date}"})
    end
  end

  defp set_from_parsed({:description, description}, todo) do
    contexts =
      case context_parser(description) do
        {:ok, contexts, _, _, _, _} -> contexts
        {:error, message, _, _, _, _} -> {:error, message}
      end

    projects =
      case project_parser(description) do
        {:ok, projects, _, _, _, _} -> projects
        {:error, message, _, _, _, _} -> {:error, message}
      end

    Map.put(todo, :description, description)
    |> Map.put(:contexts, contexts)
    |> Map.put(:projects, projects)
  end

  defp set_from_parsed({:done, done}, todo) do
    Map.put(todo, :done, done)
  end

  defp set_from_parsed({:due_date, date}, todo) do
    case Date.from_iso8601(date) do
      {:ok, valid_date} -> Map.put(todo, :due_date, valid_date)
      _ -> Map.put(todo, :due_date, {:error, "Invalid due date #{date}"})
    end
  end

  defp set_from_parsed({:pomodori, [completed, total]}, todo) do
    Map.put(todo, :pomodori, {completed, total})
  end

  defp set_from_parsed({:priority, priority}, todo) do
    Map.put(todo, :priority, priority)
  end
end
