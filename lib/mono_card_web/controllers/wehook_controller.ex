defmodule MonoCardWeb.WebhookController do
  use MonoCardWeb, :controller
  alias MonoBot.Replier
  alias MonoCard.Accounts
  require Logger

  def index(conn, _params) do
    conn
  end

  def create(_conn, payload) do
    Logger.info("Get a payload")
    IO.inspect(payload)
    {:ok, decoded_payload} = Jason.decode(payload)
    Logger.info("Payload decoded")
    white_card_id = decoded_payload["data"]["account"]
    balance = decoded_payload["data"]["statementItem"]["balance"]

    if Accounts.exist_by_card_id?(white_card_id) === true && balance < 100_000,
      do: Replier.balance_less_1000(balance, white_card_id)
  end
end
