defmodule CommandToTestDerivation do
  use Cqrs.Command

  field :id, :binary_id
  field :name, :string
end

defmodule Support.DomainEventTest.EventDerivedFromCommand do
  use Cqrs.DomainEvent, derive_from: CommandToTestDerivation
end

defmodule Support.DomainEventTest.EventDerivedFromCommandWithDrop do
  use Cqrs.DomainEvent, derive_from: CommandToTestDerivation, drop: :name
end
