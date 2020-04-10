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
    {:ok, Map.merge(args, %{offset: 0})}
  end

  def handle_info(:tick, state) do
    {:ok, updates} = Nadia.get_updates(offset: state.offset)
    last_update = List.last(updates)

    get_message(last_update, state)

    offset =
      if last_update do
        last_update.update_id + 1
      else
        state.offset
      end

    new_state = Map.put(state, :offset, offset)
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

    new_state =
      state
      |> Map.put(:message, message_text)
      |> Map.put(:chat_id, @default_chat_id)
      |> Map.put(:username, username)

    handle_cast(:message, new_state)
  end

  def handle_cast(:message, %{message: message} = state) do
    if message === "View Balance" do
      # {:ok, env} = user(@default_mono_token) |> Tesla.get("https://api.monobank.ua/personal/client-info")
      # my_info = Tesla.put_header(env, "X-Token", @default_mono_token)

    #  my_info = Tesla.request(client, [{"X-Token", @default_mono_token}])


      {:ok, env} =
      MonoApi.new(@default_mono_token)
       |>Tesla.get("https://api.monobank.ua/personal/client-info")

      balance_with_cents = env.body
      |> String.split(",")
      |> Enum.filter(fn str -> String.contains?(str, "balance") end)
      |> Enum.map(fn str -> String.split(str, ":") end)
      |> List.flatten()
      |> Enum.at(1)
      |> String.to_integer()

      balance_without_cents = (balance_with_cents - rem(balance_with_cents, 100)) / 100


      Nadia.send_message(state.chat_id, "Your current balance is #{balance_without_cents}")
    else

    Nadia.send_message(
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
end



