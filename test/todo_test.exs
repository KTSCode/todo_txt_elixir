defmodule TodoTest do
  use ExUnit.Case
  doctest Todo

  test "to_string" do
    todo = %Todo{
      description: "This test has everything @context1 @context2 +project1 +project2",
      additional_fields: %{"key1" => "value1", "key2" => "value2"},
      done: true,
      completion_date: ~D[2020-09-13],
      priority: :A,
      contexts: [:context1, :context2],
      projects: [:project1, :project2],
      creation_date: ~D[2021-09-13],
      due_date: ~D[2021-09-13],
      pomodori: {1, 3}
    }

    expected_string =
      "x (A) 2020-09-13 2021-09-13 This test has everything @context1 @context2 +project1 +project2 due:2021-09-13 key1:value1 key2:value2 (#pomo: 1/3)"

    assert Todo.to_string(todo) == expected_string
  end

  test "parse" do
    expected_todo = %Todo{
      description: "This test has everything @context1 @context2 +project1 +project2",
      additional_fields: %{"key1" => "value1", "key2" => "value2"},
      done: true,
      completion_date: ~D[2020-09-13],
      priority: :A,
      contexts: [:context1, :context2],
      projects: [:project1, :project2],
      creation_date: ~D[2021-09-13],
      due_date: ~D[2021-09-13],
      pomodori: {1, 3}
    }

    string =
      "x (A) 2020-09-13 2021-09-13 This test has everything @context1 @context2 +project1 +project2 due:2021-09-13 key1:value1 key2:value2 (#pomo: 1/3)"

    assert Todo.parse(string) == expected_todo
  end
end
