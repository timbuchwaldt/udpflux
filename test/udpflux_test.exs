defmodule UdpfluxTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = InfluxSender.start_link(%{ip: {127,0,0,1}, port: 4444})
    {:ok, pid: pid}
  end
#
#  test "Adding data to sender", %{pid: pid} do
#    dp = %DataPoint{name: "foo", tags: [host: "sample"], fields: [value: 0.069]}
#    InfluxSender.write_point(pid, dp)
#    InfluxSender.write_point(pid, dp)
#    InfluxSender.write_point(pid, dp)
#    InfluxSender.write_point(pid, dp)
#    :timer.sleep(100)
#  end

  test "encoding packet" do
    dp = %DataPoint{name: "foo", tags: [host: "sample"], fields: [value: 0.069]}
    assert DataPoint.dump(dp) == "foo,host=sample value=0.069"
  end

  test "garbled string encoding" do
    dp = %DataPoint{name: "foo", tags: [host: "sample=bar"], fields: [value: "deine mudder,alda"]}
    assert DataPoint.dump(dp) == "foo,host=sample\\=bar value=\"deine\\ mudder\\,alda\""
  end
end
