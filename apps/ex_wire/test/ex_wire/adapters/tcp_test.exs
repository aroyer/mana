defmodule ExWire.Adapter.TCPTest do
  use ExUnit.Case
  doctest ExWire.Adapter.TCP
  alias ExWire.Adapter.TCP

  describe "generate_auth_creadentials/1" do
    test "generates and adds encoded auth data" do
      state =
        build_peer()
        |> new_state()
        |> TCP.generate_auth_credentials()

      assert state.auth_data
      assert is_binary(state.auth_data)
    end

    test "generates and adds ephemeral key pair" do
      state =
        build_peer()
        |> new_state()
        |> TCP.generate_auth_credentials()

      assert {key1, key2} = state.my_ephemeral_key_pair
      assert is_binary(key1)
      assert is_binary(key2)
    end

    test "adds nonce to state" do
      state =
        build_peer()
        |> new_state()
        |> TCP.generate_auth_credentials()

      assert state.my_nonce
      assert is_binary(state.my_nonce)
    end
  end

  def new_state(peer) do
    %{peer: peer}
  end

  def build_peer do
    ExWire.Struct.Peer.new(
      "13.84.180.240",
      30303,
      "6ce05930c72abc632c58e2e4324f7c7ea478cec0ed4fa2528982cf34483094e9cbc9216e7aa349691242576d552a2a56aaeae426c5303ded677ce455ba1acd9d"
    )
  end
end
