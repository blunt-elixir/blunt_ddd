defmodule Cqrs.Ddd do
  defmacro __using__(_opts) do
    quote do
      import Cqrs.Ddd, only: :macros
    end
  end

  defmacro aggregate_state(do: body) do
    quote do
      use Cqrs.AggregateRoot
      unquote(body)
    end
  end

  defmacro defcontext(do: body) do
    quote do
      use Cqrs.BoundedContext
      unquote(body)
    end
  end

  defmacro defevent(opts \\ [], do: body) do
    quote do
      use Cqrs.DomainEvent, unquote(opts)
      unquote(body)
    end
  end

  defmacro defvalue(opts \\ [], do: body) do
    quote do
      use Cqrs.ValueObject, unquote(opts)
      unquote(body)
    end
  end

  defmacro defentity(opts \\ [], do: body) do
    quote do
      use Cqrs.Entity, unquote(opts)
      unquote(body)
    end
  end
end
