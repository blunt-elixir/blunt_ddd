defmodule Cqrs.Command.Events do
  @moduledoc false

  alias Cqrs.Command.Events

  def record(name, opts) do
    quote do
      @events {unquote(name), unquote(opts), {__ENV__.file, __ENV__.line}}
    end
  end

  def generate_proxy({name, opts, _location}) do
    opts = Keyword.delete(opts, :do)
    proxy_function_name = String.to_atom(Macro.underscore(name))

    event_module =
      quote do
        Events.fq_event_name(__MODULE__, unquote(name), unquote(opts))
      end

    quote do
      def unquote(proxy_function_name)(command, values \\ [])

      def unquote(proxy_function_name)({:error, _} = errors, _values),
        do: errors

      def unquote(proxy_function_name)({:ok, %__MODULE__{} = command, _}, values) do
        unquote(event_module).new(command, values)
      end

      def unquote(proxy_function_name)(%__MODULE__{} = command, values) do
        unquote(event_module).new(command, values)
      end
    end
  end

  def generate_events(%{module: command} = env),
    do: Enum.each(command.__events__(), &generate_event(env, &1))

  defp generate_event(%{module: command} = env, {__name, opts, {file, line}} = event) do
    event_body = Keyword.get(opts, :do, nil)
    to_drop = Keyword.get(opts, :drop, []) |> List.wrap()

    schema_fields =
      command.__schema_fields__()
      |> Enum.reject(fn {name, _type, _opts} -> Enum.member?(to_drop, name) end)
      |> Enum.map(fn
        {:created_at, _, _} -> nil
        {name, type, opts} -> quote do: field(unquote(name), unquote(type), unquote(opts))
      end)

    domain_event =
      quote do
        use Cqrs.DomainEvent
        unquote_splicing(schema_fields)
        Module.eval_quoted(__MODULE__, unquote(event_body))
      end

    env =
      env
      |> Map.put(:file, file)
      |> Map.put(:line, line)

    command
    |> fq_event_name(event)
    |> Module.create(domain_event, env)
  end

  def fq_event_name(command, {event_name, event_opts, _location}),
    do: fq_event_name(command, event_name, event_opts)

  @doc false
  def fq_event_name(command, event_name, event_opts) do
    case Keyword.get(event_opts, :ns) do
      nil ->
        case namespace(event_name) do
          Elixir -> command |> namespace() |> Module.concat(event_name)
          _ns -> event_name
        end

      ns ->
        Module.concat(ns, event_name)
    end
  end

  defp namespace(module) do
    [_module_name | namespace] =
      module
      |> Module.split()
      |> Enum.reverse()

    namespace
    |> Enum.reverse()
    |> Module.concat()
  end
end
