defmodule WordleWeb.Router do
  use WordleWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WordleWeb do
    pipe_through :api
    resources "/game", GameController, only: [:create, :show, :update]
    # TODO admin api to delete and list games

    # TODO we should require an email to issue an API key to slow down bots if we need to
  end
end
