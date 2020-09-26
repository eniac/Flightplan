# Using WeMo "smart plugs" for Scripted Power Measurement.

Nik Sultana, October 2019. r1


Steps
-----
1. Setup the WeMos: add them to a WiFi network through which you can contact them using the scripts described below. Find out which ports to which the WeMos respond for queries.
2. Update script configuration to include the WeMo's MAC addresses and ports, and execute script to start polling power data.
3. Analyse the polled power data.
4. Inevitably, problem-solve.
Each step above is expanded into its own section next.


Setup WeMos
-----------
Use Belkin's instructions for setting up WeMos:
see [here](https://www.belkin.com/us/p/P-F7C029/)
and [here](https://www.belkin.com/us/support-article?articleNum=80142).
Setting them up involves adding the WeMos to a WiFi network. The WeMos need
to be assigned IP addresses on this network, either statically or using DHCP.
I used a WiFi router for this, so the network looked a bit like this:
```
WeMos <--WiFi--> WiFi Router <--Wired--> Gathering
```
Here "Gathering" was a special host I use to run the scripts to poll the WeMos
through the WiFi network.
You need to find out which TCP port the WeMos respond to. See the [config file](config.sh)
for examples. Different versions of WeMos seem to respond on different ports.


Update+Execute Scripts
----------------------
1. Update config.sh to include the MAC address and port for each WeMo. We ignore IP addresses since these might change, but the MAC address won't.
2. Run get_macs.sh to resolve MAC addresses into IP addresses for the scripts to use.
3. Start the script to gather power readings. It'll append to file. You can use `power_read.sh` or `power_read_all.sh`. The first takes a parameter that indicates the index of the WeMo you're interested, as listed in config.sh.


Results
-------
Results are produced in this format, consisting of a timestamp, user-given name (in config.sh), current IP address, and power measurement in Watts.
```
  2019-08-02 16:11:23.387821482+00:00 fpga12/1 (192.168.1.106): 25.325
  2019-08-02 16:11:23.562930265+00:00 fpga12/1 (192.168.1.106): 25.325
  2019-08-02 16:11:23.746549888+00:00 fpga12/1 (192.168.1.106): 25.325
```


Problems
--------
Oh where to begin.
I didn't find this to be terribly useful: https://www.belkin.com/us/support-article?articleNum=44526
Here are some of the issues that were encountered:

* Script is killed. Needs to be restarted. Can set up automatic detection for script dying.

* Do upgrade firmware -- for this you need to set up Internet forwarding. See https://www.belkin.com/us/support-article?articleNum=27353

* Friendly name switches to "Pool filter". We cannot rely on it, so best to rely on MAC address.

* If you use DHCP the lease might expire. Run get_macs.sh to refresh.

* Sometimes the WeMos go unresponsive.
  It turns out that if you look at the WeMo's using the phone app, it
  somehow adjusts their configuration in ways that I wasn't able to do
  physically or using my scripts -- and athus WeMo's that previously
  refused to give power readings started happly complying. I think there's
  something that the phone app might be doing to adjust their state. Such
  voodoo.

* Sensor is returning inconsistent results -- changing baseline. Not sure if this is from the sensor or from the target, I only saw it happen with a single target.
* Sensor jumps to over 1.5KW:
```
  2019-08-02 16:11:23.387821482+00:00 fpga12/1 (192.168.1.106): 25.325
  2019-08-02 16:11:23.562930265+00:00 fpga12/1 (192.168.1.106): 25.325
  2019-08-02 16:11:23.746549888+00:00 fpga12/1 (192.168.1.106): 25.325
  2019-08-02 16:11:23.928790098+00:00 fpga12/1 (192.168.1.106): 25.325
  2019-08-02 16:11:24.103981501+00:00 fpga12/1 (192.168.1.106): 6483.200
  2019-08-02 16:11:24.277098493+00:00 fpga12/1 (192.168.1.106): 6483.200
  2019-08-02 16:11:24.447230902+00:00 fpga12/1 (192.168.1.106): 6483.200
  2019-08-02 16:11:24.615985346+00:00 fpga12/1 (192.168.1.106): 6483.200
  2019-08-02 16:11:24.792511869+00:00 fpga12/1 (192.168.1.106): 6483.200
  2019-08-02 16:11:24.959588810+00:00 fpga12/1 (192.168.1.106): 6483.200
  2019-08-02 16:11:25.131847355+00:00 fpga12/1 (192.168.1.106): 25.315
  2019-08-02 16:11:25.304187629+00:00 fpga12/1 (192.168.1.106): 25.315
  2019-08-02 16:11:25.487454070+00:00 fpga12/1 (192.168.1.106): 25.315
```

* the WeMo's server seems to crash after a while (days or weeks) -- the WeMo continues to respond to pings, but the web server (or beyond) stops responding.

* when the WeMo starts it takes a couple of minutes before it starts producing readings -- until then the power reading is 0. Once it has started, the power readings are pretty much instantaneous -- I polled it at 500ms intervals. This means that our automation must first check that readings are being made before running any experiments for which we want power readings.

* MAC printed on the device's label doesn't always match the hardware's MAC.

* There are different versions of the device, having different firmware versions. As mentioned above, they listen on different ports for queries or commands. These issues might be fixed by firmware updates, or not:
  - If a device only draws a couple of watts of power, this might fall under a threshold in the WeMo since it thinks that the plug isn't actually relaying to anything.
  - If a plug isn't connected to anything, the app gets confused whether the plug is actually on or off.
