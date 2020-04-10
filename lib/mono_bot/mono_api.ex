defmodule MonoApi do
  use Tesla

  @default_mono_token "1148214767:AAEsDnbHTRcPuAbrEdWX31GX-5_PZuO_9UU"

  plug Tesla.Middleware.BaseUrl, "https://api.monobank.ua/personal/client-info"
  plug Tesla.Middleware.Headers, [{"X-Token", @default_mono_token}]
  plug Tesla.Middleware.JSON

  def new(token) do
    Tesla.client([
      {Tesla.Middleware.Headers, [{"X-Token", token}]}
    ])
  end
end
