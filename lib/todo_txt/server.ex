defmodule TodoTxt.Server do
  @moduledoc """
    GenServer that allows interaction with a Todo.txt and optionally a Done.txt file
  """

  use GenServer

  alias TodoTxt.State

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
