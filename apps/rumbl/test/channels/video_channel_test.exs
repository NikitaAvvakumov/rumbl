defmodule Rumbl.Channels.VideoChannelTest do
  use Rumbl.ChannelCase
  import Rumbl.TestHelpers

  setup do
    user = insert_user(name: "Nik")
    video = insert_video(user, title: "Test")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)

    {:ok, socket} = connect(Rumbl.UserSocket, %{"token" => token})

    {:ok, socket: socket, user: user, video: video}
  end

  test "join replies with video annotations", %{socket: socket, video: video} do
    for body <- ~w(one two) do
      video
      |> build_assoc(:annotations, body: body)
      |> Repo.insert!()
    end

    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    assert socket.assigns.video_id == video.id
    assert %{annotations: [%{body: "one"}, %{body: "two"}]} = reply
  end

  test "inserting new annotations", %{socket: socket, video: video} do
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
    ref = push socket, "new_annotation", %{body: "new body", at: 0}

    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{}
  end

  test "new annotation triggers InfoSys", %{socket: socket, video: video} do
    result_text = "...that is the question.\n(according to Prince Hamlet in William Shakespeare"
    insert_user(username: "wolfram")
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
    ref = push socket, "new_annotation", %{body: "to be?", at: 20}

    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{body: "to be?", at: 20}
    assert_broadcast "new_annotation", %{body: ^result_text}
  end
end
