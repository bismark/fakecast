defmodule Fakecast.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FakecastWeb.Telemetry,
      FakecastWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Fakecast.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FakecastWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
