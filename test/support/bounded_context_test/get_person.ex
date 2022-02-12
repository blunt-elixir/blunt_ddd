defmodule Support.BoundedContextTest.GetPerson do
  use Cqrs.Query

  field :id, :binary_id, required: true

  binding :person, CqrsToolsBoundedContext.QueryTest.ReadModel.Person
end
