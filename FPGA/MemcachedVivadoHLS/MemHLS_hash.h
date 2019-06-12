#ifndef MEMHLS_HASH_H_
#define MEMHLS_HASH_H_

inline uint16_t hash(Data_Word Data)
{
#pragma HLS inline
	Data_Word temp = Data;
	uint16_t result = 0;
	Data = (~Data) + (Data << 21);
	Data = Data ^ (Data >> 24);
	Data = (Data + (Data << 3)) + (Data << 8);
	Data = Data ^ (Data >> 14);
	Data = (Data + (Data << 2)) + (Data << 4);
	Data = Data ^ (Data >> 28);
	Data = Data + (Data << 31);
	result = (uint16_t) (Data % MAX_MEMORY_SIZE);
	result ^= temp.range(16,0);
	result %= MAX_MEMORY_SIZE;
	return result;
}

#endif
