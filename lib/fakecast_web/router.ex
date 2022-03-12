defmodule FakecastWeb.Router do
  use FakecastWeb, :router

  scope "/", FakecastWeb do
    get "/feed.xml", FeedController, :get
    get "/cover/:book", FeedController, :cover
  end
end
