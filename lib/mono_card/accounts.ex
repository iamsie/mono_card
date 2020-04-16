defmodule MonoCard.Accounts do
  alias MonoCard.Repo
  alias MonoCard.Accounts.Users
  import Ecto.Query, warn: false

  def insert(%{chat_id: chat_id, api_key: _api_key} = attrs) do
    if exist_by_chat_id?(chat_id) === false do
      Users.changeset(%Users{}, attrs)
      |> Repo.insert()
    else
      Users.changeset(%Users{}, attrs)
      |> Repo.update()
    end
  end

  def exist_by_chat_id?(chat_id) do
    Users
    |> from()
    |> where([u], u.chat_id == ^chat_id)
    |> Repo.exists?()
  end

  def get_api_key(chat_id) do
    Users
    |> from()
    |> where([u], u.chat_id == ^chat_id)
    |> select([u], u.api_key)
    |> Repo.one()
  end
end
