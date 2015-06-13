defmodule UdpfluxTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = UDPFlux.Sender.start_link(%{ip: {127,0,0,1}, port: 4444})
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

  # that is rather hacky and I should really write a UDP acceptor that validates my message
  test "data sending doesn't crash instantly", %{pid: pid} do
    dp = %UDPFlux.DataPoint{name: "foo", tags: [host: "sample=bar"], fields: [value: "deine mudder,alda"]}
    UDPFlux.Sender.write_point(pid, dp)
    # wait for the message to be evaluated
    :timer.sleep(30)
    assert Process.alive?(pid)
  end
end
