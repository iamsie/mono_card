defmodule MonoBot.Replier do
  alias MonoCard.Accounts

  def answer_the_messages(chat_id, message) do
    cond do
      String.length(message) > 25 ->
        Accounts.insert(%{chat_id: chat_id, api_key: message})

        Nadia.send_message(
          chat_id,
          "Great! Now you can view the balance or change API_MONO_KEY anytime.",
          reply_markup: %Nadia.Model.ReplyKeyboardMarkup{
            keyboard: [
              [%{text: "View Balance"}],
              [%{text: "Update API_MONO_KEY"}]
            ],
            resize_keyboard: true,
            one_time_keyboard: true
          }
        )

      message == "Update API_MONO_KEY" ->
        Nadia.send_message(chat_id, "Send me a new API_MONO_KEY")

      message == "View Balance" ->
        api_key = Accounts.get_api_key(chat_id)
        balance = check_balance(api_key)

        Nadia.send_message(
          chat_id,
          "Your current balance is #{balance}. Want to perform another operation?",
          reply_markup: %Nadia.Model.ReplyKeyboardMarkup{
            keyboard: [
              [%{text: "View Balance"}],
              [%{text: "Update API_MONO_KEY"}]
            ],
            resize_keyboard: true,
            one_time_keyboard: true
          }
        )

      true ->
        Nadia.send_message(
          chat_id,
          "What do you want to do?",
          reply_markup: %Nadia.Model.ReplyKeyboardMarkup{
            keyboard: [
              [%{text: "View Balance"}],
              [%{text: "Update API_MONO_KEY"}]
            ],
            resize_keyboard: true,
            one_time_keyboard: true
          }
        )
    end
  end

  defp check_balance(api_key) do
    card_info =
      ExMonoWrapper.get_client_info(api_key).accounts
      |> Enum.filter(fn map -> map.type === "white" end)
      |> List.first()

    (card_info.balance - rem(card_info.balance, 100)) / 100
  end
end
