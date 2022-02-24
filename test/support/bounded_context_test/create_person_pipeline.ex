defmodule Support.BoundedContextTest.CreatePersonPipeline do
  use Blunt.CommandPipeline

  alias Blunt.Repo
  alias Support.BoundedContextTest.ReadModel.Person

  @impl true
  def handle_dispatch(%{id: id, name: name}, _context) do
    %{id: id, name: name}
    |> Person.changeset()
    |> Repo.insert()
  end
end
