-- send 512 B packet out of port 0, measure port 1 throughput rx rate once every 100 ms, save to log.

-- Config --
txPort = "0" -- out port.
rxPort = "1" -- in port.
benchmarkDuration = 60
delayInterval = 1000 -- how long to wait between checking current bit-rate.

-- Setup -- 
print("starting throughput benchmark\n");
file = io.open("throughput.txt", "w");

-- pktgen.screen("off"); -- uncomment this to shut the info screen off.
pktgen.set(txPort, "rate", 99); -- set tx rate.
pktgen.set(txPort, "size", 512); -- set tx pkt size.
pktgen.start(txPort);

-- Run the benchmark -- 
file:write("ts,Mbps\n");
print("ts, Mbps");
getRates = function (ts)
	-- prints("rates", pktgen.portStats("0", "rate"));
	file:write(ts .. ", " .. pktgen.portStats(rxPort, "rate")[tonumber(rxPort)].mbits_rx .. "\n");
	print(ts .. ", " .. pktgen.portStats(rxPort, "rate")[tonumber(rxPort)].mbits_rx);
	pktgen.delay(delayInterval);
end

for i=1,benchmarkDuration,1 do getRates(i) end

-- stop --
pktgen.stop(txPort);
for i=benchmarkDuration,benchmarkDuration+3,1 do getRates(i) end
-- Teardown --
file:close();
print("benchmark done.");
pktgen.screen("on");
pktgen.quit();