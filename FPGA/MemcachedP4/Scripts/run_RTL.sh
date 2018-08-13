cd memcached_0_t.HDL
rm *.v
ln -s ../../../Sources/memcached_0_t.v .
cp  ../../../../MemcachedVivadoHLS/Batch/MemcachedVivadoHLS/solution2/syn/verilog/*.v .
cd ..
./vivado_sim.bash
