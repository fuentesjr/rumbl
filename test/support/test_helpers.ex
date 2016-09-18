defmodule Rumbl.TestHelpers do
  alias Rumbl.User
  alias Rumbl.Video
  alias Rumbl.Repo

  def insert_user(attrs \\ %{}) do
    user_attrs =
      Dict.merge(%{
                   name: "Some User",
                   username: "user#{Base.encode16(:crypto.rand_bytes(8))}",
                   password: "somepass",
                 }, attrs)

    %User{}
      |> User.Changesets.registration(user_attrs)
      |> Repo.insert!()
  end

  def insert_video(user, attrs \\ %{}) do
    user
      |> Ecto.build_assoc(:videos, attrs)
      |> Repo.insert!()
  end
end
