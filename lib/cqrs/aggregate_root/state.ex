defmodule Cqrs.AggregateRoot.State do
  @moduledoc false

  alias Cqrs.Message.Changeset
  alias Cqrs.AggregateRoot.{Error, State}

  def generate_field_access_functions(%{module: module}) do
    module
    |> Module.get_attribute(:schema_fields)
    |> Enum.map(&generate_field_access/1)
  end

  defp generate_field_access({name, _type, _config}) do
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

  def generate_update do
    quote do
      def update(%__MODULE__{} = state, values) do
        State.update(__MODULE__, state, values)
      end
    end
  end

  def update(state_module, state, values) do
    attrs = Cqrs.Message.Input.normalize(values, state_module)

    types =
      :fields
      |> state_module.__schema__()
      |> Enum.into(%{}, fn field -> {field, state_module.__schema__(:type, field)} end)

    case Ecto.Changeset.cast({state, types}, attrs, Map.keys(types)) do
      %{valid?: true} = changeset -> Ecto.Changeset.apply_changes(changeset)
      changeset -> raise Error, errors: Changeset.format_errors(changeset)
    end
  end

  def put(state_module, state, key, value),
    do: update(state_module, state, Map.new([{key, value}]))
end
