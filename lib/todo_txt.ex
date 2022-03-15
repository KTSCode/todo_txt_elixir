defmodule TodoTxt do
  @moduledoc """
    GenServer that allows interaction with a Todo.txt and optionally a Done.txt file
  """
  defmodule State do
    @enforce_keys [:todo_txt_file_path]

    defstruct todo_txt_file_path: :none,
              done_txt_file_path: :none,
              options: [],
              todos: [],
              history: :none

    def new(input), do: load_todos(struct(State, input))

    defp validate(state) do
      %State{todo_txt_file_path: todo_txt_file_path, done_txt_file_path: done_txt_file_path} =
        state

      cond do
        !File.exists?(todo_txt_file_path) ->
          {:error, "File #{todo_txt_file_path} does not exist"}

        done_txt_file_path != :none && !File.exists?(done_txt_file_path) ->
          {:error, "File #{done_txt_file_path} does not exist"}

        true ->
          {:ok, state}
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

  use GenServer

  def start_link(args), do: GenServer.start_link(__MODULE__, State.new(args), name: __MODULE__)

  def todos do
    GenServer.call(__MODULE__, :todos)
  end

  @impl true
  def init(state), do: {:ok, state}
  # TODO: Add file watcher

  @impl true
  def handle_call(:todos, _from, %State{} = state) do
    reloaded_state = State.load_todos(state)
    {:reply, Map.get(reloaded_state, :todos), reloaded_state}
  end
end
