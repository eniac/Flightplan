Steps:


    Install the dependencies (see below)
    ./build.sh --mlx5 --mlx4(To enable Mellanox cards)
    sudo ./bind-interfaces.sh
    sudo ./setup-hugetlbfs.sh

Note: You need to bind NICs to DPDK to use them. bind-interfaces.sh does this for all unused NICs (no routing table entry in the system). Use libmoon/deps/dpdk/usertools/dpdk-devbind.py to manage NICs manually.
Dependencies

    gcc >= 4.8
    make
    cmake
    libnuma-dev
    kernel headers (for the DPDK igb-uio driver)
    lspci (for dpdk-devbind.py)
    additional dependencies for Mellanox NICs

Run the following command to install these on Debian/Ubuntu:

sudo apt-get install -y build-essential cmake linux-headers-`uname -r` pciutils libnuma-dev


Things to note:

If you see the error, that no ports are available, make sure that the MoonGen binary in the build directory has suid bit set and ownership as root:$USER.

Also make sure the port number in the testing/{test_case_dir}/execution/cfgs/{test}.yml has the device id set correctly to the mellanox card, in the following line:
moongen:
        host: moongen
        start: 'cd ~/source/MoonGen/ && ./build/MoonGen {0.files.moongen_script.dst} 5 {log} -s100'

In the above example, 5 refers to the port id where the mellanox card is running. To see the port ids, run the code in the start section manually on the moongen host and observer the logs being printed.

Machines tclust1-5 use newer NICs(connectx-4 as compared to connectx-3) and are capable of better capture functionality. 

There are additional parameters in the capture.lua file which can be used to improve performance. 
rxdescs should be increased to 16384
dropEnable should be set to false
tryRecv(bufs, 100) as parameters
