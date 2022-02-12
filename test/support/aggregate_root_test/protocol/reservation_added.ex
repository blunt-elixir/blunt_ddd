defmodule Support.AggregateRootTest.Protocol.ReservationAdded do
  use Cqrs.DomainEvent
  field :person_id, :binary_id
  field :reservation_id, :binary_id
end
