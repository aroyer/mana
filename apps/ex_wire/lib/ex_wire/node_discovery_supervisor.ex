defmodule ExWire.NodeDiscoverySupervisor do
  use Supervisor

  @moduledoc """
  The Node Discovery Supervisor manages two processes. The first process is kademlia
  algorithm's routing table state - ExWire.Kademlia.Server,  the second one is process
  that sends and receives all messages that are used for node discovery (ping, pong etc)
  """

  alias ExWire.Kademlia.Server, as: KademliaServer
  alias ExWire.Kademlia.Node
  alias ExWire.{Network, Config}
  alias ExWire.Struct.Endpoint

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_params) do
    {udp_module, udp_process_name} = Config.udp_network_adapter()

    children = [
      {KademliaServer,
       [name: KademliaState, current_node: current_node(), network_client_name: NetworkClient]},
      {udp_module,
       [name: udp_process_name, network_module: {Network, []}, port: Config.listen_port()]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end

  def current_node do
    udp_port = Config.listen_port()
    public_ip = Config.public_ip()
    public_key = Config.public_key()
    endpoint = %Endpoint{ip: public_ip, udp_port: udp_port}

    Node.new(public_key, endpoint)
  end
end
