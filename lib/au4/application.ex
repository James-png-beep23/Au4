defmodule Au4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Au4Web.Telemetry,
      Au4.Repo,
      {DNSCluster, query: Application.get_env(:au4, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Au4.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Au4.Finch},
      # Start a worker by calling: Au4.Worker.start_link(arg)
      # {Au4.Worker, arg},
      # Start to serve requests, typically the last entry
      Au4Web.Endpoint,
       {Au4.Server, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Au4.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Au4Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
