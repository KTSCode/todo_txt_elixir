defmodule TodoTxt.Application do
  @moduledoc false

  use Application

  def start(_type, args) do
    # Set default paths if none are passed
    todo_txt_file_path = get_in(args, [Access.key(:todo_txt_file_path, "$TODO_DIR/todo.txt")])
    done_txt_file_path = get_in(args, [Access.key(:done_txt_file_path, "$TODO_DIR/done.txt")])

    children = [
      {TodoTxt.Server,
       todo_txt_file_path: todo_txt_file_path, done_txt_file_path: done_txt_file_path}
      # TODO: Add file_system watcher here
    ]

    opts = [strategy: :one_for_one, name: VaporExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
