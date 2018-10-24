#!/bin/bash -e

ENCODER_SDX_DIR=/scratch/safe/giesen/DComp/Repository/Encoder_large_buf/FPGA/RSESDxDualMAC
DROPPER_SDX_DIR=/scratch/safe/giesen/DComp/Repository/P4Boosters/FPGA/PacketDropperTopSDx
DECODER_SDX_DIR=/scratch/safe/giesen/DComp/Repository/Decoder_large_buf/FPGA/RSESDxDualMAC

DPDK_DIR=/scratch/safe/giesen/dpdk/

SCRIPT_DIR=${PWD}

ENCODER_TARGET=jsn-JTAG-SMT2NC-210308A47676
DROPPER_TARGET=jsn-JTAG-SMT2NC-210308A5EE07
DECODER_TARGET=jsn-JTAG-SMT2NC-210308A5F0D3

SEND_RATES="50 max"
LOSS_RATES="0.001 0.003 0.01 0.03 0.1"
REPETITIONS=20


Run_command()
{
  cd $1
  shift
  while true
  do
    $* && break
  done
}

echo
echo "Programming encoder..."
echo "======================"
echo
Run_command ${ENCODER_SDX_DIR} ./Run_project.bash ${ENCODER_TARGET}

sleep 1

echo
echo "Programming packet dropper..."
echo "============================="
echo
Run_command ${DROPPER_SDX_DIR} ./Run_project.bash ${DROPPER_TARGET}

sleep 1

echo
echo "Programming decoder..."
echo "======================"
echo
Run_command ${DECODER_SDX_DIR} ./Run_project.bash ${DECODER_TARGET}

sleep 1

echo
echo "Programming drop rate to 0..."
echo "============================="
echo
Run_command ${DROPPER_SDX_DIR} ./Set_rate.bash 0 ${DROPPER_TARGET}

echo
echo "Measuring maximum transmission rate without loss..."
echo "==================================================="
echo
cd ${DPDK_DIR}
./Run_script.bash ${SCRIPT_DIR}/Measure_throughput.lua
MAX_RATE=$(cat /tmp/Output.txt)
sudo rm /tmp/Output.txt

rm -f ${SCRIPT_DIR}/Loss.csv
for SEND_RATE in ${SEND_RATES}
do
  if [ "${SEND_RATE}" == "max" ]
  then
    SEND_RATE=${MAX_RATE}
  fi

  echo
  echo "Setting transmission rate to ${SEND_RATE}..."
  echo "========================================"
  echo
  sed -e "s/RATE/${SEND_RATE}/g" -e "s/REPETITIONS/${REPETITIONS}/g" ${SCRIPT_DIR}/Measure_loss_template.lua > ${SCRIPT_DIR}/Measure_loss.lua

  for LOSS_RATE in ${LOSS_RATES}
  do
    echo
    echo "Programming drop rate to ${LOSS_RATE}..."
    echo "========================================"
    echo
    Run_command ${DROPPER_SDX_DIR} ./Set_rate.bash ${LOSS_RATE} ${DROPPER_TARGET}

    echo
    echo "Measuring loss..."
    echo "================="
    echo
    cd ${DPDK_DIR}
    ./Run_script.bash ${SCRIPT_DIR}/Measure_loss.lua
    RESULT=$(cat /tmp/Output.txt)
    sudo rm /tmp/Output.txt

    echo "${SEND_RATE}, ${LOSS_RATE}${RESULT}" >> ${SCRIPT_DIR}/Loss.csv
  done
done

