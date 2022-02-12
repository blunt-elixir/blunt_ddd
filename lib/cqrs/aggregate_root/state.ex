defmodule Cqrs.AggregateRoot.State do
  @moduledoc false

  alias Cqrs.Message.Changeset
  alias Cqrs.AggregateRoot.Error

  def set(state_module, state, key, value) do
    types =
      :fields
      |> state_module.__schema__()
      |> Enum.into(%{}, fn field -> {field, state_module.__schema__(:type, field)} end)

    attrs = Map.new([{key, value}])

    case Ecto.Changeset.cast({state, types}, attrs, Map.keys(types)) do
      %{valid?: true} = changeset -> Ecto.Changeset.apply_changes(changeset)
      changeset -> raise Error, errors: Changeset.format_errors(changeset)
    end
  end
end
