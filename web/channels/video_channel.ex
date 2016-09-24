defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel

  def join("videos:" <> video_id, _param, socket) do
    {:ok, socket}
  end

  def handle_in("new_annot", params, socket) do
    IO.puts "[DEBUG] user#{socket.assigns.user_id}\n[DEBUG] #{inspect params}"

    broadcast! socket, "new_annot", %{
      user: %{username: "anon"},
      body: params["body"],
      at: params["at"]
    }

    {:reply, :ok, socket}
  end
end
