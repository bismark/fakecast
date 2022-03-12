import Config

config :fakecast, FakecastWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "acDAkJGUwMlS6UBcUFL+fT8lGtu+1xoEcqQBe5/Ccgxyu44LspMCLY0vwNCJVe4G",
  watchers: []

config :logger, :console, format: "[$level] $message\n"

config :phoenix,
  stacktrace_depth: 20,
  plug_init_mode: :runtime
