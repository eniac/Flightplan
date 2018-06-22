cd ./XilinxSwitch.TB
./compile.bash
cd ..
if [!-n "$1"]; then
	./XilinxSwitch Packet.user > o.log
else
	./XilinxSwitch $1 > o.log
fi

