echo "Compiling..."
cd ./XilinxSwitch.TB
./compile.bash
cd ..
if [ "$1" ];then
	XilinxSwitch.TB/XilinxSwitch $1 > o.log
else
	XilinxSwitch.TB/XilinxSwitch > o.log
fi

