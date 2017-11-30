# set paths and start script
cd $PROGPATH/control
export PATH=$SDE_INSTALL/bin:$PATH
export PYTHONPATH=$SDE_INSTALL/lib/python2.7/site-packages/p4testutils:$SDE_INSTALL/lib/python2.7/site-packages/tofinopd/:$SDE_INSTALL/lib/python2.7/site-packages/tofino:$SDE_INSTALL/lib/python2.7/site-packages/:$PYTHONPATH
python controlScript.py
