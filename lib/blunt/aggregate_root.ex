defmodule Blunt.AggregateRoot do
  alias Blunt.AggregateRoot.State
  alias Blunt.Message.{Schema, Schema.Fields}

  @type state :: struct()
  @type command :: struct()
  @type domain_event :: struct()

  @callback apply(state, domain_event) :: state

  defmodule Error do
    defexception [:errors]

    def message(%{errors: errors}) do
      inspect(errors)
    end
  end

  defmacro __using__(_opts) do
    quote do
      use Blunt.Message.Compilation

      @primary_key_type false
      @require_all_fields? false
      @create_jason_encoders? false

      Module.register_attribute(__MODULE__, :schema_fields, accumulate: true)

      @behaviour Blunt.AggregateRoot
      @before_compile Blunt.AggregateRoot

      import Blunt.AggregateRoot, only: :macros
    end
  end

  @spec field(name :: atom(), type :: atom(), keyword()) :: any()
  defmacro field(name, type, opts \\ []),
    do: Fields.record(name, type, opts)

  defmacro __before_compile__(env) do
    schema = Schema.generate(env)
    state_update = State.generate_update()
    field_access_functions = State.generate_field_access_functions(env)

    [schema, state_update] ++ field_access_functions
  end
end
