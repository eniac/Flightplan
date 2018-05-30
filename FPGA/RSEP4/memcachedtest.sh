ln ../../MemCode/Memcore.c ./Encoder/XilinxSwitch/XilinxSwitch.TB/Memcore.cpp
ln ../../MemCode/Memcore.h ./Encoder/XilinxSwitch/XilinxSwitch.TB/Memcore.h
ln ../../MemCode/capture.pcap ./Encoder/XilinxSwitch/XilinxSwitch.TB/Packet.user
cd Encoder/XilinxSwitch/XilinxSwitch.TB/
sudo ./compile.bash
sudo ./XilinxSwitch > output.log
