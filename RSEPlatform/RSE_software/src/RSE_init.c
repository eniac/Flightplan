#include <xparameters.h>
#include <xil_io.h>
#include <stdio.h>

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
  Xil_Out32(ADDR_CONFIG_RX_REG1, 0x33);
  Xil_Out32(ADDR_CONFIG_TX_REG1, 0x3003);
  Xil_Out32(ADDR_GT_RESET_REG, 1);
  Xil_Out32(ADDR_GT_RESET_REG, 0);

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
