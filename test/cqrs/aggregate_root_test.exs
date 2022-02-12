defmodule Cqrs.AggregateRootTest do
  use ExUnit.Case, async: true

  alias Support.AggregateRootTest.PersonAggregateRoot
  alias Support.AggregateRootTest.Protocol.{PersonCreated, ReservationAdded}

  test "initial aggregate state" do
    assert %{id: nil} = %PersonAggregateRoot{}
  end

  test "create person" do
    id = UUID.uuid4()

    event = PersonCreated.new(id: id, name: "chris")

    assert %{id: ^id, reservations: []} =
             %PersonAggregateRoot{}
             |> PersonAggregateRoot.apply(event)
  end

  test "add reservation" do
    person_id = UUID.uuid4()
    reservation_id = UUID.uuid4()

    events = [
      PersonCreated.new(id: person_id, name: "chris"),
      ReservationAdded.new(person_id: person_id, reservation_id: reservation_id)
    ]

    state = %PersonAggregateRoot{}

    assert %{id: ^person_id, reservations: [%{id: ^reservation_id}]} =
             Enum.reduce(events, state, &PersonAggregateRoot.apply(&2, &1))
  end
end
