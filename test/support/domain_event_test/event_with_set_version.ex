defmodule Support.DomainEventTest.EventWithSetVersion do
  use Cqrs.DomainEvent

  @version 2

  field(:user, :string)
end
