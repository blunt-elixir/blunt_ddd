defmodule Cqrs.Command.EventDerivationTest do
  use ExUnit.Case, async: true

  alias Cqrs.CommandTest.Events.NamespacedEventWithExtrasAndDrops

  alias Support.Command.EventDerivationTest.{
    CommandWithEventDerivations,
    DefaultEvent,
    EventWithExtras,
    EventWithDrops,
    EventWithExtrasAndDrops
  }

  test "event structs are created" do
    %{} = %DefaultEvent{}
    %{} = %EventWithExtras{}
    %{} = %EventWithExtrasAndDrops{}
    %{} = %NamespacedEventWithExtrasAndDrops{}
  end

  describe "proxy functions" do
    test "are created on the command" do
      funcs = CommandWithEventDerivations.__info__(:functions)
      assert [1, 2] = Keyword.get_values(funcs, :event_with_drops)
      assert [1, 2] = Keyword.get_values(funcs, :event_with_extras)
      assert [1, 2] = Keyword.get_values(funcs, :event_with_extras_and_drops)
      assert [1, 2] = Keyword.get_values(funcs, :namespaced_event_with_extras_and_drops)
      CommandWithEventDerivations.event_with_drops()
    end

    test "invocation" do
      assert %EventWithExtras{dog: "jake", name: "chris"} =
               %{name: "chris"}
               |> CommandWithEventDerivations.new()
               |> CommandWithEventDerivations.event_with_extras(dog: "jake")
    end
  end

  test "are created and returned from pipeline" do
    {:ok, events} =
      %{name: "chris"}
      |> CommandWithEventDerivations.new()
      |> CommandWithEventDerivations.dispatch()

    today = Date.utc_today()

    assert %{
             default_event: %DefaultEvent{dog: "maize", name: "chris"},
             event_with_drops: %EventWithDrops{name: "chris"},
             event_with_extras: %EventWithExtras{dog: "maize", name: "chris", date: ^today},
             event_with_extras_and_drops: %EventWithExtrasAndDrops{name: "chris", date: ^today},
             namespaced_event_with_extras_and_drops: %NamespacedEventWithExtrasAndDrops{name: "chris", date: ^today}
           } = events
  end
end
