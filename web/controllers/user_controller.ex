defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  plug :authenticate_user when action in [:index, :show]

  alias Rumbl.User

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, "show.html", user: user
  end

  def edit(conn, %{"id" => id}) do
    chngset = Repo.get!(User, id) |> User.changeset()
    render conn, "edit.html", user_id: id, changeset: chngset
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(User, id)
    chngset = User.changeset(user, user_params)
    case Repo.update(chngset) do
      {:ok, user} ->
        conn
          |> put_flash(:info, "User #{user.name} updated!")
          |> redirect(to: user_path(conn, :show, user.id))
      {:error, chngset} ->
        render conn, "edit.html", user_id: user.id, changeset: chngset
    end
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset_registration(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
          |> Rumbl.Auth.login(user)
          |> put_flash(:info, "#{user.name} created!")
          |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    Repo.delete!(user)

    conn
      |> put_flash(:info, "User (#{user.username}) removed!")
      |> redirect(to: user_path(conn, :index))
  end
end
