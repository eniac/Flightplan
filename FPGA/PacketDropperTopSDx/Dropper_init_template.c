#include <xparameters.h>
#include <xil_io.h>
#include <stdio.h>
#include <xgpiops_hw.h>

#define ADDR_ETH_0_GT_RESET_REG              (0x80000000)
#define ADDR_ETH_1_GT_RESET_REG              (0x80010000)
#define ADDR_ETH_0_CONFIG_TX_REG1            (0x8000000C)
#define ADDR_ETH_1_CONFIG_RX_REG1            (0x80010014)

int main()
{
  // Setup.
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x18, 1); // EMIO 0 Mask
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C4, 1); // EMIO 0 Direction
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C8, 1); // EMIO 0 Output enable
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C, 0xC0000000); // EMIO 94-95 mask
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x344, 0xC0000000); // EMIO 94-95 direction
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x348, 0xC0000000); // EMIO 94-95 output enable

  // Disable everything.
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x54, 0x80000000); // EMIO 94-95 data disable
  Xil_Out32(ADDR_ETH_0_GT_RESET_REG, 1); // Reset GT
  Xil_Out32(ADDR_ETH_1_GT_RESET_REG, 1); // Reset GT
  Xil_Out32(ADDR_ETH_0_CONFIG_TX_REG1, 0x3002); // Disable transmitter
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x4C, 0); // EMIO 0 Data - disable
  Xil_Out32(ADDR_ETH_1_CONFIG_RX_REG1, 0x32); // Disable receiver

  // Enable everything.
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x54, 0xC0000000); // EMIO 94-95 data enable
  Xil_Out32(ADDR_ETH_0_GT_RESET_REG, 0); // Release GT reset
  Xil_Out32(ADDR_ETH_1_GT_RESET_REG, 0); // Release GT reset
  Xil_Out32(ADDR_ETH_0_CONFIG_TX_REG1, 0x3003); // Enable transmitter
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x4C, 1); // EMIO 0 Data - enable
  Xil_Out32(ADDR_ETH_1_CONFIG_RX_REG1, 0x33); // Enable receiver

  // Set packet error rate.
  unsigned Threshold = RATE * 0x100000000;
  Threshold = Threshold < 0x100000000 ? Threshold : 0xFFFFFFFF;
  Xil_Out32(XPAR_PACKETDROPPERVIVADO_0_BASEADDR, Threshold);

  return 0;
}
