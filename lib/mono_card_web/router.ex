defmodule MonoCardWeb.Router do
  use MonoCardWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MonoCardWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/webhook", WebhookController, only: [:index, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/webhook", MonoCardWeb do
  #   pipe_through :api
  # end
end
