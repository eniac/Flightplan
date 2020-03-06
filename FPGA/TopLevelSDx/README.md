# Programming FPGAs

At the moment, the FPGAs are only programmable from tclust2. It is connected to all five of the FPGAs.

This document: https://github.com/eniac/P4Boosters/blob/master/testing/e2e/e2e.md#fpgas
give the serial numbers of each of the FPGAs.

To program an FPGA, issue

```shell`
./Run_project.bash <ProjectName> <SerialNumber>
```

ProjectName must match a directory in this folder which contains the bitstream.

I **believe** that the only subdirectory that must be present in the `ProjectName/`
directory is `HW`, however I am not certain if that is the case.
(Below, there is a pasted list of all of the files that are currently present in a sample
ProjectName tree, which are certainly sufficient)

A list of the serial numbers is available here: https://github.com/eniac/P4Boosters/blob/master/testing/e2e/e2e.md#fpgas

For an example, view `program_decoder.sh`

Finally, the following lines are added to my .bashrc file, and I believe that they are necessary for running the xilinx toolchain to program the FPGAs.
```shell
export LM_LICENSE_FILE=2100@potato.cis.upenn.edu
export SDNET_ROOT=/opt/Xilinx/SDx/2017.1/
export SDSOC_ROOT=/opt/Xilinx/SDx/2017.1/
export PATH=$PATH:/opt/Xilinx/SDx/2017.1/bin/
```

### Sample ProjectName directory

```shell
Compressor1Port
├── BSP
│   ├── Makefile
│   ├── psu_cortexa53_0
│   │   ├── code
│   │   ├── include
│   │   │   ├── bspconfig.h
│   │   │   ├── sleep.h
│   │   │   ├── vectors.h
│   │   │   ├── xaxipmon.h
│   │   │   ├── xaxipmon_hw.h
│   │   │   ├── xbasic_types.h
│   │   │   ├── xcoresightpsdcc.h
│   │   │   ├── xcpu_cortexa53.h
│   │   │   ├── xcsudma.h
│   │   │   ├── xcsudma_hw.h
│   │   │   ├── xddrcpsu.h
│   │   │   ├── xddr_xmpu0_cfg.h
│   │   │   ├── xddr_xmpu1_cfg.h
│   │   │   ├── xddr_xmpu2_cfg.h
│   │   │   ├── xddr_xmpu3_cfg.h
│   │   │   ├── xddr_xmpu4_cfg.h
│   │   │   ├── xddr_xmpu5_cfg.h
│   │   │   ├── xdebug.h
│   │   │   ├── xenv.h
│   │   │   ├── xenv_standalone.h
│   │   │   ├── xfpd_slcr.h
│   │   │   ├── xfpd_slcr_secure.h
│   │   │   ├── xfpd_xmpu_cfg.h
│   │   │   ├── xfpd_xmpu_sink.h
│   │   │   ├── xgpiops.h
│   │   │   ├── xgpiops_hw.h
│   │   │   ├── xil_assert.h
│   │   │   ├── xil_cache.h
│   │   │   ├── xil_cache_vxworks.h
│   │   │   ├── xil_exception.h
│   │   │   ├── xil_hal.h
│   │   │   ├── xil_io.h
│   │   │   ├── xil_macroback.h
│   │   │   ├── xil_mem.h
│   │   │   ├── xil_mmu.h
│   │   │   ├── xil_printf.h
│   │   │   ├── xil_smc.h
│   │   │   ├── xil_testcache.h
│   │   │   ├── xil_testio.h
│   │   │   ├── xil_testmem.h
│   │   │   ├── xil_types.h
│   │   │   ├── xiou_secure_slcr.h
│   │   │   ├── xiou_slcr.h
│   │   │   ├── xipipsu.h
│   │   │   ├── xipipsu_hw.h
│   │   │   ├── xlpd_slcr.h
│   │   │   ├── xlpd_slcr_secure.h
│   │   │   ├── xlpd_xppu.h
│   │   │   ├── xlpd_xppu_sink.h
│   │   │   ├── xocm_xmpu_cfg.h
│   │   │   ├── xparameters.h
│   │   │   ├── xparameters_ps.h
│   │   │   ├── xplatform_info.h
│   │   │   ├── xpseudo_asm_gcc.h
│   │   │   ├── xpseudo_asm.h
│   │   │   ├── xreg_cortexa53.h
│   │   │   ├── xrtcpsu.h
│   │   │   ├── xrtcpsu_hw.h
│   │   │   ├── xscugic.h
│   │   │   ├── xscugic_hw.h
│   │   │   ├── xstatus.h
│   │   │   ├── xsysmonpsu.h
│   │   │   ├── xsysmonpsu_hw.h
│   │   │   ├── xtime_l.h
│   │   │   ├── xzdma.h
│   │   │   └── xzdma_hw.h
│   │   ├── lib
│   │   │   └── libxil.a
│   │   └── libsrc
│   │       ├── axipmon_v6_5
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       ├── xaxipmon.c
│   │       │       ├── xaxipmon_g.c
│   │       │       ├── xaxipmon.h
│   │       │       ├── xaxipmon_hw.h
│   │       │       ├── xaxipmon_selftest.c
│   │       │       └── xaxipmon_sinit.c
│   │       ├── coresightps_dcc_v1_4
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       ├── xcoresightpsdcc.c
│   │       │       └── xcoresightpsdcc.h
│   │       ├── cpu_cortexa53_v1_3
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       └── xcpu_cortexa53.h
│   │       ├── csudma_v1_1
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       ├── xcsudma.c
│   │       │       ├── xcsudma_g.c
│   │       │       ├── xcsudma.h
│   │       │       ├── xcsudma_hw.h
│   │       │       ├── xcsudma_intr.c
│   │       │       ├── xcsudma_selftest.c
│   │       │       └── xcsudma_sinit.c
│   │       ├── ddrcpsu_v1_1
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       └── xddrcpsu.h
│   │       ├── generic_v2_0
│   │       │   └── src
│   │       ├── gpiops_v3_2
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       ├── xgpiops.c
│   │       │       ├── xgpiops_g.c
│   │       │       ├── xgpiops.h
│   │       │       ├── xgpiops_hw.c
│   │       │       ├── xgpiops_hw.h
│   │       │       ├── xgpiops_intr.c
│   │       │       ├── xgpiops_selftest.c
│   │       │       └── xgpiops_sinit.c
│   │       ├── ipipsu_v2_2
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       ├── xipipsu.c
│   │       │       ├── xipipsu_g.c
│   │       │       ├── xipipsu.h
│   │       │       ├── xipipsu_hw.h
│   │       │       └── xipipsu_sinit.c
│   │       ├── rtcpsu_v1_4
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       ├── xrtcpsu.c
│   │       │       ├── xrtcpsu_g.c
│   │       │       ├── xrtcpsu.h
│   │       │       ├── xrtcpsu_hw.h
│   │       │       ├── xrtcpsu_intr.c
│   │       │       ├── xrtcpsu_selftest.c
│   │       │       └── xrtcpsu_sinit.c
│   │       ├── scugic_v3_6
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       ├── xscugic.c
│   │       │       ├── xscugic_g.c
│   │       │       ├── xscugic.h
│   │       │       ├── xscugic_hw.c
│   │       │       ├── xscugic_hw.h
│   │       │       ├── xscugic_intr.c
│   │       │       ├── xscugic_selftest.c
│   │       │       └── xscugic_sinit.c
│   │       ├── standalone_v6_2
│   │       │   └── src
│   │       │       ├── abort.c
│   │       │       ├── abort.o
│   │       │       ├── asm_vectors.o
│   │       │       ├── asm_vectors.S
│   │       │       ├── boot.o
│   │       │       ├── boot.S
│   │       │       ├── bspconfig.h
│   │       │       ├── changelog.txt
│   │       │       ├── close.c
│   │       │       ├── close.o
│   │       │       ├── config.make
│   │       │       ├── errno.c
│   │       │       ├── errno.o
│   │       │       ├── _exit.c
│   │       │       ├── _exit.o
│   │       │       ├── fcntl.c
│   │       │       ├── fcntl.o
│   │       │       ├── fstat.c
│   │       │       ├── fstat.o
│   │       │       ├── getpid.c
│   │       │       ├── getpid.o
│   │       │       ├── inbyte.c
│   │       │       ├── inbyte.o
│   │       │       ├── includes_ps
│   │       │       │   ├── xddr_xmpu0_cfg.h
│   │       │       │   ├── xddr_xmpu1_cfg.h
│   │       │       │   ├── xddr_xmpu2_cfg.h
│   │       │       │   ├── xddr_xmpu3_cfg.h
│   │       │       │   ├── xddr_xmpu4_cfg.h
│   │       │       │   ├── xddr_xmpu5_cfg.h
│   │       │       │   ├── xfpd_slcr.h
│   │       │       │   ├── xfpd_slcr_secure.h
│   │       │       │   ├── xfpd_xmpu_cfg.h
│   │       │       │   ├── xfpd_xmpu_sink.h
│   │       │       │   ├── xiou_secure_slcr.h
│   │       │       │   ├── xiou_slcr.h
│   │       │       │   ├── xlpd_slcr.h
│   │       │       │   ├── xlpd_slcr_secure.h
│   │       │       │   ├── xlpd_xppu.h
│   │       │       │   ├── xlpd_xppu_sink.h
│   │       │       │   └── xocm_xmpu_cfg.h
│   │       │       ├── initialise_monitor_handles.c
│   │       │       ├── initialise_monitor_handles.o
│   │       │       ├── isatty.c
│   │       │       ├── isatty.o
│   │       │       ├── kill.c
│   │       │       ├── kill.o
│   │       │       ├── lseek.c
│   │       │       ├── lseek.o
│   │       │       ├── Makefile
│   │       │       ├── _open.c
│   │       │       ├── open.c
│   │       │       ├── _open.o
│   │       │       ├── open.o
│   │       │       ├── outbyte.c
│   │       │       ├── outbyte.o
│   │       │       ├── print.c
│   │       │       ├── print.o
│   │       │       ├── putnum.c
│   │       │       ├── putnum.o
│   │       │       ├── read.c
│   │       │       ├── read.o
│   │       │       ├── _sbrk.c
│   │       │       ├── sbrk.c
│   │       │       ├── _sbrk.o
│   │       │       ├── sbrk.o
│   │       │       ├── sleep.c
│   │       │       ├── sleep.h
│   │       │       ├── sleep.o
│   │       │       ├── translation_table.o
│   │       │       ├── translation_table.S
│   │       │       ├── uart.c
│   │       │       ├── uart.o
│   │       │       ├── unlink.c
│   │       │       ├── unlink.o
│   │       │       ├── vectors.c
│   │       │       ├── vectors.h
│   │       │       ├── vectors.o
│   │       │       ├── write.c
│   │       │       ├── write.o
│   │       │       ├── xbasic_types.h
│   │       │       ├── xdebug.h
│   │       │       ├── xenv.h
│   │       │       ├── xenv_standalone.h
│   │       │       ├── xil_assert.c
│   │       │       ├── xil_assert.h
│   │       │       ├── xil_assert.o
│   │       │       ├── xil_cache.c
│   │       │       ├── xil_cache.h
│   │       │       ├── xil_cache.o
│   │       │       ├── xil_cache_vxworks.h
│   │       │       ├── xil-crt0.o
│   │       │       ├── xil-crt0.S
│   │       │       ├── xil_exception.c
│   │       │       ├── xil_exception.h
│   │       │       ├── xil_exception.o
│   │       │       ├── xil_hal.h
│   │       │       ├── xil_io.c
│   │       │       ├── xil_io.h
│   │       │       ├── xil_io.o
│   │       │       ├── xil_macroback.h
│   │       │       ├── xil_mem.c
│   │       │       ├── xil_mem.h
│   │       │       ├── xil_mem.o
│   │       │       ├── xil_mmu.c
│   │       │       ├── xil_mmu.h
│   │       │       ├── xil_mmu.o
│   │       │       ├── xil_printf.c
│   │       │       ├── xil_printf.h
│   │       │       ├── xil_printf.o
│   │       │       ├── xil_smc.c
│   │       │       ├── xil_smc.h
│   │       │       ├── xil_smc.o
│   │       │       ├── xil_testcache.c
│   │       │       ├── xil_testcache.h
│   │       │       ├── xil_testcache.o
│   │       │       ├── xil_testio.c
│   │       │       ├── xil_testio.h
│   │       │       ├── xil_testio.o
│   │       │       ├── xil_testmem.c
│   │       │       ├── xil_testmem.h
│   │       │       ├── xil_testmem.o
│   │       │       ├── xil_types.h
│   │       │       ├── xparameters_ps.h
│   │       │       ├── xplatform_info.c
│   │       │       ├── xplatform_info.h
│   │       │       ├── xplatform_info.o
│   │       │       ├── xpseudo_asm_gcc.h
│   │       │       ├── xpseudo_asm.h
│   │       │       ├── xreg_cortexa53.h
│   │       │       ├── xstatus.h
│   │       │       ├── xtime_l.c
│   │       │       ├── xtime_l.h
│   │       │       └── xtime_l.o
│   │       ├── sysmonpsu_v2_1
│   │       │   └── src
│   │       │       ├── Makefile
│   │       │       ├── xsysmonpsu.c
│   │       │       ├── xsysmonpsu_g.c
│   │       │       ├── xsysmonpsu.h
│   │       │       ├── xsysmonpsu_hw.h
│   │       │       ├── xsysmonpsu_intr.c
│   │       │       ├── xsysmonpsu_selftest.c
│   │       │       └── xsysmonpsu_sinit.c
│   │       └── zdma_v1_2
│   │           └── src
│   │               ├── Makefile
│   │               ├── xzdma.c
│   │               ├── xzdma_g.c
│   │               ├── xzdma.h
│   │               ├── xzdma_hw.h
│   │               ├── xzdma_intr.c
│   │               ├── xzdma_selftest.c
│   │               └── xzdma_sinit.c
│   └── system.mss
├── HW
│   ├── design_1_bd.tcl
│   ├── design_1.hwh
│   ├── design_1_system_ila_0_0_bd.tcl
│   ├── design_1_system_ila_0_0.hwh
│   ├── design_1_system_ila_1_0_bd.tcl
│   ├── design_1_system_ila_1_0.hwh
│   ├── design_1_wrapper.bit
│   ├── design_1_wrapper.mmi
│   ├── psu_init.c
│   ├── psu_init_gpl.c
│   ├── psu_init_gpl.h
│   ├── psu_init.h
│   ├── psu_init.html
│   ├── psu_init.tcl
│   ├── sysdef.xml
│   ├── system.hdf
│   └── system.hwdef
├── SDK.log
└── SW
    ├── Debug
    │   ├── makefile
    │   ├── objects.mk
    │   ├── sources.mk
    │   ├── src
    │   │   ├── Init.d
    │   │   ├── Init.o
    │   │   └── subdir.mk
    │   ├── SW.elf
    │   └── SW.elf.size
    └── src
        ├── Init.c
        ├── lscript.ld
        └── README.txt

38 directories, 301 files
```
