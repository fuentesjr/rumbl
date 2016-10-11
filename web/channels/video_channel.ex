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
        broadcast_annotation(annot, socket)
        Task.start_link(fn -> compute_additional_info(annot, socket) end)
        {:reply, :ok, socket}

      {:error, chngset} ->
        {:reply, {:error, %{errors: chngset}}, socket}
    end
  end

  alias Rumbl.AnnotationView
  defp broadcast_annotation(annotation, socket) do
    annotation = Repo.preload(annotation, :user)
    rendered_ann = Phoenix.View.render(AnnotationView, "annotation.json", %{
      annotation: annotation
    })
    broadcast! socket, "new_annot", rendered_ann
  end

  defp compute_additional_info(ann, socket) do
    IO.puts "[INFOSYS DEBUG] sending info: #{inspect ann}"
    for result <- Rumbl.InfoSys.compute(ann.body, limit: 1, timeout: 10_000) do
      IO.puts "[INFOSYS DEBUG] receiving info: #{inspect result}"
      attrs = %{url: result.url, body: result.text, at: ann.at}
      info_chngset =
        Repo.get_by!(Rumbl.User, username: result.backend)
          |> build_assoc(:annotations, video_id: ann.video_id)
          |> Rumbl.Annotation.changeset(attrs)
      case Repo.insert(info_chngset) do
        {:ok, info_ann} -> broadcast_annotation(info_ann, socket)
        {:error, _changeset} -> :ignore
      end
    end
  end

end
