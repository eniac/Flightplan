#include <iostream>
#include <cstdlib>

int main()
{
  unsigned short lfsr = 1;

  int Count[100];
  for (int i = 0; i < 100; i++)
    Count[i] = 0;

  int Length = 0;
  for (int i = 0; i < 0x10000; i++)
  {
    if (lfsr < 0x10000 * 0.1)
    {
      Length++;
    }
    else
    {
      Count[Length]++;
      Length = 0;
    }
    lfsr = (lfsr << 1) | (((lfsr >> 15) ^ (lfsr >> 13) ^ (lfsr >> 12) ^ (lfsr >> 10)) & 1);
  }
  if (Length > 0)
    Count[Length]++;

  for (int i = 0; i < 100; i++)
    std::cout << i << ": " << Count[i] << '\n';

  return 0;
}

