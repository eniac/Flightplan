Since we add another intermediate cache before the MCD server in this example,
we actually see better performance. But the previous test we use fails, because
the behaviour we see is different. To restore the old behaviour, UNIQUE_MATTERS
for complete_mcd_e2e in tests.sh can be used for the old test. Incidentally
that test passes if the packet dropper is disabled. Packet dropping interferes
with the order of packet (which are later reconstructed by the FEC) -- this
might also have an effect with what the MCD server sees (e.g., in terms of GETs
arriving before the corresponding SET).
