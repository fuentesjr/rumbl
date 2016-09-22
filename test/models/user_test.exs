defmodule Rumbl.UserTest do
  use Rumbl.ModelCase, async: true
  alias Rumbl.User

  @valid_attrs    %{name: "Some User", username: "someuser", password: "secret"}
  @invalid_attrs  %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset does not accept long usernames" do
    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
    assert {:username, "should be at most 20 character(s)"}
           in errors_on(%User{}, attrs)
  end

  test "changeset_registration password must be at least 6 chars long" do
    attrs = Map.put(@valid_attrs, :password, "12345")
    chngset = User.changeset_registration(%User{}, attrs)
    assert {:password, {"should be at least %{count} character(s)", [count: 6]}}
           in chngset.errors
  end

  test "changeset_registration with valid attributes hashes password" do
    attrs = Map.put(@valid_attrs, :password, "123456")
    chngset = User.changeset_registration(%User{}, attrs)
    %{password: pass, password_hash: pass_hash} = chngset.changes

    assert chngset.valid?
    assert pass_hash
    assert Comeonin.Bcrypt.checkpw(pass, pass_hash)
  end

end
