import Config

config :fakecast, FakecastWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: FakecastWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Fakecast.PubSub

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
