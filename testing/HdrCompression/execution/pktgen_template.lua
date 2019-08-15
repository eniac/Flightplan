txPort = "0";
maxDuration = 20000;
pktgen.delay(100);

pktgen.set(txPort, "rate", $rate);
pktgen.pcap(txPort, "on");
pktgen.set(txPort, "burst", 1);
pktgen.set(txPort, "count", $count);

pktgen.delay(100);


pktgen.start(txPort);
pktgen.delay(maxDuration);
pktgen.stop(txPort);

pktgen.quit();
