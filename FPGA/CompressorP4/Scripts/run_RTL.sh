cd headerCompress_0_t.HDL
#rm *.v
#ln -s ../../../Sources/headerCompress_0_t.v .
cp  ../../../../CompressorVivadoHLS/Batch/MemcachedVivadoHLS/solution2/syn/verilog/*.v .
cd ..
./vivado_sim.bash
