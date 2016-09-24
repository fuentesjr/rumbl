defmodule Rumbl.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    #user = user_id && repo.get(Rumbl.User, user_id)
    #assign(conn, :current_user, user)

    cond do
      user = conn.assigns[:current_user] ->
        conn
      user = user_id && repo.get(Rumbl.User, user_id) ->
        assign_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  defp assign_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
      |> assign(:current_user, user)
      |> assign(:user_token, token)
  end


  # Plug function
  import Phoenix.Controller
  alias Rumbl.Router.Helpers, as: RouterHelper
  def authenticate_user(conn, _opts) do
    case conn.assigns.current_user do
      %Rumbl.User{} -> conn
      _ ->
        conn
          |> put_flash(:error, "User must be logged in to access that page.")
          |> redirect(to: RouterHelper.page_path(conn, :index))
          |> halt()
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def login(conn, user) do
    conn
      |> assign_user(user)
      |> put_session(:user_id, user.id)
      |> configure_session(renew: true)
  end

  def login_by_username_pass(conn, username, given_passwd, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.User, username: username)

    cond do
      user && checkpw(given_passwd, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end
end
