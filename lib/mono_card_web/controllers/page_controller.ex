defmodule MonoCardWeb.PageController do
  use MonoCardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
