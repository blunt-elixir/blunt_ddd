defmodule Cqrs.AggregateRoot.State do
  @moduledoc false

  alias Cqrs.Message.Changeset
  alias Cqrs.AggregateRoot.{Error, State}

  def generate_access({name, _type, _config}) do
    getter = String.to_atom("get_#{name}")
    putter = String.to_atom("put_#{name}")

    quote do
      def unquote(getter)(%__MODULE__{} = state) do
        Map.fetch!(state, unquote(name))
      end

      def unquote(putter)(%__MODULE__{} = state, value) do
        State.put(__MODULE__, state, unquote(name), value)
      end
    end
  end

  def put(state_module, state, key, value) do
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
