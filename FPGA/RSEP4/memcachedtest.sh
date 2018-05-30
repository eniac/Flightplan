ln -s ../../MemCode/Memcore.c ./Encoder/XilinxSwitch/XilinxSwitch.TB/Memcore.cpp
ln -s ../../MemCode/Memcore.h ./Encoder/XilinxSwitch/XilinxSwitch.TB/Memcore.h
ln -s ../../MemCode/capture.pcap ./Encoder/XilinxSwitch/XilinxSwitch.TB/Packet.user
cd Encoder/XilinxSwitch/XilinxSwitch.TB/
sudo ./compile.bash
sudo ./XilinxSwitch > output.log
