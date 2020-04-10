defmodule MonoApi do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.monobank.ua/personal/client-info"
  plug Tesla.Middleware.Headers
  plug Tesla.Middleware.JSON

  def new(token) do
    Tesla.client([
      {Tesla.Middleware.Headers, [{"X-Token", token}]}
    ])
  end
end
