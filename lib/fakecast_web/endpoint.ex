defmodule FakecastWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :fakecast

  plug Plug.Static,
    at: "/",
    from: :fakecast,
    gzip: false,
    only: ~w(images books)

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug FakecastWeb.Router
end
