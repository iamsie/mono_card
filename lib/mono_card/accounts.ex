defmodule MonoCard.Accounts do
  alias MonoCard.Repo
  alias MonoCard.Accounts.Users
  import Ecto.Query, warn: false

  def insert(%{chat_id: chat_id, api_key: _api_key} = attrs) do
    case Repo.get_by(Users, %{chat_id: chat_id}) do
      nil -> %Users{}
      user -> user
    end
    |> Users.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def exist_by_chat_id?(chat_id) do
    case Repo.get_by(Users, %{chat_id: chat_id}) do
      nil -> false
      _user -> true
    end
  end

  def get_api_key(chat_id) do
    Users
    |> from()
    |> where([u], u.chat_id == ^chat_id)
    |> select([u], u.api_key)
    |> Repo.one()
  end
end
