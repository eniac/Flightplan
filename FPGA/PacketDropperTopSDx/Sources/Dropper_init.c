#include <stdio.h>
#include <xparameters.h>
#include <xil_io.h>
#include <stdio.h>
#include <xgpiops_hw.h>

#define BUFFER_SIZE (256)

#define ADDR_ETH_0_GT_RESET_REG   (0x80000000)
#define ADDR_ETH_1_GT_RESET_REG   (0x80010000)
#define ADDR_ETH_0_CONFIG_TX_REG1 (0x8000000C)
#define ADDR_ETH_1_CONFIG_RX_REG1 (0x80010014)

// Initializes the packet dropper.
void Initialize(void)
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
}

// Read a line from the serial port.  Lines from the serial console are delimited by carriage returns instead of the
// usual newline character.
void Read_line(char * Buffer, int Size)
{
  int Offset = 0;
  while(Offset < Size - 1)
  {
    int Letter = fgetc(stdin);
    if (Letter == '\r')
      break;
    Buffer[Offset++] = Letter;
  }
  Buffer[Offset] = 0;
}

int main()
{
  // Initialize the packet dropper.
  Initialize();

  // Produce some output to make finding the right device file for the UART easier.
  puts("Hello! I am the packet dropper! Please enter the desired packet drop rate.");

  char * Line = NULL;
  while (1)
  {
    double Rate;
    while (1)
    {
      // Read a line.  
      Read_line(Line, BUFFER_SIZE);

      if (strcmp(Line, "Identify yourself!") == 0)
      {
        puts("I am the packet dropper!");
        continue;
      }

      // Extract a number from the line.
      if (sscanf(Line, "%lf", &Rate) != 1)
      {
        puts("You did not enter a floating point number.  Try again.");
        continue;
      }

      // Check whether the number is inside the interval [0, 1].
      if (Rate >= 0 && Rate <= 1)
        break;
      puts("You have to enter a number in the interval [0, 1].  Try again.");
    }

    // Set packet error rate.
    unsigned Threshold = 0.1 * 0x100000000;
    Threshold = Threshold < 0x100000000 ? Threshold : 0xFFFFFFFF;
    Xil_Out32(XPAR_PACKETDROPPERVIVADO_0_BASEADDR, Threshold);

    // Inform user that rate was changed.
    puts("Consider it done!!!");
  }

  // We should never reach here, but let's return an exit value anyway...
  return 0;
}
