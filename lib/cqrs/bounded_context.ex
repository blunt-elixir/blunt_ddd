defmodule Cqrs.BoundedContext do
  alias Cqrs.BoundedContext.Message

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :proxies, accumulate: true)

      @before_compile Cqrs.BoundedContext
      @after_compile Cqrs.BoundedContext

      import Cqrs.BoundedContext, only: :macros
    end
  end

  defmacro command(module, opts \\ []) do
    quote do
      @proxies {:command, unquote(module), unquote(opts)}
    end
  end

  defmacro query(module, opts \\ []) do
    quote do
      @proxies {:query, unquote(module), unquote(opts)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __proxies__, do: @proxies

      proxies = Enum.map(@proxies, &Message.generate_proxy/1)
      Module.eval_quoted(__MODULE__, proxies)
    end
  end

  defmacro __after_compile__(%{module: module}, _bytecode) do
    Enum.each(module.__proxies__(), &Message.validate_proxy!/1)
    nil
  end
end
