defmodule Support.AggregateRootTest.Protocol.PersonCreated do
  use Cqrs.DomainEvent, require_all_fields?: true

  field :id, :binary_id
  field :name, :string
end
