ifndef DISPLAY
  $(error Despite SDx is used in batch mode, you have to set the DISPLAY environment variable.)
endif

.PHONY: All RSEEncoder1Port RSEDecoder1Port Memcached1Port RSEEncoder2Ports RSEDecoder2Ports Memcached2Ports \
        PacketDropper2Ports

All: RSEEncoder1Port RSEDecoder1Port Memcached1Port RSEEncoder2Ports RSEDecoder2Ports Memcached2Ports \
        PacketDropper2Ports

RSEEncoder1Port:
	rm -fr RSEEncoder1Port
	source $SDSOC_ROOT/settings64.sh
	sdx -batch -source ./Build_project.tcl $PWD RSEEncoder1Port

RSEDecoder1Port:
	rm -fr RSEDecoder1Port
	source $SDSOC_ROOT/settings64.sh
	sdx -batch -source ./Build_project.tcl $PWD RSEDecoder1Port

Memcached1Port:
	rm -fr Memcached1Port
	source $SDSOC_ROOT/settings64.sh
	sdx -batch -source ./Build_project.tcl $PWD Memcached1Port

RSEEncoder2Ports:
	rm -fr RSEEncoder2Ports
	source $SDSOC_ROOT/settings64.sh
	sdx -batch -source ./Build_project.tcl $PWD RSEncoder2Ports

RSEDecoder2Ports:
	rm -fr RSEDecoder2Ports
	source $SDSOC_ROOT/settings64.sh
	sdx -batch -source ./Build_project.tcl $PWD RSEDecoder2Ports

Memcached2Ports:
	rm -fr Memcached2Ports
	source $SDSOC_ROOT/settings64.sh
	sdx -batch -source ./Build_project.tcl $PWD Memcached2Ports

PacketDropper2Ports:
	rm -fr PacketDropper2Ports
	source $SDSOC_ROOT/settings64.sh
	sdx -batch -source ./Build_project.tcl $PWD PacketDropper2Ports

clean:
	rm -fr RSEEncoder1Port RSEDecoder1Port Memcached1Port RSEEncoder2Ports RSEDecoder2Ports Memcached2Ports PacketDropper2Ports

