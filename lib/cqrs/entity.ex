defmodule Cqrs.Entity do
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
      require Identity
      require Constructor

      Identity.generate()
      Constructor.generate(return_type: :struct)
    end
  end
end
