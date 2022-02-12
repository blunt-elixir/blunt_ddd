defmodule Support.DomainEventTest.DefaultEvent do
  use Cqrs.DomainEvent
  field(:user, :string)
end
