defmodule TodoTxt do
  @moduledoc """
  This module deals with parsing and structuring todo.txt data
  """
  defstruct todos: [%Todo{description: ""}], done_todos: [%Todo{description: "", done: true}]

  @doc """
  parse_todo_txt parses a list of raw todo strings from a todo file into a

  ## Examples

      iex> TodoTxt.parse_todo_txt(["x done", "todo"])
      %TodoTxt{todos: [%Todo{description: "todo", done: false}],
        done_todos: [%Todo{description: "done", done: true}]}
  """
  def parse_todo_txt(list_of_todos) do
    {done, undone} =
      list_of_todos
      |> Enum.map(&parse_todo/1)
      |> Enum.split_with(& &1.done)

    %TodoTxt{todos: undone, done_todos: done}
  end

  @doc """
  parse_todo parses a raw todo string into a Todo struct

  ## Examples

      iex> TodoTxt.parse_todo("x done")
      %Todo{description: "done", done: true}

      iex> TodoTxt.parse_todo("x 2020-09-13 done")
      %Todo{description: "done", done: true, completion_date: ~D[2020-09-13]}

      iex> TodoTxt.parse_todo("(A) top priority")
      %Todo{description: "top priority", priority: :A }

      iex> TodoTxt.parse_todo("todo with @Context1 and @Context_2")
      %Todo{description: "todo with @Context1 and @Context_2", contexts: [:Context1, :Context_2]}

      iex> TodoTxt.parse_todo("todo with +Project_1 and +project2")
      %Todo{description: "todo with +Project_1 and +project2", projects: [:Project_1, :project2]}

      iex> TodoTxt.parse_todo("todo 2020-10-15 with due: 2021-09-13")
      %Todo{description: "todo 2020-10-15 with", due_date: ~D[2021-09-13]}

      iex> TodoTxt.parse_todo("2020-10-15 task due: 2021-09-13")
      %Todo{description: "task", creation_date: ~D[2020-10-15], due_date: ~D[2021-09-13]}

      iex> TodoTxt.parse_todo("task pomo: (10/5) due: 2021-09-13 meta: data")
      %Todo{description: "task", additional_fields: %{"meta" => "data", "pomo" => "(10/5)"}, due_date: ~D[2021-09-13]}

  """
  def parse_todo(todo_string) do
    {done_bool, completion_date, undone_todo_string} = done_task_check(todo_string)
    {creation_date, creation_dateless_todo_string} = creation_date_check(undone_todo_string)
    {priority, deprioritized_todo_string} = priority_task_check(creation_dateless_todo_string)
    {due_date, dueless_todo_string} = due_task_check(deprioritized_todo_string)
    {additional_fields, description} = additional_fields_check(dueless_todo_string)

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

  defp additional_fields_check(todo_string, additional_fields \\ %{}) do
    regex = ~r/\S*: \S*$/
    trimmed_todo = String.trim(todo_string)

    if Regex.match?(regex, trimmed_todo) do
      [todo | add_fields_string] =
        regex |> Regex.split(trimmed_todo, include_captures: true, trim: true)

      [key | value_array] = String.split(List.last(add_fields_string), ":")
      value = value_array |> List.to_string() |> String.trim()
      additional_fields_check(todo, Map.put(additional_fields, key, value))
    else
      {additional_fields, String.trim(todo_string)}
    end
  end

  defp creation_date_check(todo_string) do
    %{date: date, todo: todo} = date_extracter(~r/^\d{4}-\d{2}-\d{2}\s/, todo_string)
    {date, todo}
  end

  defp due_task_check(todo_string) do
    %{date: date, todo: todo} = date_extracter(~r/\sdue: \d{4}-\d{2}-\d{2}/, todo_string)
    {date, todo}
  end

  defp get_contexts(todo_string) do
    ~r/\s\@\S*/
    |> Regex.scan(todo_string)
    |> List.flatten()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.trim(&1, "@"))
    |> Enum.map(&String.to_atom/1)
  end

  defp get_projects(todo_string) do
    ~r/\s\+\S*/
    |> Regex.scan(todo_string)
    |> List.flatten()
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.trim(&1, "+"))
    |> Enum.map(&String.to_atom/1)
  end

  defp priority_task_check(todo_string) do
    priority_parsed =
      ~r/\([A-Z]\)/
      |> Regex.split(todo_string, include_captures: true, trim: true)

    if Regex.match?(~r/\([A-Z]\)/, List.first(priority_parsed)) do
      [priority | deprioritized] = priority_parsed

      {String.to_atom(List.first(Regex.run(~r/[A-Z]/, priority))),
       String.trim(Enum.join(deprioritized, ""))}
    else
      {:none, todo_string}
    end
  end

  defp done_task_check(todo_string) do
    case todo_string do
      "x " <> clean_todo_string ->
        %{date: date, todo: todo} = date_extracter(~r/^\d{4}-\d{2}-\d{2}\s/, clean_todo_string)
        {true, date, todo}

      clean_todo_string ->
        {false, :none, clean_todo_string}
    end
  end

  @doc """
  helper function that takes regex and a string, then uses the regex to find a pattern in the string and extract a date from it

  ## Examples

      iex> TodoTxt.date_extracter(~r/\\sdue: \\d{4}-\\d{2}-\\d{2}\/, "Give speech due: 1963-08-28")
      %{date: ~D[1963-08-28], todo: "Give speech"}

      iex> TodoTxt.date_extracter(~r/^\\d{4}-\\d{2}-\\d{2}\\s/, "1963-08-28 Give speech")
      %{date: ~D[1963-08-28], todo: "Give speech"}

      iex> TodoTxt.date_extracter(~r/^\\d{4}-\\d{2}-\\d{2}\\s/, "1963-08-28 Give speech, save the date: 1964-10-14")
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
