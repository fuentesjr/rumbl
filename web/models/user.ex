defmodule Rumbl.User do
  use Rumbl.Web, :model

  schema "users" do
    field     :name,          :string
    field     :username,      :string
    field     :password,      :string, virtual: true
    field     :password_hash, :string
    has_many  :videos,        Rumbl.Video

    timestamps
  end

  defmodule Changeset do
    def base(model, params \\ %{}) do
      model
        |> cast(params, [:name,  :username])
        |> validate_length(:username, min: 1, max: 20)
    end

    def registration(model, params) do
      model
        |> base(params)
        |> cast(params, [:password])
        |> validate_length(:password, min: 4, max: 100)
        |> put_pass_hash()
    end

    ### Private helper method
    defp put_pass_hash(changeset) do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
          put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
        _ -> changeset
      end
    end
  end
end
