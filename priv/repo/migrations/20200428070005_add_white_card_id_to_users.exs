defmodule MonoCard.Repo.Migrations.AddWhiteCardIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :white_card_id, :string
    end
  end
end
