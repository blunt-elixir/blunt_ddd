defmodule Cqrs.BoundedContext do
  alias Cqrs.BoundedContext
  alias Cqrs.BoundedContext.Proxy

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(_opts) do
    quote do
      use Cqrs.Message.Compilation

      Module.register_attribute(__MODULE__, :proxies, accumulate: true)
      Module.register_attribute(__MODULE__, :messages, accumulate: true, persist: true)

      @before_compile Cqrs.BoundedContext
      @after_compile Cqrs.BoundedContext

      import Cqrs.BoundedContext, only: :macros
    end
  end

  defmacro command(module, opts \\ []) do
    quote do
      @messages {:command, unquote(module)}
      @proxies {{:command, unquote(module), unquote(opts)}, {__ENV__.file, __ENV__.line}}
    end
  end

  defmacro query(module, opts \\ []) do
    quote do
      @messages {:query, unquote(module)}
      @proxies {{:query, unquote(module), unquote(opts)}, {__ENV__.file, __ENV__.line}}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      Enum.map(@proxies, fn {message_info, {file, line}} ->
        code = Proxy.generate(message_info)

        __ENV__
        |> Map.put(:file, file)
        |> Map.put(:line, line)
        |> Module.eval_quoted(code)
      end)
    end
  end

  defmacro __after_compile__(%{module: module}, _bytecode) do
    module
    |> BoundedContext.messages_proxying()
    |> Enum.each(&Proxy.validate!(&1, module))

    nil
  end

  def messages_proxying(bounded_context_module) do
    :attributes
    |> bounded_context_module.__info__()
    |> Keyword.get_values(:messages)
    |> List.flatten()
  end
end
