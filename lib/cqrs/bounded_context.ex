defmodule Cqrs.BoundedContext do
  alias Cqrs.{BoundedContext, BoundedContext.Proxy}

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :proxies, accumulate: true, persist: true)

      @after_compile Cqrs.BoundedContext

      import Cqrs.BoundedContext, only: :macros
    end
  end

  defmacro command(module, opts \\ []) do
    quote bind_quoted: [module: module, opts: opts] do
      @proxies {:command, module}
      proxy = Proxy.generate({:command, module, opts})
      Module.eval_quoted(__ENV__, proxy)
    end
  end

  defmacro query(module, opts \\ []) do
    quote bind_quoted: [module: module, opts: opts] do
      @proxies {:query, module}
      proxy = Proxy.generate({:query, module, opts})
      Module.eval_quoted(__ENV__, proxy)
    end
  end

  defmacro __after_compile__(%{module: module}, _bytecode) do
    module
    |> BoundedContext.proxies()
    |> Enum.each(&Proxy.validate!(&1, module))

    nil
  end

  def proxies(bounded_context_module) do
    :attributes
    |> bounded_context_module.__info__()
    |> Keyword.get_values(:proxies)
    |> List.flatten()
  end
end
