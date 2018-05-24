defmodule ExWire.P2PWireProtocol do
  @moduledoc """
  Functions that deal directly with the DEVp2p Wire Protocol.

  For more information, please see:
  https://github.com/ethereum/wiki/wiki/%C3%90%CE%9EVp2p-Wire-Protocol
  """

  alias ExWire.{Config, Packet}

  defmodule Session do
    @moduledoc """
      Module to hold struct for a p2p wire protocol session.
      The session should be active when `Hello` messages have been exchanged.

      See https://github.com/ethereum/wiki/wiki/%C3%90%CE%9EVp2p-Wire-Protocol#session-management
    """

    alias ExWire.Packet.Hello

    @type t :: %Session{}

    defstruct handshake_sent: false, handshake_received: false

    def active?(%Session{handshake_received: false}), do: false
    def active?(%Session{handshake_sent: false}), do: false

    def active?(%Session{handshake_sent: %Hello{}, handshake_received: %Hello{}} = session) do
      compatible_capabilities?(session)
    end

    def disconnect(session = %Session{}) do
      %{session | handshake_sent: false, handshake_received: false}
    end

    def compatible_capabilities?(session = %Session{}) do
      %Session{handshake_received: handshake_received, handshake_sent: handshake_sent} = session

      intersection =
        MapSet.intersection(
          to_mapset(handshake_received.caps),
          to_mapset(handshake_sent.caps)
        )

      !Enum.empty?(intersection)
    end

    defp to_mapset(list) do
      Enum.into(list, MapSet.new())
    end
  end

  @spec init_session :: Session.t()
  def init_session do
    %Session{}
  end

  def generate_handshake do
    %Packet.Hello{
      p2p_version: Config.p2p_version(),
      client_id: Config.client_id(),
      caps: Config.caps(),
      listen_port: Config.listen_port(),
      node_id: Config.node_id()
    }
  end

  def handshake_sent(session, hello = %Packet.Hello{}) do
    %{session | handshake_sent: hello}
  end

  def handshake_received(session, hello = %Packet.Hello{}) do
    %{session | handshake_received: hello}
  end

  def session_active?(session), do: Session.active?(session)

  def session_compatible?(session), do: Session.compatible_capabilities?(session)

  def handle_message(session, message) do
    case session_active?(session) do
      false ->
        {:error, :handshake_incomplete, session}

      true ->
        response = generate_response(message)
        new_session = update_session(session, message)
        {:ok, response, new_session}
    end
  end

  defp update_session(session, %Packet.Disconnect{}) do
    Session.disconnect(session)
  end

  defp update_session(session, _message), do: session

  defp generate_response(%Packet.Ping{} = ping), do: Packet.Ping.handle(ping)

  defp generate_response(%Packet.Disconnect{} = disconnect),
    do: Packet.Disconnect.handle(disconnect)
end
