defmodule Rumbl.VideoController do
  use Rumbl.Web, :controller
  alias Rumbl.Video
  alias Rumbl.Category

  plug :load_cats when action in [:new, :create, :edit, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  defp user_videos(user), do: assoc(user, :videos)

  def index(conn, _params, user) do
    videos = user |> user_videos() |> Repo.all()
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, user) do
    changeset =
      user |> build_assoc(:videos) |> Video.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    changeset =
      user |> build_assoc(:videos) |> Video.changeset(video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = user |> user_videos() |> Repo.get!(id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = user |> user_videos() |> Repo.get!(id)
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = user |> user_videos() |> Repo.get!(id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = user |> user_videos() |> Repo.get!(id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  defp load_cats(conn, _) do
    query = Category.alphabetical |> Category.name_and_ids
    cats = Repo.all query
    assign(conn, :cats, cats)
  end
end
