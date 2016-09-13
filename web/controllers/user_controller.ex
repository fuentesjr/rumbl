defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  plug :authenticate when action in [:index, :show]

  alias Rumbl.User

  defp authenticate(conn, _opts) do
    case conn.assigns.current_user do
      %User{} -> conn
      _ ->
        conn
          |> put_flash(:errror, "User must be logged in to access that page.")
          |> redirect(to: page_path(conn, :index))
          |> halt()
    end
  end

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    changeset = User.Changeset.base(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.Changeset.registration(%User{}, user_params)
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
end
