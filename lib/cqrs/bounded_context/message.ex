defmodule Cqrs.BoundedContext.Message do
  @moduledoc false

  alias Cqrs.Message.{Input, Metadata}
  alias Cqrs.BoundedContext.{Error, Message}

  def validate_proxy!({:command, module, _opts, {file, line}}) do
    error = "#{inspect(module)} is not a valid #{inspect(Cqrs.Command)}. #{file}:#{line}"
    validate!(module, :command, error)
  end

  def validate_proxy!({:query, module, _opts, {file, line}}) do
    error = "#{inspect(module)} is not a valid #{inspect(Cqrs.Query)}. #{file}:#{line}"
    validate!(module, :query, error)
  end

  defp validate!(module, type, error) do
    case Code.ensure_compiled(module) do
      {:module, module} ->
        unless Metadata.is_message_type?(module, type) do
          raise Error, message: error
        end

      _ ->
        raise Error, message: error
    end
  end

  def generate_proxy({:command, module, proxy_opts, {file, line}}) do
    docs = get_docs(module)

    {function_name, proxy_opts} = function_name(module, proxy_opts)

    body =
      quote bind_quoted: [module: module, proxy_opts: proxy_opts] do
        opts = Keyword.merge(proxy_opts, opts)
        Message.dispatch(module, values, opts)
      end

    quote file: file, line: line do
      @doc unquote(docs)
      def unquote(function_name)(values, opts \\ []) do
        unquote(body)
      end
    end
  end

  def generate_proxy({:query, module, proxy_opts, {file, line}}) do
    docs = get_docs(module)

    {function_name, proxy_opts} = function_name(module, proxy_opts)
    query_function_name = String.to_atom("#{function_name}_query")

    quote file: file, line: line do
      @doc unquote(docs)
      def unquote(function_name)(values \\ [], opts \\ []) do
        opts = Keyword.merge(unquote(proxy_opts), opts)
        Message.dispatch(unquote(module), values, opts)
      end

      @doc "Same as `#{unquote(function_name)}` but returns the query without executing it"
      def unquote(query_function_name)(values, opts \\ []) do
        opts =
          unquote(proxy_opts)
          |> Keyword.merge(opts)
          |> Keyword.put(:return, :query)

        Message.dispatch(unquote(module), values, opts)
      end
    end
  end

  defp get_docs(module) do
    case Code.fetch_docs(module) do
      {:docs_v1, _anno, _lang, _format, %{"en" => docs}, _meta, _inner_docs} -> docs
      _ -> ""
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
    {field_values, opts} =
      opts
      |> Keyword.put(:dispatched_from, :bounded_context)
      |> Keyword.put(:user_supplied_fields, user_supplied_fields(values))
      |> Keyword.pop(:field_values, [])

    field_values = Enum.into(field_values, %{})
    values = Input.normalize(values, module)

    values
    |> Map.merge(field_values)
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
