defmodule Support.DomainEventTest.EventWithDecimalVersion do
  use Cqrs.DomainEvent

  @version 2.3

  field(:user, :string)
end
