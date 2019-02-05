TX_port = 0;
RX_port = 1;

Burst_size = 4;

TX_count = 1000000;

package.path = package.path ..";?.lua;test/?.lua;app/?.lua;";

require "Pktgen";

local function Test_rate(Rate)
  printf("Trying rate %i...\n", Rate);

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
  printf("Received: %i packets\n", RX_count);

  return RX_count >= TX_count;
end

pktgen.set(TX_port, "burst", Burst_size);
pktgen.set(TX_port, "count", TX_count);

Rate = 100;
while not Test_rate(Rate) do
  Rate = Rate - 1;
end

printf("Best rate: %i\n", Rate);

f = assert(io.open("/tmp/Output.txt", "w"));
f:write(Rate);
f:close();

pktgen.quit();

