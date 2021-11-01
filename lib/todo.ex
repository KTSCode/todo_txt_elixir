defmodule Todo do
  @moduledoc """
    Struct and functions for operating on ToDos
  """
  import NimbleParsec

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

  @doc """
  TODO: Switch to using NimbleParsec to parse todo strings
  parse_todo parses a raw todo string into a Todo struct

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

      iex> Todo.parse("task due:2021-09-13 meta:data")
      %Todo{description: "task", additional_fields: %{"meta" => "data"}, due_date: ~D[2021-09-13]}

      iex> Todo.parse_done("x (A) 2020-09-01 2020-09-02 this is a test due:2021-10-31")
      {:ok, [done: true]}

  """
  date =
    integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)
    |> reduce({Enum, :join, ["-"]})

  priority =
    ignore(string(" "))
    |> optional
    |> ignore(string("("))
    |> ascii_string([?A..?Z], 1)
    |> ignore(string(")"))
    |> map({String, :to_atom, []})
    |> unwrap_and_tag(:priority)
    |> optional

  completion_date =
    ignore(string(" "))
    |> optional
    |> concat(date)
    |> unwrap_and_tag(:completion_date)
    |> optional

  creation_date =
    optional(ignore(string(" ")))
    |> concat(date)
    |> unwrap_and_tag(:creation_date)
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

  due_date =
    ignore(string(" "))
    |> ignore(string("due:"))
    |> concat(date)
    |> unwrap_and_tag(:due_date)

  description =
    string(" ")
    |> ignore
    |> optional
    |> utf8_string([not: ?\s], min: 1)
    # TODO add other metadata parsers
    |> lookahead_not(due_date)
    |> repeat
    |> optional(ignore(string(" ")))
    |> utf8_string([not: ?\s], min: 0)
    |> reduce({Enum, :join, [" "]})
    |> unwrap_and_tag(:description)

  rest = description |> optional(due_date)

  # TODO: post process context and projects 
  defparsec(
    :parse_done,
    choice([done, not_done])
    |> concat(rest)
  )

  def parse(str) do
    {done_bool, completion_date, undone_str} = done_task_check(str)
    {creation_date, creation_dateless_str} = creation_date_check(undone_str)
    {priority, deprioritized_str} = priority_task_check(creation_dateless_str)
    {due_date, dueless_str} = due_task_check(deprioritized_str)
    {additional_fields, description} = additional_fields_check(dueless_str)

    %Todo{
      additional_fields: additional_fields,
      completion_date: completion_date,
      contexts: get_contexts(description),
      creation_date: creation_date,
      description: description,
      done: done_bool,
      due_date: due_date,
      priority: priority,
      projects: get_projects(description)
    }
  end

  defp additional_fields_check(str, additional_fields \\ %{}) do
    regex = ~r/\S*:\S*/
    trimmed_todo = String.trim(str)

    if Regex.match?(regex, trimmed_todo) do
      [todo | add_fields_string] =
        regex |> Regex.split(trimmed_todo, include_captures: true, trim: true)

      [key | value_array] = String.split(List.last(add_fields_string), ":")
      value = value_array |> List.to_string() |> String.trim()
      additional_fields_check(todo, Map.put(additional_fields, key, value))
    else
      {additional_fields, String.trim(str)}
    end
  end

  defp creation_date_check(str) do
    %{date: date, todo: todo} = date_extracter(~r/^\d{4}-\d{2}-\d{2}\s/, str)
    {date, todo}
  end

  defp due_task_check(str) do
    %{date: date, todo: todo} = date_extracter(~r/\sdue:\d{4}-\d{2}-\d{2}/, str)
    {date, todo}
  end

  defp get_contexts(str) do
    ~r/\s\@\S*/
    |> Regex.scan(str)
    |> List.flatten()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.trim(&1, "@"))
    |> Enum.map(&String.to_atom/1)
  end

  defp get_projects(str) do
    ~r/\s\+\S*/
    |> Regex.scan(str)
    |> List.flatten()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.trim(&1, "+"))
    |> Enum.map(&String.to_atom/1)
  end

  defp priority_task_check(str) do
    priority_parsed =
      ~r/\([A-Z]\)/
      |> Regex.split(str, include_captures: true, trim: true)

    if Regex.match?(~r/\([A-Z]\)/, List.first(priority_parsed)) do
      [priority | deprioritized] = priority_parsed

      {String.to_atom(List.first(Regex.run(~r/[A-Z]/, priority))),
       String.trim(Enum.join(deprioritized, ""))}
    else
      {:none, str}
    end
  end

  defp done_task_check(str) do
    case str do
      "x " <> clean_str ->
        %{date: date, todo: todo} = date_extracter(~r/^\d{4}-\d{2}-\d{2}\s/, clean_str)
        {true, date, todo}

      clean_str ->
        {false, :none, clean_str}
    end
  end

  @doc """
  helper function that takes regex and a string, then uses the regex to find a pattern in the string and extract a date from it

  ## Examples

      iex> Todo.date_extracter(~r/\\sdue: \\d{4}-\\d{2}-\\d{2}\/, "Give speech due: 1963-08-28")
      %{date: ~D[1963-08-28], todo: "Give speech"}

      iex> Todo.date_extracter(~r/^\\d{4}-\\d{2}-\\d{2}\\s/, "1963-08-28 Give speech")
      %{date: ~D[1963-08-28], todo: "Give speech"}

      iex> Todo.date_extracter(~r/^\\d{4}-\\d{2}-\\d{2}\\s/, "1963-08-28 Give speech, save the date: 1964-10-14")
      %{date: ~D[1963-08-28], todo: "Give speech, save the date: 1964-10-14"}

  """

  def date_extracter(regex, todo_string_with_date) do
    split = Regex.split(regex, todo_string_with_date, include_captures: true, trim: true)

    date =
      split
      |> Enum.reject(&(!Regex.match?(regex, &1)))
      |> List.to_string()
      |> (fn string -> Regex.scan(~r/\d{4}-\d{2}-\d{2}/, string) end).()
      |> List.to_string()

    todo = split |> Enum.reject(&Regex.match?(regex, &1)) |> List.to_string()

    case Date.from_iso8601(date) do
      {:ok, valid_date} -> %{date: valid_date, todo: todo}
      _ -> %{date: :none, todo: todo_string_with_date}
    end
  end
end
