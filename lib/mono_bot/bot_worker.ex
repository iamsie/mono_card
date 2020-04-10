defmodule MonoBot.BotWorker do
  require Logger
  use GenServer
  use Tesla

  @default_chat_id 197_893_092
  @default_mono_token "ux31VQVUOG7QFCd2WDpdN-7qSpWGY6F3tEAYM2B9LeO8"

  def start_link(args \\ %{}, opts \\ []) do
    Logger.info("Worker starts")
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    Logger.info("Worker inits")
    Process.send_after(self(), :tick, 5000)
    {:ok, Map.merge(args, %{offset: 0, api_key: nil})}
  end

  def handle_info(:tick, state) do
    IO.inspect(state.api_key)
    {:ok, updates} = Nadia.get_updates(offset: state.offset)

    last_update = List.last(updates)
    get_message(last_update, state)

     offset =
      if last_update do
        last_update.update_id + 1
      else
        state.offset
      end

     api_key =
       if last_update do
        message_text =
          last_update
        |> Map.get(:message)
        |> Map.get(:text)

      if String.length(message_text) > 15 do
        message_text
      else
        nil
      end
      else
        state.api_key
      end

    new_state =
      state
      |> Map.put(:offset, offset)
      |> Map.put(:api_key, api_key)
    {:noreply, new_state}

    handle_info(:tick, new_state)
  end

  def get_message(nil, _state), do: :noop

   def get_message(update, state) do
    username = update.message.from.first_name

    message_text =
      update
      |> Map.get(:message)
      |> Map.get(:text)

     api_key =
      if String.length(message_text) > 15 do message_text else nil end

    new_state =
      state
      |> Map.put(:message, message_text)
      |> Map.put(:chat_id, @default_chat_id)
      |> Map.put(:username, username)
      |> Map.put(:api_key, api_key)

    handle_cast(:message, new_state)
  end

  def handle_cast(:message, %{message: message} = state) do
    IO.inspect(state)
    cond do
      message === "View Balance" ->
        if state[:api_key] !== nil do
          IO.inspect(state)
          check_balance(state.api_key, state.chat_id)
         else
         Nadia.send_message(state.chat_id, "Send me Mono API key")
        end

        true -> Nadia.send_message(
          state.chat_id,
          "Hi, " <>
            state.username <>
            "! What do you want to do?",
            reply_markup: %Nadia.Model.ReplyKeyboardMarkup{
            keyboard: [
              [%{text: "View Balance"}]
            ],
            resize_keyboard: true,
            one_time_keyboard: true
          }
        )
    end

    {:noreply, state}
  end

  defp check_balance(api_key, chat_id) do
    {:ok, env} = MonoApi.new(api_key)
      |>Tesla.get("https://api.monobank.ua/personal/client-info")

    balance_with_cents = env.body
    |> String.split(",")
    |> Enum.filter(fn str -> String.contains?(str, "balance") end)
    |> Enum.map(fn str -> String.split(str, ":") end)
    |> List.flatten()
    |> Enum.at(1)
    |> String.to_integer()

    balance_without_cents = (balance_with_cents - rem(balance_with_cents, 100)) / 100

    Nadia.send_message(chat_id, "Your current balance is #{balance_without_cents}")
  end
end



