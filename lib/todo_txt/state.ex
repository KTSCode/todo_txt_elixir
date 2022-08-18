defmodule TodoTxt.State do
  alias TodoTxt.State

  defstruct todo_txt_file_path: "#{System.get_env("TODO_DIR")}/todo.txt",
            done_txt_file_path: "#{System.get_env("TODO_DIR")}/done.txt",
            file_location: :local,
            options: [],
            todos: [],
            history: :none

  def new(state = %State{}) do
    load_todos(state)
  end

  defp validate(state) do
    %State{
      todo_txt_file_path: todo_txt_file_path,
      done_txt_file_path: done_txt_file_path,
      file_location: file_location
    } = state

    case file_location do
      :local ->
        cond do
          !File.exists?(todo_txt_file_path) ->
            {:error, "File #{todo_txt_file_path} does not exist"}

          done_txt_file_path != :none && !File.exists?(done_txt_file_path) ->
            {:error, "File #{done_txt_file_path} does not exist"}

          true ->
            {:ok, state}
        end

      invalid_location ->
        {:error, "#{invalid_location} is not a valid file_location"}
    end
  end

  def load_todos(state) do
    {:ok, %State{todo_txt_file_path: todo_txt_file_path}} = validate(state)

    todos =
      todo_txt_file_path
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&Todo.parse/1)

    Map.put(state, :todos, todos)
  end
end
