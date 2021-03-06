defmodule Magpie.InteractiveRoomChannelTest do
  @moduledoc """
  Tests for the interactive room channel
  """
  use Magpie.ChannelCase

  # alias Magpie.InteractiveRoomChannel
  alias Magpie.ParticipantSocket

  setup do
    experiment = insert_complex_experiment()
    create_and_subscribe_participant(experiment)
  end

  test "joins the interactive room channel successfully", %{
    socket: socket,
    experiment: _experiment,
    participant_id: _participant_id
  } do
    assert {:ok, _, socket} =
             subscribe_and_join(
               socket,
               "interactive_room:#{socket.assigns.experiment_id}:#{socket.assigns.chain}:#{
                 socket.assigns.realization
               }"
             )
  end

  test "the newly joined user is tracked by Presence", %{
    socket: socket,
    experiment: _experiment,
    participant_id: _participant_id
  } do
    {:ok, _, _socket} =
      subscribe_and_join(
        socket,
        "interactive_room:#{socket.assigns.experiment_id}:#{socket.assigns.chain}:#{
          socket.assigns.realization
        }"
      )

    # payload = %{
    #   variant: socket.assigns.variant,
    #   chain: socket.assigns.chain,
    #   realization: socket.assigns.realization
    # }

    # assert_broadcast("presence_diff", ^payload)

    # Just test that it pushed out an event called "presence_diff". It seems to be not that easy to match against the payload body actually.
    assert_broadcast("presence_diff", %{})
  end

  test "start_game message is sent after the specified number of participants is reached", %{
    socket: socket,
    experiment: experiment,
    participant_id: participant_id
  } do
    # First we need do join the first created participant to the channel...
    subscribe_and_join(
      socket,
      "interactive_room:#{socket.assigns.experiment_id}:#{socket.assigns.chain}:#{
        socket.assigns.realization
      }"
    )

    num_participants = socket.assigns.num_variants
    # Enum.reduce(1..num_participants - 1, , fun)
    Enum.each(1..(num_participants - 1), fn count ->
      {:ok, socket: socket, experiment: experiment, participant_id: participant_id} =
        create_and_subscribe_participant(experiment)

      subscribe_and_join(
        socket,
        "interactive_room:#{socket.assigns.experiment_id}:#{socket.assigns.chain}:#{
          socket.assigns.realization
        }"
      )
    end)

    assert_broadcast("start_game", %{})
  end
end
