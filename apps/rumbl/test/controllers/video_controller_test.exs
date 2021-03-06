defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase
  alias Rumbl.Video

  @valid_attrs %{url: "http://youtu.be", title: "Video", description: "Yes"}
  @invalid_attrs %{title: "Invalid"}

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    actions = [
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :create, %{})),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      get(conn, video_path(conn, :update, "123")),
      get(conn, video_path(conn, :delete, "123")),
    ]

    Enum.each(actions, &assert_responds_with_302/1)
  end

  defp assert_responds_with_302(conn) do
    assert html_response(conn, 302)
    assert conn.halted
  end

  @tag login_as: "nik"
  test "lists all user's videos on index", %{conn: conn, user: user} do
    user_video = insert_video(user, title: "OMG Ponies!")
    other_user = insert_user(username: "other")
    other_user_video = insert_video(other_user, title: "Barbie ROX!")

    conn = get conn, video_path(conn, :index)

    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_user_video.title)
  end

  defp video_count(query) do
    Repo.one(from v in query, select: count(v.id))
  end

  @tag login_as: "nik"
  test "creates a video with valid params", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs

    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  @tag login_as: "nik"
  test "does not create a video with invalid params", %{conn: conn} do
    count_before = video_count(Video)

    conn = post conn, video_path(conn, :create), video: @invalid_attrs

    assert html_response(conn, 200) =~ "check the errors"
    assert video_count(Video) == count_before
  end

  @tag login_as: "nik"
  test "forbids unauthorized access", %{conn: conn, user: owner} do
    video = insert_video(owner, @valid_attrs)
    intruder = insert_user(username: "thief")
    conn = assign(conn, :current_user, intruder)

    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :show, video))
    end
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :edit, video))
    end
    assert_error_sent :not_found, fn ->
      put(conn, video_path(conn, :update, video, video: @valid_attrs))
    end
    assert_error_sent :not_found, fn ->
      delete(conn, video_path(conn, :delete, video))
    end
  end
end
