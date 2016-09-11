defmodule Rumbl.Repo do
  use Ecto.Repo, otp_app: :rumbl
  @moduledoc """
    In-memory repo
  """
  # alias Rumbl.User
  # def all(User) do
  #   [
  #     %User{id: "1", name: "Jose", username: "josevalim", password: "elixir"},
  #     %User{id: "2", name: "Bruce", username: "redrapids", password: "7langs"},
  #     %User{id: "3", name: "Chris", username: "chrismccord", password: "phx"},
  #     %User{id: "4", name: "Sal", username: "sfuentes", password: "7langs"}
  #   ]
  # end
  # def all(_module), do: []
  #
  # def get(module, id) do
  #   Enum.find all(module), fn(user) -> user.id == id end
  # end
  #
  # def get_by(module, params) do
  #   Enum.find all(module), fn(user) ->
  #     Enum.all?(params, fn{key, val}-> Map.get(user, key) == val end)
  #   end
  # end
  # def get_all_by(module, params) do
  #   Enum.filter all(module), fn(user) ->
  #     Enum.all?(params, fn{key, val}-> Map.get(user, key) == val end)
  #   end
  # end

end
