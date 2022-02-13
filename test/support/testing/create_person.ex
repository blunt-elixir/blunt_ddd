defmodule Support.Testing.CreatePerson do
  use Cqrs.Command
  use Cqrs.Command.EventDerivation

  field :id, :binary_id
  field :name, :string

  derive_event PersonCreated
end

defmodule Support.Testing.CreatePersonPipeline do
  use Cqrs.CommandPipeline

  @impl true
  def handle_dispatch(command, _context) do
    {:dispatched, command}
  end
end
