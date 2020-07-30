defmodule Todo do
  @moduledoc """
    Struct and functions for operating on ToDos
  """
  @enforce_keys [:description]
  defstruct done: false,
            priority: nil,
            completion_date: nil,
            creation_date: nil,
            description: nil,
            projects: [],
            contexts: [],
            due_date: nil,
            additional_fields: %{}

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
