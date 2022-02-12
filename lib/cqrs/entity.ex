defmodule Cqrs.Entity do
  alias Cqrs.Entity.Identity
  alias Cqrs.Ddd.Constructor

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

      @before_compile Cqrs.Entity
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      require Constructor
      Constructor.generate(return_type: :struct)
    end
  end
end
