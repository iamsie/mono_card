defmodule MonoBot.BotSupervisor do
  require Logger
  use Supervisor

  alias MonoBot.BotWorker

  def start_link(type \\ [], args \\ %{}) do
    Logger.info("Supervisor starts")
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    Logger.info("Init starts")

    children = [
      {BotWorker, %{}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
