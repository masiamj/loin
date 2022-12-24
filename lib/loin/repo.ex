defmodule Loin.Repo do
  use Ecto.Repo,
    otp_app: :loin,
    adapter: Ecto.Adapters.Postgres
end
