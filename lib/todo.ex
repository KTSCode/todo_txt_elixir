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
end
