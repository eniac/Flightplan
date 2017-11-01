export PROGPATH=`pwd`
export PROGNAME=boostFilter
cd ~/bf-sde-5.0.*
# cd ~/bf_sdk/bf-sde-5.0.1.21
export SDE=`pwd`
export SDE_INSTALL=$SDE/install
export PATH=$SDE_INSTALL/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$SDE_INSTALL/lib:$LD_LIBRARY_PATH
cd -