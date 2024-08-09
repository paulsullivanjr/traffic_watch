defmodule TrafficWatch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TrafficWatchWeb.Telemetry,
      TrafficWatch.Repo,
      {DNSCluster, query: Application.get_env(:traffic_watch, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TrafficWatch.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TrafficWatch.Finch},
      # Start a worker by calling: TrafficWatch.Worker.start_link(arg)
      # {TrafficWatch.Worker, arg},
      # Start to serve requests, typically the last entry
      TrafficWatchWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TrafficWatch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TrafficWatchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
