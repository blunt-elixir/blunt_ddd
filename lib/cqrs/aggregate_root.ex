defmodule Cqrs.AggregateRoot do
  alias Cqrs.AggregateRoot.State
  alias Cqrs.Message.{Schema, Schema.Fields}

  @type state :: struct()
  @type command :: struct()
  @type domain_event :: struct()

  @callback execute(state, command) ::
              {:ok, domain_event | list(domain_event)} | {:error, any()} | nil

  @callback apply(state, domain_event) :: state

  defmodule Error do
    defexception [:errors]

    def message(%{errors: errors}) do
      inspect(errors)
    end
  end

  defmacro __using__(_opts) do
    quote do
      use Cqrs.Message.Compilation

      @primary_key_type false
      @require_all_fields? false
      @create_jason_encoders? false

      Module.register_attribute(__MODULE__, :schema_fields, accumulate: true)

      @behaviour Cqrs.AggregateRoot
      @before_compile Cqrs.AggregateRoot

      import Cqrs.AggregateRoot, only: :macros

      @impl true
      def execute(_state, _command), do: nil
      defoverridable execute: 2
    end
  end

  @spec field(name :: atom(), type :: atom(), keyword()) :: any()
  defmacro field(name, type, opts \\ []),
    do: Fields.record(name, type, opts)

  defmacro __before_compile__(_env) do
    quote do
      require Schema
      Schema.generate()

      require State
      State.generate_update()
      access = Enum.map(@schema_fields, &State.generate_field_access/1)
      Module.eval_quoted(__MODULE__, access)
    end
  end
end
