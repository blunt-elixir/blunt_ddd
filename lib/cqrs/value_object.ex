defmodule Cqrs.ValueObject do
  alias Cqrs.Ddd.Constructor

  defmacro __using__(opts) do
    quote do
      use Cqrs.Message,
          [require_all_fields?: false]
          |> Keyword.merge(unquote(opts))
          |> Constructor.put_option()
          |> Keyword.put(:dispatch?, false)
          |> Keyword.put(:message_type, :value_object)

      @before_compile Cqrs.ValueObject
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      require Constructor
      Constructor.generate(return_type: :struct)
    end
  end
end
