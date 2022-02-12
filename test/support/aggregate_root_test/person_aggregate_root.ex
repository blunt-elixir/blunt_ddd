defmodule Support.AggregateRootTest.PersonAggregateRoot do
  use Cqrs.Ddd
  alias Support.AggregateRootTest.ReservationEntity
  alias Support.AggregateRootTest.Protocol.{PersonCreated, ReservationAdded}

  defaggregate do
    field :id, :binary_id
    field :reservations, {:array, ReservationEntity}, default: []
  end

  def apply(state, %PersonCreated{id: id}),
    do: set(state, :id, id)

  def apply(%{reservations: reservations} = state, %ReservationAdded{reservation_id: id}) do
    reservation = ReservationEntity.new(id: id)
    set(state, :reservations, [reservation | reservations])
  end
end
