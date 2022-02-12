defmodule Cqrs.EntityTestMessages.Protocol do
  defmodule Entity1 do
    use Cqrs.Entity
  end

  defmodule Entity2 do
    use Cqrs.Entity, identity: {:ident, :binary_id, []}
  end
end
