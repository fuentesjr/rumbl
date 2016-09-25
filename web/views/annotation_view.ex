defmodule Rumbl.AnnotationView do
  use Rumbl.Web, :view

  def render("annotation.json", %{annotation: annot}) do
    %{
      id: annot.id,
      body: annot.body,
      at: annot.at,
      user: render_one(annot.user, Rumbl.UserView, "user.json")
    }
  end
end
