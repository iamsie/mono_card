defmodule MonoCard.Accounts do
  alias MonoCard.Repo
  alias MonoCard.Accounts.Users
  alias MonoBot.BotWorker
  import Ecto.Query, warn: false

  def insert(%{chat_id: chat_id, api_key: api_key} = attrs) do
    monobank_accounts_info =
      ExMonoWrapper.get_client_info(api_key)
      |> Map.get(:accounts)
      |> Enum.filter(fn map -> map.type === "white" end)
      |> List.first()

    attrs =
      attrs
      |> Map.put(:white_card_id, monobank_accounts_info.id)

    case Repo.get_by(Users, %{chat_id: chat_id}) do
      nil -> %Users{}
      user -> user
    end
    |> Users.changeset(attrs)
    |> Repo.insert_or_update()

    BotWorker.set_webhook(api_key)
  end

  def exist_by_chat_id?(chat_id) do
    case Repo.get_by(Users, %{chat_id: chat_id}) do
      nil -> false
      _user -> true
    end
  end

  def exist_by_card_id?(card_id) do
    case Repo.get_by(Users, %{white_card_id: card_id}) do
      nil -> false
      _user -> true
    end
  end

  def get_chat_id_by_card_id(card_id) do
    user = Repo.get_by(Users, %{white_card_id: card_id})

    user.chat_id
  end

  def get_api_key(chat_id) do
    Users
    |> from()
    |> where([u], u.chat_id == ^chat_id)
    |> select([u], u.api_key)
    |> Repo.one()
  end
end
