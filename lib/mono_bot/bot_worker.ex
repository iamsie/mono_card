defmodule MonoBot.BotWorker do
  use GenServer
  use Tesla

  alias MonoCard.Accounts

  def start_link(args \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    Process.send_after(self(), :messages, 5000)

    {:ok, Map.merge(args, %{offset: 0, api_key: nil})}
  end

  def handle_info(:messages, state) do
    {:ok, updates} = Nadia.get_updates(offset: state.offset)

    last_update = List.last(updates)
    get_message(last_update, state)

    offset =
      if last_update do
        last_update.update_id + 1
      else
        state.offset
      end

    new_state =
      state
      |> Map.put(:offset, offset)

    {:noreply, new_state}

    handle_info(:messages, new_state)
  end

  def get_message(nil, _state), do: :noop

  def get_message(update, state) do
    username = update.message.from.first_name
    chat_id = update.message.from.id

    message_text =
      update
      |> Map.get(:message)
      |> Map.get(:text)

    new_state =
      state
      |> Map.put(:message, message_text)
      |> Map.put(:chat_id, chat_id)
      |> Map.put(:username, username)

    handle_cast(:message, new_state)
  end

  def handle_cast(:message, %{message: message} = state) do
    cond do
      Accounts.exist_by_chat_id?(state.chat_id) === true || message === "Send/Update API_MONO_KEY" ||
          String.length(message) > 25 ->
        answer_the_messages(state.chat_id, message)

      true ->
        IO.inspect(message)

        Nadia.send_message(
          state.chat_id,
          "Hi, " <>
            state.username <>
            "! Seems like you are a newcomer. So,send me your MONO_API_KEY",
          reply_markup: %Nadia.Model.ReplyKeyboardMarkup{
            keyboard: [
              [%{text: "Send/Update API_MONO_KEY"}]
            ],
            resize_keyboard: true,
            one_time_keyboard: true
          }
        )
    end

    {:noreply, state}
  end

  defp answer_the_messages(chat_id, message) do
    cond do
      String.length(message) > 25 && message !== "Send/Update API_MONO_KEY" ->
        Accounts.insert(%{chat_id: chat_id, api_key: message})

        Nadia.send_message(
          chat_id,
          "Great! Now you can view the balance or change API_MONO_KEY anytime.",
          reply_markup: %Nadia.Model.ReplyKeyboardMarkup{
            keyboard: [
              [%{text: "View Balance"}],
              [%{text: "Send/Update API_MONO_KEY"}]
            ],
            resize_keyboard: true,
            one_time_keyboard: true
          }
        )

      message == "Send/Update API_MONO_KEY" ->
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
              [%{text: "Send/Update API_MONO_KEY"}]
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
              [%{text: "Send/Update API_MONO_KEY"}]
            ],
            resize_keyboard: true,
            one_time_keyboard: true
          }
        )
    end
  end

  def check_balance(api_key) do
    {:ok, env} =
      MonoApi.new(api_key)
      |> Tesla.get("https://api.monobank.ua/personal/client-info")

    balance_with_cents =
      env.body
      |> String.split(",")
      |> Enum.filter(fn str ->
        String.contains?(str, "balance") || String.contains?(str, "type")
      end)
      |> Enum.chunk_every(2)
      |> Enum.map(fn list -> List.to_string(list) end)
      |> Enum.filter(fn str ->
        String.contains?(str, "white")
      end)
      |> Enum.map(fn str ->
        String.split(str, "type")
        |> Enum.at(0)
        |> String.split(":")
        |> Enum.at(1)
        |> String.split("\"")
        |> Enum.at(0)
        |> String.to_integer()
      end)
      |> Enum.at(0)

    (balance_with_cents - rem(balance_with_cents, 100)) / 100
  end
end
