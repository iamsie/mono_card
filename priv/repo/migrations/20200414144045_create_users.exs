defmodule MonoCard.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :chat_id, :bigint
      add :api_key, :string

      timestamps()
    end
  end
end
