defmodule MonoCard.Accounts.Users do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :api_key, :string
    field :chat_id, :integer
    field :white_card_id, :string

    timestamps()
  end

  @doc false
  def changeset(users, attrs) do
    users
    |> cast(attrs, [:chat_id, :api_key, :white_card_id])
    |> validate_required([:chat_id, :api_key, :white_card_id])
  end
end
