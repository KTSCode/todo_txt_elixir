defmodule Todo do
  @moduledoc """
    Struct and functions for operating on ToDos
  """
  @enforce_keys [:description]
  defstruct done: false,
            priority: :none,
            completion_date: nil,
            creation_date: nil,
            description: nil,
            projects: [],
            contexts: [],
            due_date: nil,
            additional_fields: %{}
end
