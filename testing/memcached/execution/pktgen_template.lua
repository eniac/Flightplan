txPort = "0";
maxDuration = 40000;
pktgen.delay(100);

pktgen.set(txPort, "rate", $rate);
pktgen.pcap(txPort, "on");
pktgen.set(txPort, "burst", 4);
pktgen.set(txPort, "count", $count);

pktgen.delay(100);


pktgen.start(txPort);
pktgen.delay(maxDuration);
pktgen.stop(txPort);

pktgen.delay(2000);
pktgen.set(txPort, "rate", $rate);
pktgen.set(txPort, "count", 50000000);
pktgen.start(txPort);
pktgen.delay(3000);
rates = pktgen.portStats(txPort, "rate");
prints("port rates: ", rates[0]);

logfile = io.open("$logfile", "w");
logfile:write("Rate: " .. rates[0]["pkts_tx"]);
logfile:close();

pktgen.stop(txPort);
pktgen.quit();
