defmodule Cqrs.Entity do
  alias Cqrs.Behaviour
  alias Cqrs.Ddd.Constructor
  alias Cqrs.Entity.Identity

  @callback identity(struct()) :: any()

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(opts) do
    quote do
      {identity, opts} = Identity.pop(unquote(opts))

      use Cqrs.Message,
          [require_all_fields?: false]
          |> Keyword.merge(unquote(opts))
          |> Constructor.put_option()
          |> Keyword.put(:dispatch?, false)
          |> Keyword.put(:message_type, :entity)
          |> Keyword.put(:primary_key, Macro.escape(identity))

      @behaviour Cqrs.Entity
      @before_compile Cqrs.Entity
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def identity(%__MODULE__{} = entity),
        do: Cqrs.Entity.identity(__MODULE__, entity)

      def equals?(left, right),
        do: Cqrs.Entity.equals?(__MODULE__, left, right)

      require Constructor
      Constructor.generate(return_type: :struct)
    end
  end

  def identity(entity_module, entity) do
    Behaviour.validate!(entity_module, Cqrs.Entity)
    {identity, _type, _config} = entity_module.__primary_key__()
    Map.fetch!(entity, identity)
  end

  def equals?(entity_module, %{__struct__: entity_module} = left, %{__struct__: entity_module} = right) do
    identity(entity_module, left) == identity(entity_module, right)
  end

  def equals?(entity_module, _left, _right) do
    raise Error, message: "#{inspect(entity_module)}.equals? requires two #{inspect(entity_module)} structs"
  end
end
