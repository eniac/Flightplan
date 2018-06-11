################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../solution1/.autopilot/db/MemHLS.pragma.1.cpp 

OBJS += \
./.reference/MemHLS.pragma.1.o 

CPP_DEPS += \
./.reference/MemHLS.pragma.1.d 


# Each subdirectory must supply rules for building sources it contributes
.reference/MemHLS.pragma.1.o: /home/zhaoyang/Summer/P4Boosters/FPGA/MemcachedVivadoHLS/MemcachedHLS/solution1/.autopilot/db/MemHLS.pragma.1.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -DAESL_TB -D__llvm__ -D__llvm__ -I/opt/Xilinx/SDx/2017.1/Vivado_HLS/include/ap_sysc -I/opt/Xilinx/SDx/2017.1/Vivado_HLS/lnx64/tools/auto_cc/include -I/opt/Xilinx/SDx/2017.1/Vivado_HLS/lnx64/tools/systemc/include -I/opt/Xilinx/SDx/2017.1/Vivado_HLS/include/etc -I/opt/Xilinx/SDx/2017.1/Vivado_HLS/include -I/home/zhaoyang/Summer/P4Boosters/FPGA/MemcachedVivadoHLS -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


