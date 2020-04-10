defmodule MonoBot.BotWorker do
  require Logger
  use GenServer

  @default_chat_id 197_893_092
  @default_mono_token "1148214767:AAEsDnbHTRcPuAbrEdWX31GX-5_PZuO_9UU"

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
    # {:ok, updates} = Nadia.get_updates(offset: state.offset)
    # last_update = List.last(updates)

    # get_message(last_update, state)

    # offset =
    #   if last_update do
    #     last_update.update_id + 1
    #   else
    #     state.offset
    #   end

    # new_state = Map.put(state, :offset, offset)
    # {:noreply, new_state}

    # handle_info(:tick, new_state)

    {:noreply, state}
  end
end
