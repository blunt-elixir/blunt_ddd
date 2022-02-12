defmodule Cqrs.DomainEventTest do
  use ExUnit.Case, async: true

  alias Support.DomainEventTest.{DefaultEvent, EventWithSetVersion, EventWithDecimalVersion}

  test "is version 1 by default" do
    assert %DefaultEvent{version: 1} = DefaultEvent.new(%{})
  end

  test "version is settable" do
    assert %EventWithSetVersion{version: 2} = EventWithSetVersion.new(%{})
  end

  test "version is decimal" do
    assert %EventWithDecimalVersion{version: 2.3} = EventWithDecimalVersion.new(%{})
  end
end
