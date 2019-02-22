-- Capture packets on a port and bounce them back out again
local lm     = require "libmoon"
local device = require "device"
local log    = require "log"
local memory = require "memory"
local stats  = require "stats"
local pcap   = require "pcap"

function configure(parser)
    parser:argument("dev", "Device on which to capture and bounce"):args(1):convert(tonumber)
    parser:option("-t --threads", "Number of threads per forwarding direction using RSS."):args(1):convert(tonumber):default(1)
	parser:option("-s --snap-len", "Truncate packets to this size."):convert(tonumber):target("snapLen")
    parser:argument("output", "Pcap file to output logged packets to");
    local args = parser:parse()
    return args
end

function master(args)
    local dev = device.config {
        port = args.dev,
        txQueues = args.threads,
        rxQueues = args.threads,
        rssQueues = args.threads,
        dropEnable = false,
        rxDescs = 8192
    }
    device.waitForLinks()

    stats.startStatsTask{rxDevices = {dev}}

    for i = 1, args.threads do
        lm.startTask("bounce", dev:getRxQueue(i - 1), dev:getTxQueue(i - 1), args, i)
    end

    lm.waitForTasks()
end

function bounce(rxQueue, txQueue, args, threadId)
    local snapLen = args.snapLen
    local captureCtr

    if args.threads > 1 then
        if args.output:match("%.pcap$") then
            args.output = args.output:gsub("%.pcap$", "")
        end
        args.output = args.output .. "-thread-" .. threadId .. ".pcap"
    else
        if not args.output:match("%.pcap$") then
            args.output = args.output .. ".pcap"
        end
    end

    local writer = pcap:newWriter(args.output)
    local captureCtr = stats:newPktRxCounter("Capture, thread #" .. threadId)

    local bufs = memory.bufArray()

    while lm.running() do
        local count = rxQueue:tryRecv(bufs, 100) -- 1000 is timeout (ms)
        local batchTime = lm.getTime()
        for i = 1, count do
            local buf = bufs[i]
            writer:writeBuf(batchTime, buf, snapLen)
            captureCtr:countPacket(buf)
        end
        txQueue:sendN(bufs, count)
    end

    captureCtr:finalize()
    log:info("Flushing buffers, this can take a while...")
    writer:close()
end
