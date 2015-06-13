defmodule UdpfluxTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = UDPFlux.Sender.start_link(%{ip: {127,0,0,1}, port: 2808})
    {:ok, pid: pid}
  end

  test "encoding packet" do
    dp = %UDPFlux.DataPoint{name: "foo", tags: [host: "sample"], fields: [value: 0.069]}
    assert UDPFlux.DataPoint.dump(dp) == "foo,host=sample value=0.069"
  end

  test "garbled string encoding" do
    dp = %UDPFlux.DataPoint{name: "foo", tags: [host: "sample=bar"], fields: [value: "deine mudder,alda"]}
    assert UDPFlux.DataPoint.dump(dp) == "foo,host=sample\\=bar value=\"deine\\ mudder\\,alda\""
  end

  test "data sending doesn't crash instantly", %{pid: pid} do
    # Create test-listener that delivers by sending a message to self
    {:ok, socket_acceptor} = :gen_udp.open(2808)
    :inet.setopts(socket_acceptor, [active: :once])
    # we want messages as binaries (utf8-strings)
    :inet.setopts(socket_acceptor, [mode: :binary])

    dp = %UDPFlux.DataPoint{name: "foo", tags: [host: "sample=bar"], fields: [value: "deine mudder,alda"]}
    UDPFlux.Sender.write_point(pid, dp)

    # receive UDP datagram
    d = receive do
      {:udp, _port, _src_ip, _src_port, data} -> data
    end

    assert d == "foo,host=sample\\=bar value=\"deine\\ mudder\\,alda\""
    assert Process.alive?(pid)
  end
end
