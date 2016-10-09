defmodule Rumbl.UserRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  @valid_attrs %{name: "Some User", username: "nik"}

  test "converts unique constraint on username to error" do
    insert_user(username: "mari")
    attrs = Map.put(@valid_attrs, :username, "mari")

    changeset = User.changeset(%User{}, attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:username, {"has already been taken", []}} in changeset.errors
  end
end
