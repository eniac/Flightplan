-- Capture packets on a port and bounce them back out again
local lm     = require "libmoon"
local device = require "device"
local log    = require "log"
local memory = require "memory"
local stats  = require "stats"
local pcap   = require "pcap"

function configure(parser)
    parser:argument("dev_in", "Device on which to capture retransmit from"):args(1):convert(tonumber)
    parser:argument("dev_out", "Device on which to capture retransmit to"):args(1):convert(tonumber)
    parser:argument("output_in", "Pcap file to output logged packets to");
    parser:argument("output_out", "Pcap file to output logged packets to");
    parser:option("-t --threads", "Number of threads per forwarding direction using RSS."):args(1):convert(tonumber):default(1)
	parser:option("-s --snap-len", "Truncate packets to this size."):convert(tonumber):target("snapLen")
    local args = parser:parse()
    return args
end

function master(args)
    local dev_in = device.config {
        port = args.dev_in,
        txQueues = args.threads,
        rxQueues = args.threads,
        rssQueues = args.threads,
        dropEnable = false,
        rxDescs = 8192
    }
    local dev_out = device.config {
        port = args.dev_out,
        txQueues = args.threads,
        rxQueues = args.threads,
        rssQueues = args.threads,
        dropEnable = false,
        rxDescs = 8192
    }
    device.waitForLinks()

    stats.startStatsTask{rxDevices = {dev_in, dev_out}}

    for i = 1, args.threads do
        lm.startTask("bounce", dev_in:getRxQueue(i - 1), dev_out:getTxQueue(i - 1), args, i)
        lm.startTask("capture", dev_out:getRxQueue(i - 1), args, i)
    end

    lm.waitForTasks()
end

function capture(rxQueue, args, threadId)
    local snapLen = args.snapLen
    local captureCtr
    local output = args.output_out

    if args.threads > 1 then
        if output:match("%.pcap$") then
            output = output:gsub("%.pcap$", "")
        end
        output = output .. "-thread-" .. threadId .. ".pcap"
    else
        if not output:match("%.pcap$") then
            output = output .. ".pcap"
        end
    end

    local writer = pcap:newWriter(output)
    local captureCtr = stats:newPktRxCounter("Capture return, thread #" .. threadId)

    local bufs = memory.bufArray()

    while lm.running() do
        local count = rxQueue:tryRecv(bufs, 100)
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



function bounce(rxQueue, txQueue, args, threadId)
    local snapLen = args.snapLen
    local captureCtr
    local output = args.output_in

    if args.threads > 1 then
        if output:match("%.pcap$") then
            output = output:gsub("%.pcap$", "")
        end
        output = output .. "-thread-" .. threadId .. ".pcap"
    else
        if not output:match("%.pcap$") then
            output = output .. ".pcap"
        end
    end

    local writer = pcap:newWriter(output)
    local captureCtr = stats:newPktRxCounter("Capture bounce, thread #" .. threadId)

    local bufs = memory.bufArray()

    while lm.running() do
        local count = rxQueue:tryRecv(bufs, 100) -- 100 is timeout (ms)
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
