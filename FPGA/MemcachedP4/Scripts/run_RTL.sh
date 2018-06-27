cd memcached_0_t.HDL
rm *.v
ln -s ../../../Sources/memcached_0_t.v .
ln -s ../../../../MemcachedVivadoHLS/MemcachedHLS/solution2/syn/verilog/*.v .
cd ..
./vivado_sim_waveform.bash
