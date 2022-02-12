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
