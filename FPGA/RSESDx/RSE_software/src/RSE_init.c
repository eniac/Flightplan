#include <xparameters.h>
#include <xil_io.h>
#include <stdio.h>
#include <xgpiops_hw.h>

#define ADDR_GT_RESET_REG              (XPAR_XXV_ETHERNET_0_BASEADDR + 0x00000000)
#define ADDR_CONFIG_TX_REG1            (XPAR_XXV_ETHERNET_0_BASEADDR + 0x0000000C)
#define ADDR_CONFIG_RX_REG1            (XPAR_XXV_ETHERNET_0_BASEADDR + 0x00000014)
#define ADDR_TICK_REG                  (XPAR_XXV_ETHERNET_0_BASEADDR + 0x00000020)
#define ADDR_STAT_TX_TOTAL_PACKETS_LSB (XPAR_XXV_ETHERNET_0_BASEADDR + 0x00000700)
#define ADDR_STAT_TX_TOTAL_PACKETS_MSB (XPAR_XXV_ETHERNET_0_BASEADDR + 0x00000704)
#define ADDR_STAT_RX_TOTAL_PACKETS_LSB (XPAR_XXV_ETHERNET_0_BASEADDR + 0x00000808)
#define ADDR_STAT_RX_TOTAL_PACKETS_MSB (XPAR_XXV_ETHERNET_0_BASEADDR + 0x0000080C)

int main()
{
	/*
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x18, 1); // EMIO 0 Mask (enable_processing)
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C4, 1); // EMIO 0 Direction
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C8, 1); // EMIO 0 Output enable
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x4C, 1); // EMIO 0 Data - enable

  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C, 0xC0000000); // EMIO 94-95 mask (EMIO 95 is PL reset 0, 94 is PL reset 1)
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x344, 0xC0000000); // EMIO 94-95 direction
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x348, 0xC0000000); // EMIO 94-95 output enable
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x54, 0); // EMIO 94-95 data disable
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x54, 0xC0000000); // EMIO 94-95 data enable

  Xil_Out32(ADDR_GT_RESET_REG, 1); // Reset GT
  Xil_Out32(ADDR_GT_RESET_REG, 0); // Release GT reset
  Xil_Out32(ADDR_CONFIG_TX_REG1, 0x3003); // Enable transmitter
  Xil_Out32(ADDR_CONFIG_RX_REG1, 0x33); // Enable receiver
*/

  // Setup.
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x18, 1); // EMIO 0 Mask
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C4, 1); // EMIO 0 Direction
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C8, 1); // EMIO 0 Output enable
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x2C, 0xC0000000); // EMIO 94-95 mask
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x344, 0xC0000000); // EMIO 94-95 direction
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x348, 0xC0000000); // EMIO 94-95 output enable

  // Disable everything.
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x54, 0x80000000); // EMIO 94-95 data disable
  Xil_Out32(ADDR_GT_RESET_REG, 1); // Reset GT
  Xil_Out32(ADDR_CONFIG_TX_REG1, 0x3002); // Disable transmitter
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x4C, 0); // EMIO 0 Data - disable
  Xil_Out32(ADDR_CONFIG_RX_REG1, 0x32); // Disable receiver

  // Enable everything.
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x54, 0xC0000000); // EMIO 94-95 data enable
  Xil_Out32(ADDR_GT_RESET_REG, 0); // Release GT reset
  Xil_Out32(ADDR_CONFIG_TX_REG1, 0x3003); // Enable transmitter
  XGpioPs_WriteReg(XPAR_XGPIOPS_0_BASEADDR, 0x4C, 1); // EMIO 0 Data - enable
  Xil_Out32(ADDR_CONFIG_RX_REG1, 0x33); // Enable receiver

  while (1)
  {
    Xil_Out32(ADDR_TICK_REG, 1);

    unsigned long long Count = Xil_In32(ADDR_STAT_RX_TOTAL_PACKETS_LSB);
    Count += (unsigned long long) Xil_In32(ADDR_STAT_RX_TOTAL_PACKETS_MSB) << 32;
    printf("Packets received: %llu\n", Count);

    Count = Xil_In32(ADDR_STAT_TX_TOTAL_PACKETS_LSB);
    Count += (unsigned long long) Xil_In32(ADDR_STAT_TX_TOTAL_PACKETS_MSB) << 32;
    printf("Packets sent: %llu\n", Count);
  };

  return 0;
}
