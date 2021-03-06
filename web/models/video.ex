defmodule Rumbl.Video do
  use Rumbl.Web, :model

  @primary_key {:id, Rumbl.Permalink, autogenerated: true}
  schema "videos" do
    field :url, :string
    field :title, :string
    field :slug,  :string
    field :description, :string
    belongs_to :user, Rumbl.User
    belongs_to :category, Rumbl.Category
    has_many  :annotations,   Rumbl.Annotation

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:url, :title, :description, :category_id])
    |> validate_required([:url, :title, :description])
    |> slugify_title()
    |> foreign_key_constraint(:category_id)
  end

  defp slugify_title(chngset) do
    if title = get_change(chngset, :title) do
      put_change(chngset, :slug, slugify(title))
    else
      chngset
    end
  end

  defp slugify(str) do
    str |> String.downcase() |> String.replace(~r/[^\w-]+/u, "-")
  end

  defimpl Phoenix.Param, for: Rumbl.Video do
    def to_param(%{id: id, slug: slug}) do
      "#{id}-#{slug}"
    end
  end
end
