#UdpFlux
[![Build Status](https://travis-ci.org/timbuchwaldt/udpflux.svg)](https://travis-ci.org/timbuchwaldt/udpflux) [![Coverage Status](https://coveralls.io/repos/timbuchwaldt/udpflux/badge.svg)](https://coveralls.io/r/timbuchwaldt/udpflux)


This is an opinionated InfluxDB client, built to only work with InfluxDB 0.9 and it's UDP line protocol.

It's meant to instantly ship available events off to InfluxDB, taking the risk of loosing events due to UDP usage. It also let's InfluxDB decide upon the timestamp, as I can't be bothered to make sure the clocks are all fine ;)

# Usage

1. Instantiate the InfluxSender GenServer: `{:ok, pid} = InfluxSender.start_link(%{ip: {127,0,0,1}, port: 4444})`
2. Create events: `point = %DataPoint{name: "foo", tags: [key: "value"], fields: [value: 0.069]}`
3.  Ship events: `InfluxSender.write_point(pid, point)`
4. Done. The point is now racing to the InfluxDB specified. Make sure to configure it correctly, the values below work for me

```
[udp]
  enabled = true
  bind-address = "0.0.0.0:4444"
  database = "foo"
  batch-size = 100
  batch-timeout = "10ms"
```

Those values basically mean: Accept UDP on any IP and port 4444, write points to the DB "foo", wait up to 10ms or a batch of up to 100 data points. Whichever comes first triggers a write.
