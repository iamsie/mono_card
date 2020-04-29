defmodule MonoCardWeb.WebhookController do
  use MonoCardWeb, :controller
  alias MonoBot.Replier
  alias MonoCard.Accounts
  require Logger

  def index(conn, _params) do
    conn
  end

  def create(conn, payload) do
    Logger.info("Get a payload")
    white_card_id = payload["data"]["account"]
    balance = payload["data"]["statementItem"]["balance"]

    if Accounts.exist_by_card_id?(white_card_id) === true && balance < 100_000,
      do: Replier.balance_less_1000(balance, white_card_id)

    conn
  end
end
