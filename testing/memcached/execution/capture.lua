-- Capture packets on a port with high rate and accurate timestamps
local lm     = require "libmoon"
local device = require "device"
local log    = require "log"
local memory = require "memory"
local stats  = require "stats"
local pcap   = require "pcap"

function configure(parser)
    parser:argument("dev_in", "Device on which to capture from"):args(1):convert(tonumber)
    parser:argument("output", "Pcap file to output logged packets to");
	parser:option("-s --snap-len", "Truncate packets to this size."):convert(tonumber):target("snapLen")
    local args = parser:parse()
    return args
end

function master(args)
    local dev_in = device.config {
        port = args.dev_in,
        dropEnable = false,
        rxDescs = 16384
    }

    device.waitForLinks()

    stats.startStatsTask{rxDevices = {dev_in}}

    lm.startTask("capture", dev_in:getRxQueue(0), args)

    lm.waitForTasks()
end

function capture(rxQueue, args)
    local snapLen = args.snapLen
    local captureCtr = stats:newPktRxCounter("Capture return")
    local output = args.output

    local writer = pcap:newWriter(output)

    local bufs = memory.bufArray()

    while lm.running() do
        local count = rxQueue:tryRecv(bufs, 1000)
	local batchTime = lm.getTime()
        for i = 1, count do
            local buf = bufs[i]
            writer:writeBuf(batchTime, buf, snapLen)
            captureCtr:countPacket(buf)
        end
        bufs:free(count)
    end
    captureCtr:finalize()
    log:info("Flushing rcv only buffers")
    writer:close()
end
