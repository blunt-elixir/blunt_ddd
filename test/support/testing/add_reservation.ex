defmodule Support.Testing.AddReservation do
  use Cqrs.Command
  use Cqrs.Command.EventDerivation
  field :id, :binary_id

  derive_event ReservationAdded do
    field :person_id, :binary_id
  end
end
