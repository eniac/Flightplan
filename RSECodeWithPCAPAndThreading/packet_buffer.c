#include <stdio.h>
#include <stdlib.h>
#include <sys/timeb.h>

#define MAX_DELAY_BEFORE_PACKET_LOSS_MILLIS 2000
#define SIZE_ETHERNET 14
int SIZE_OF_FEC_BLOCK = 6;


typedef struct fec_header {
  unsigned char blockId;
  unsigned char pktId;
} fec_header_t;

typedef struct fec_blk_buffer_entry{
	char** pkts_in_fec_blk;
	long long recv_timestamp;
	int blockId;
	fec_blk_buffer_entry* next_blk;
	fec_blk_buffer_entry* prev_blk;
	int pending_pkts;
} fec_blk_buffer_entry_t;

fec_blk_buffer_entry_t* fecBufferHead; /*Head pointer to the fec Buffer doubly linked list*/

void insert_packet_into_buffer(char* packet);
void handle_completed_fec_blk(fec_blk_buffer_entry_t *entry);
fec_blk_buffer_entry_t* insert_new_entry_to_buffer(fec_blk_buffer_entry_t* fecBufferHead);
void initialize_block_entry(fec_blk_buffer_entry_t *entry);
void insert_pkt_at_entry(fec_blk_buffer_entry_t* entry, int pktId, char* packet);
fec_blk_buffer_entry_t* entry_for_blockId(int blockId);
int get_block_index_of_pkt(char* packet);
int get_packet_index_in_blk(char* packet);
unsigned long long get_system_time_millis();

int main(int argc, char **argv) {
	fecBufferHead = NULL;
	char* packet ;
	/* Insert the packet into fec buffer and wait for the remaining packets to arrive.*/
	insert_packet_into_buffer(packet);

}

/**
 * @brief      Inserts the specified packet into local fec buffer.
 *
 * @param      packet  The packet
 */
void insert_packet_into_buffer(char* packet) {

	int blockId = get_block_index_of_pkt(packet);
	int pktId = get_packet_index_in_blk(packet);
	fec_blk_buffer_entry_t* entry = NULL;

	/*First check if we have an entry with packet's blockId in the buffer.*/
	if ((entry = entry_for_blockId(blockId)) == NULL) { /*This means that this is a new FEC block*/
		insert_new_entry_to_buffer(fecBufferHead);
	} else {
		insert_pkt_at_entry(entry, pktId, packet);
		/*Check if all the packets in the fec_blk have been received*/
		if (entry->pending_pkts == 0) {
			
		}
	}
}


void handle_completed_fec_blk(fec_blk_buffer_entry_t *entry) {
	if (entry == NULL) {
		return;
	}
	/*TODO: call the encoder and pass it all data packets in this fec_blk*/

	/*TODO: Free the entry for this blk and update the linked List accordingly*/

}


fec_blk_buffer_entry_t* insert_new_entry_to_buffer(fec_blk_buffer_entry_t* fecBufferHead) {
	/*if this is the first entry.*/
	if (fecBufferHead == NULL) {
		fecBufferHead = allocate_memory_for_new_fec_entry();
		initialize_block_entry(fecBufferHead);
		fecBufferHead->prev_blk = NULL;
		return fecBufferHead;
	}

	/*Insert a new entry at the end of the linked list*/
	fec_blk_buffer_entry_t* entry = fecBufferHead;
	while (entry->next_blk != NULL) {
		entry = entry->next_blk;
	}
	fec_blk_buffer_entry_t *new_entry = allocate_memory_for_new_fec_entry();
	entry->next_blk = new_entry
	                  initialize_block_entry(new_entry);
	new_entry->prev_blk = entry;

	return entry->next_blk;
}

void initialize_block_entry(fec_blk_buffer_entry_t *entry) {
	if (entry == NULL) {
		return;
	}

	entry->pkts_in_fec_blk = NULL;
	entry->recv_timestamp = 0;
	entry->blockId = -1;
	entry->next_blk = NULL;
	entry->pending_pkts = SIZE_OF_FEC_BLOCK;
}




/**
 * @brief      Inserts a packet into the fec_blk buffer
 *
 * @param      entry   entry pointer in buffer
 * @param[in]  pktId   The packet id
 * @param      packet  The packet itself
 */
void insert_pkt_at_entry(fec_blk_buffer_entry_t* entry, int pktId, char* packet) {
	/*Insert at the specified index*/
	char** buffered_fec_blk = entry->pkts_in_fec_blk;
	*(buffered_fec_blk + pktId) = packet;
	entry->pending_pkts--;
}

/**
 * @brief      Iterate over buffer and get
 *
 * @param[in]  blockId  The block id
 *
 * @return
 */
fec_blk_buffer_entry_t* entry_for_blockId(int blockId) {
	fec_blk_buffer_entry_t *entry  = fecBufferHead;

	/* Iterate over the buffer and match for blockId*/
	while (entry != NULL) {
		if (entry->blockId == blockId) {
			return entry;
		}
		entry = entry->next_blk;
	}
	return NULL;
}

/**
 * @brief      Gets the block index of packet.
 *
 * @param      packet  The packet
 *
 * @return     The block index of packet.
 */
int get_block_index_of_pkt(char* packet) {
	fec_header_t *fecHeader = (fec_header_t *) (packet + SIZE_ETHERNET);
	return fecHeader->blockId;
}

/**
 * @brief      returns the packet Index within a FEC block for the given packet.
 *
 * @param      packet  The packet
 *
 * @return     The packet index in block.
 */
int get_packet_index_in_blk(char* packet) {
	fec_header_t *fecHeader = (fec_header_t *) (packet + SIZE_ETHERNET);
	return fecHeader->pktId;
}

/**
 * @brief      returns the system time in millis.
 *
 * @return
 */
unsigned long long get_system_time_millis() {
	struct timeb timer_msec;
	long long int timestamp_msec; /* timestamp in millisecond. */

	if (!ftime(&timer_msec)) {
		timestamp_msec = ((long long int) timer_msec.time) * 1000ll +
		                 (long long int) timer_msec.millitm;
	}
	else {
		timestamp_msec = -1;
	}

	return timestamp_msec;
}

/**
 * @brief      Allocates memory for a new fec block
 *
 * @return
 */
fec_blk_buffer_entry_t* allocate_memory_for_new_fec_entry() {
	/* Allocate memory for the buffer entry */
	fec_blk_buffer_entry_t *new_entry = (fec_blk_buffer_entry_t *) malloc(sizeof(fec_blk_buffer_entry_t));
	
	/* Allocate memory for each packet in the buffer entry */
	new_entry->pkts_in_fec_blk = (char** ) malloc( SIZE_OF_FEC_BLOCK * sizeof(char*));

	return new_entry;
}

/**
 * @brief      Frees the memory associated with an fec_buffer_entry
 *
 * @param[in]  entry  The entry
 */
void free_fec_entry(fec_blk_buffer_entry_t *entry) {
	free(entry->pkts_in_fec_blk);
	free(entry);
}
