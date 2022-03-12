import Config

config :fakecast, FakecastWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "OcFWSmTKf5WM3eYBrIfyhGnd21ufht1BN+Cirxj6SO/gdGnGrPsysPnPfCegDSCA",
  server: false

config :logger, level: :warn

config :phoenix, :plug_init_mode, :runtime
