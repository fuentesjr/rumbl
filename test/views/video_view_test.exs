defmodule Rumbl.VideoViewTest do
  use Rumbl.ConnCase, async: true
  import Phoenix.View

  alias Rumbl.Video


  test "render video#index.new", %{conn: conn} do
    videos = [%Video{id: 1, title: "dogs"},
              %Video{id: 2, title: "cats"}]
    content = render_to_string(Rumbl.VideoView, "index.html",
                               conn: conn, videos: videos)

    assert String.contains?(content, "Listing videos")
    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "render new.html", %{conn: conn} do
    chngset = Video.changeset(%Video{})
    cats = [{"cats", 123}]
    content = render_to_string(Rumbl.VideoView, "new.html", conn: conn,
                               changeset: chngset, cats: cats)
    assert String.contains?(content, "New video")
  end

end
