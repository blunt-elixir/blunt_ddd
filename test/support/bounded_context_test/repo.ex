defmodule Cqrs.Repo do
  use Ecto.Repo, otp_app: :cqrs_tools_bounded_context, adapter: Etso.Adapter
end
