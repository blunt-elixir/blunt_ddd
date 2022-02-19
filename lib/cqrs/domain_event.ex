defmodule Cqrs.DomainEvent do
  alias Cqrs.Ddd.Constructor

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(opts) do
    {derive_from, opts} = Keyword.pop(opts, :derive_from)

    quote bind_quoted: [derive_from: derive_from, opts: opts] do
      use Cqrs.Message,
          [require_all_fields?: false]
          |> Keyword.merge(opts)
          |> Constructor.put_option()
          |> Keyword.put(:versioned?, true)
          |> Keyword.put(:message_type, :domain_event)

      unless is_nil(derive_from) do
        fields = Cqrs.DomainEvent.__derive_from__(derive_from, opts)
        Module.eval_quoted(__MODULE__, fields)
      end

      @before_compile Cqrs.DomainEvent
    end
  end

  @doc false
  def __derive_from__(command_module, opts) do
    quote bind_quoted: [command_module: command_module, opts: opts] do
      unless Cqrs.Message.Metadata.is_command?(command_module) do
        raise Error, message: "derive_from requires a Cqrs.Command. #{inspect(command_module)} is not one."
      else
        to_drop = Keyword.get(opts, :drop, []) |> List.wrap()

        command_module
        |> Cqrs.Message.Metadata.fields()
        |> Enum.reject(fn {name, _type, _opts} -> Enum.member?(to_drop, name) end)
        |> Enum.map(fn field ->
          @schema_fields field
        end)
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      require Constructor
      Constructor.generate(return_type: :struct)
    end
  end
end
