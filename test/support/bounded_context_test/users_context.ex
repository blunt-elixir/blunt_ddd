defmodule Support.BoundedContextTest.UsersContext do
  use Cqrs.BoundedContext
  alias Support.BoundedContextTest.{CreatePerson, GetPerson}

  command CreatePerson
  command CreatePerson, as: :create_person2
  command CreatePerson, as: :create_person_with_custom_opts, send_notification: true

  query GetPerson
end
