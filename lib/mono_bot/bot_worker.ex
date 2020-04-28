defmodule MonoBot.BotWorker do
  use GenServer
  use Tesla

  alias MonoCard.Accounts
  alias MonoBot.Replier

  def start_link(args \\ %{}, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    tick(1000, :messages)

    {:ok, Map.merge(args, %{offset: 0, api_key: nil})}
  end

  def handle_info({:tick, :messages}, state) do
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

    tick(:timer.seconds(1), :messages)

    {:noreply, new_state}
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
      Accounts.exist_by_chat_id?(state.chat_id) === true || String.length(message) > 25 ->
        Replier.answer_the_messages(state.chat_id, message)

      true ->
        Nadia.send_message(
          state.chat_id,
          "Hi, " <>
            state.username <>
            "! Seems like you are a newcomer. So,send me your MONO_API_KEY"
        )
    end

    {:noreply, state}
  end

  def send_webhook(api_key) do
    ExMonoWrapper.post_personal_webhook(api_key, %{
      webhookurl: System.get_env("WEB_HOOK_URL")
    })
  end

  defp tick(interval \\ 1_000, task) when is_integer(interval) do
    Process.send_after(self(), {:tick, task}, interval)
  end
end
