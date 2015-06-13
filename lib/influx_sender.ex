defmodule UDPFlux.Sender do
  use GenServer

  def write_point(pid, point) do
    GenServer.cast(pid, {:write_point, point})
  end

  def start_link(server) do
    # Expects server-hash: %{ip: {127,0,0,1}, port: 4444}
    GenServer.start_link(__MODULE__, server)
  end


  def init(server) do
    # Initialize UDP-Socket to random port
    {:ok, socket} = :gen_udp.open(0)
    {:ok, %{server: server, socket: socket}}
  end


  def handle_cast({:write_point, point}, %{socket: socket, server: server}) do
    binary_representation = UDPFlux.DataPoint.dump(point)
    send_buffer(binary_representation, socket, server)
    {:noreply, %{socket: socket, server: server}}
  end


  def send_buffer(buffer, socket, server) do
    :gen_udp.send(socket, server.ip, server.port, buffer)
  end

end
