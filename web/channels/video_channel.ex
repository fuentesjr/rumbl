defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel

  def join("videos:" <> video_id, params, socket) do
    video_id = String.to_integer(video_id)
    video = Repo.get!(Rumbl.Video, video_id)

    last_seen_id = params["last_seen_annot_id"] || 0
    annots = Repo.all(
      from a in assoc(video, :annotations),
        where: a.id > ^last_seen_id,
        order_by: [asc: a.at, asc: a.id],
        limit: 200,
        preload: [:user]
    )
    resp = %{
      annotations:
        Phoenix.View.render_many(annots, Rumbl.AnnotationView, "annotation.json")
    }

    {:ok, resp, assign(socket, :video_id, video_id)}
  end

  def handle_in(event, params, socket) do
    user = Repo.get(Rumbl.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annot", params, user, socket) do
    IO.puts "[DEBUG] user#{user.id}\n[DEBUG] #{inspect params}"

    video_id = socket.assigns.video_id
    chngset =
      user
        |> build_assoc(:annotations, video_id: video_id)
        |> Rumbl.Annotation.changeset(params)

    case Repo.insert(chngset) do
      {:ok, annot} ->
        broadcast! socket, "new_annot", %{
          id:   annot.id,
          user: Rumbl.UserView.render("user.json", %{user: user}),
          body: annot.body,
          at:   annot.at
        }
        {:reply, :ok, socket}

      {:error, chngset} ->
        {:reply, {:error, %{errors: chngset}}, socket}
    end
  end
end
