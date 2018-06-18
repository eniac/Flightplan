export VIVADO_HLS_ROOT=/opt/Xilinx/SDx/2017.1/Vivado_HLS
cd Encoder/XilinxSwitch/XilinxSwitch.TB/
ln -s ../MemcachedVivadoHLS/MemHLS.cpp
ln -s ../MemcachedVivadoHLS/MemHLS.h
ln -s ../memcachedVivadoHLS/Memcore.h
./compile.bash
if [!-n "$1"]; then
	./XilinxSwitch > output.log
else 
	./XilinxSwitch $1 > output.log
fi
vim output.log
cd ../../../
