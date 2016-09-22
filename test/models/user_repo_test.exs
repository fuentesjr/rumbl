defmodule Rumbl.UserRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  @valid_attrs %{name: "A User", username: "eva"}

  test "generates error when unique_constraint on username is broken" do
    insert_user(username: "eric")
    attrs = Map.put(@valid_attrs, :username, "eric")
    chngset = User.changeset(%User{}, attrs)

    assert {:error, chngset} = Repo.insert(chngset)
    assert {:username, {"has already been taken", []}} in chngset.errors
  end

end
