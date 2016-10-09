defmodule Rumbl.UserTest do
  use Rumbl.ModelCase, async: true
  alias Rumbl.User

  @valid_attrs %{name: "Some User", username: "some", password: "password"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)

    refute changeset.valid?
  end

  test "changeset does not accept long usernames" do
    long_username = String.duplicate("a", 21)
    attrs = Map.put(@valid_attrs, :username, long_username)
    error = {:username, "should be at most 20 character(s)"}

    assert error in errors_on(%User{}, attrs)
  end

  test "registration_changeset password must be at least 6 characters long" do
    short_password = String.duplicate("a", 5)
    attrs = Map.put(@valid_attrs, :password, short_password)
    error = {:password, {"should be at least %{count} character(s)", [count: 6]}}

    changeset = User.registration_changeset(%User{}, attrs)

    assert error in changeset.errors
  end

  test "registration_changeset with valid attrs hashes password" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    %{password_hash: pass_hash} = changeset.changes

    assert changeset.valid?
    assert pass_hash
    assert Comeonin.Bcrypt.checkpw(@valid_attrs[:password], pass_hash)
    refute Map.has_key?(changeset, :password)
  end
end
