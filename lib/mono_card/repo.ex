defmodule MonoCard.Repo do
  use Ecto.Repo,
    otp_app: :mono_card,
    adapter: Ecto.Adapters.Postgres
end
