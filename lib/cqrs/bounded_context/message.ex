defmodule Cqrs.BoundedContext.Message do
  @moduledoc false

  alias Cqrs.BoundedContext.{Error, Message}

  def validate_proxy!({:command, module, _opts}) do
    error = "#{inspect(module)} is not a valid #{inspect(Cqrs.Command)}"
    validate!(module, :command, error)
  end

  def validate_proxy!({:query, module, _opts}) do
    error = "#{inspect(module)} is not a valid #{inspect(Cqrs.Query)}"
    validate!(module, :query, error)
  end

  defp validate!(module, type, error) do
    case Code.ensure_compiled(module) do
      {:module, module} ->
        unless function_exported?(module, :__message_type__, 0) && module.__message_type__() == type do
          raise Error, message: error
        end

      _ ->
        raise Error, message: error
    end
  end

  def generate_proxy({:command, module, proxy_opts}) do
    {function_name, proxy_opts} = function_name(module, proxy_opts)

    quote do
      def unquote(function_name)(values, opts \\ []) do
        opts = Keyword.merge(unquote(proxy_opts), opts)
        Message.dispatch(unquote(module), values, opts)
      end
    end
  end

  def generate_proxy({:query, module, proxy_opts}) do
    {function_name, proxy_opts} = function_name(module, proxy_opts)
    query_function_name = String.to_atom("#{function_name}_query")

    quote do
      def unquote(function_name)(values, opts \\ []) do
        opts = Keyword.merge(unquote(proxy_opts), opts)
        Message.dispatch(unquote(module), values, opts)
      end

      def unquote(query_function_name)(values, opts \\ []) do
        opts =
          unquote(proxy_opts)
          |> Keyword.merge(opts)
          |> Keyword.put(:execute, false)

        Message.dispatch(unquote(module), values, opts)
      end
    end
  end

  defp function_name(module, opts) do
    {as, opts} = Keyword.pop(opts, :as)

    name =
      case as do
        nil ->
          [name | _] =
            module
            |> Module.split()
            |> Enum.reverse()

          name
          |> to_string
          |> Macro.underscore()
          |> String.to_atom()

        name ->
          name
      end

    {name, opts}
  end

  def dispatch(module, values, opts) do
    opts =
      opts
      |> Keyword.put(:dispatched_from, :bounded_context)
      |> Keyword.put(:user_supplied_fields, user_supplied_fields(values))

    values
    |> module.new()
    |> module.dispatch(opts)
  end

  defp user_supplied_fields(list) when is_list(list),
    do: Keyword.keys(list)

  defp user_supplied_fields(struct) when is_struct(struct),
    do: user_supplied_fields(Map.from_struct(struct))

  defp user_supplied_fields(map) when is_map(map),
    do: Map.keys(map)
end
