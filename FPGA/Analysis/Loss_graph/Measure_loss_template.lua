TX_port = 0;
RX_port = 1;

Burst_size = 4;
Rate = RATE;

TX_count = 1000000;

package.path = package.path ..";?.lua;test/?.lua;app/?.lua;";

require "Pktgen";

pktgen.set(TX_port, "burst", Burst_size);

f = assert(io.open("/tmp/Output.txt", "w"));

for i = 1, REPETITIONS
do
  -- Flush remaining packets.
  pktgen.set(TX_port, "count", 1);
  while true do
    pktgen.clear("all");
    pktgen.start(TX_port);
    pktgen.delay(1000);
    RX_count = pktgen.portStats(RX_port, "port")[RX_port]["ipackets"];
    if RX_count > 0 then
      break;
    end
  end

  pktgen.clear("all");
  pktgen.set(TX_port, "count", TX_count);
  pktgen.set(TX_port, "rate", Rate);
  pktgen.start(TX_port);

  while pktgen.isSending(TX_port) == "y" or
        pktgen.portStats(RX_port, "port")[RX_port]["ipackets"] == 0 do
    pktgen.delay(10);
  end
  pktgen.delay(1000);

  RX_count = pktgen.portStats(RX_port, "port")[RX_port]["ipackets"];
  Loss = 1 - RX_count / TX_count

  printf("Loss: %f\n", Loss);

  f:write(", ");
  f:write(Loss);
end

f:close();

pktgen.quit();

