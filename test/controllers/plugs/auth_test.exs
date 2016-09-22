defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth

  setup %{conn: conn} do
    conn =
      conn
        |> bypass_through(Rumbl.Router, :browser)
        |> get("/")
    {:ok, %{conn: conn}}
  end

###### test authenticate_user() ################################################
  test "authenticate_user halts when no current_user exists",
    %{conn: conn} do

    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists",
    %{conn: conn} do

    conn =
      conn
        |> assign(:current_user, %Rumbl.User{})
        |> Auth.authenticate_user([])
    refute conn.halted
  end

###### test longin() ###########################################################
  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
        |> Auth.login(%Rumbl.User{id: 123})
        |> send_resp(:ok, "")
    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

###### test longout() ##########################################################
  test "logout destroys the users session", %{conn: conn} do
    conn_after_logout =
      conn
        |> put_session(:user_id, 123)
        |> Auth.logout()
        |> send_resp(:ok, "")
    next_conn = get(conn_after_logout, "/")
    refute get_session(next_conn, :user_id)
  end

###### test call() #############################################################
  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
        |> put_session(:user_id, user.id)
        |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Repo)
    assert conn.assigns.current_user == nil
  end

###### test login_by_username_pass() ###########################################
  test "login with a valid username and pass", %{conn: conn} do
    user = insert_user(username: "me", password: "secret")
    {:ok, conn} = Auth.login_by_username_pass(conn, "me", "secret", repo: Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} =
      Auth.login_by_username_pass(conn, "me", "secret", repo: Repo)
  end

  test "login with incorrect password", %{conn: conn} do
    _ = insert_user(username: "me", password: "secret")
    assert {:error, :unauthorized, _conn} =
      Auth.login_by_username_pass(conn, "me", "wrong", repo: Repo)
  end
end
