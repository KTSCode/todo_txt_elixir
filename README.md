# TodoTxt
[Online Documentation](https://hexdocs.pm/todo_txt/Todo.html).

`TodoTxt` An Elixir library for parseing todo.txt files

## About Todo.txt
More information about todo.txt can be found at:
  - [Overview](https://github.com/todotxt/todo.txt)
  - [Homepage](http://todotxt.org/)
  - [cli](https://github.com/todotxt/todo.txt-cli)

## Installation

This package can be installed
by adding `todo_txt` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:todo_txt, "~> 0.1.0"}
  ]
end
```

## Basic Usage

### Read Todos From todo.txt File

```elixir
todos = 
  File.read!("todo.txt") 
  |> String.split("\n") 
  |> Enum.map(&Todo.parse/1)
```

### Write Todos To todo.txt File

```elixir
to_write = 
  todos 
  |> Enum.map(&Todo.to_string/1) 
  |> Enum.join("\n")

File.write!("todo.txt.diff", to_write)
```

### Remove Done Todos From todo.txt And Archive Them In done.txt File
```elixir
todos = File.read!("todo.txt") |> String.split("\n") |> Enum.map(&Todo.parse/1)
{done, todo} = Enum.split_with(todos, fn t -> t.done end)

File.write!("todo.txt", Enum.join(Enum.map(todo, &Todo.to_string/1), "\n"))
File.write!("done.txt", Enum.join(Enum.map(done, &Todo.to_string/1), "\n"))
```

## Roadmap
- Add a File Watcher for Local todo.txt
- Add a File Watcher for Google Drive todo.txt
