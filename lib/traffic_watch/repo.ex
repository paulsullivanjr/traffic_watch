defmodule TrafficWatch.Repo do
  use Ecto.Repo,
    otp_app: :traffic_watch,
    adapter: Ecto.Adapters.Postgres
end
