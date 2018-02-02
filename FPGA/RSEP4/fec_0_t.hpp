#ifndef SDNET_ENGINE_fec_0_t
#define SDNET_ENGINE_fec_0_t

#include "sdnet_lib.hpp"
#include "rse.h"

namespace SDNET {

//######################################################
class fec_0_t { // UserEngine
public:

	// tuple types
	struct fec_input_t {
		static const size_t _SIZE = 410;
		_LV<1> stateful_valid_0;
		_LV<8> operation;
		_LV<32> index;
		_LV<1> is_parity;
		_LV<368> packet;
		fec_input_t& operator=(_LV<410> _x) {
			stateful_valid_0 = _x.slice(409,409);
			operation = _x.slice(408,401);
			index = _x.slice(400,369);
			is_parity = _x.slice(368,368);
			packet = _x.slice(367,0);
			return *this;
		}
		_LV<410> get_LV() { return (stateful_valid_0,operation,index,is_parity,packet); }
		operator _LV<410>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid_0 = " + stateful_valid_0.to_string() + "\n" + "\t\toperation = " + operation.to_string() + "\n" + "\t\tindex = " + index.to_string() + "\n" + "\t\tis_parity = " + is_parity.to_string() + "\n" + "\t\tpacket = " + packet.to_string() + "\n" + "\t)";
		}
		fec_input_t() {} 
		fec_input_t( _LV<1> _stateful_valid_0, _LV<8> _operation, _LV<32> _index, _LV<1> _is_parity, _LV<368> _packet) {
			stateful_valid_0 = _stateful_valid_0;
			operation = _operation;
			index = _index;
			is_parity = _is_parity;
			packet = _packet;
		}
	};
	struct fec_output_t {
		static const size_t _SIZE = 368;
		_LV<368> result_0;
		fec_output_t& operator=(_LV<368> _x) {
			result_0 = _x.slice(367,0);
			return *this;
		}
		_LV<368> get_LV() { return (result_0); }
		operator _LV<368>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tresult_0 = " + result_0.to_string() + "\n" + "\t)";
		}
		fec_output_t() {} 
		fec_output_t( _LV<368> _result_0) {
			result_0 = _result_0;
		}
	};

	// engine members
	std::string _name;
	fec_input_t fec_input;
	fec_output_t fec_output;


	// TODO: ***************************
	// TODO: *** USER ENGINE MEMBERS ***
	// TODO: ***************************

	// engine ctor
	fec_0_t(std::string _n, std::string _filename = "") : _name(_n) {

		// TODO: **********************************
		// TODO: *** USER ENGINE INITIALIZATION ***
		// TODO: **********************************
	  	int ret = rse_init();
		std::cout<< "[P4] rse init result: "<<ret<<std::endl;      

	}

#define FEC_QUEUE_NUMBER 8
#define FEC_PARITY_NUMBER 4

#define FEC_PAYLOAD_SIZE 256
#define ETH_HEADER_SIZE 112
#define FEC_PACKET_SIZE 368
#define VETH_HEADER_SIZE 136
#define FEC_ENCODED_PACKET_SIZE 504

#define PARITY_FLAG (1<<23)
#define VID_MASK 0x7fffff

#define OP_PREPARE_ENCODING (1<<0)
#define OP_ENCODE           (1<<1)
#define OP_GET_ENCODED      (1<<2)
#define OP_PREPARE_DECODING (1<<3)
#define OP_DECODE           (1<<4)
#define OP_GET_DECODED      (1<<5) 

	// engine function
	void operator()() {
		if (fec_input.stateful_valid_0.to_ulong() == 0)
			return;
		std::cout << "===================================================================" << std::endl;
		std::cout << "Entering engine " << _name << std::endl;
		// input and inout tuples:
		std::cout << "initial input and inout tuples:" << std::endl;
		std::cout << "	fec_input = " << fec_input.to_string() << std::endl;
		// clear internal and output-only tuples:
		std::cout << "clear internal and output-only tuples" << std::endl;
		fec_output = 0;
		std::cout << "	fec_output = " << fec_output.to_string() << std::endl;

		// TODO: *********************************
		// TODO: *** USER ENGINE FUNCTIONALITY ***
		// TODO: *********************************

		unsigned long op = fec_input.operation.to_ulong();
		unsigned long index = fec_input.index.to_ulong();
		unsigned long len = FEC_PACKET_SIZE/sizeof(fec_sym)/8;
		unsigned long is_parity = fec_input.is_parity.to_ulong();

		if (op & OP_PREPARE_ENCODING)
		{

			if (fb.pdata[0] == nullptr)
			{
				for (int i=0; i<FEC_QUEUE_NUMBER+FEC_PARITY_NUMBER; i++)
				{
					fb.pdata[i] = new fec_sym[len];
				}
				fb.block_C = len;
				fb.block_N = FEC_QUEUE_NUMBER+FEC_PARITY_NUMBER;
			}
			fec_sym* p = fb.pdata[index];


			for (int i = 0; i<len; i++)
			{
				p[i] = (fec_sym) fec_input.packet.slice(FEC_PACKET_SIZE-(i*8)-1,FEC_PACKET_SIZE-(i*8)-8).to_ulong();
			}

			fb.pdata[index] = p;
			fb.cbi[index] = index;
			fb.plen[index] = len;
			fb.pstat[index] = FEC_FLAG_KNOWN;
			std::cout<< "[P4] Encoder: stored a packet at position " << index<<std::endl;


			fec_sym y = FEC_QUEUE_NUMBER + index;                                  /* FEC block index */
			fec_sym z = FEC_MAX_N - index - 1;             /* Codeword index */
//			fb.pdata[y] = p;
			fb.cbi[y] = z;
			fb.plen[y] = fb.block_C;
			fb.pstat[y] = FEC_FLAG_WANTED;

		}

		if (op & OP_ENCODE)
		{
			rse_code(1);
			fec_block_print();
//			rse_block_delete();
//			fec_block_print();
			for (int i=0; i<FEC_QUEUE_NUMBER; i++)
			{
				delete[] fb.pdata[i];
				fb.pdata[i] = nullptr;
			}
		}

		if (op & OP_GET_ENCODED)
		{
			std::cout<<"[P4] index = "<<index<<std::endl;
			std::string s = "";
			fec_sym* p = fb.pdata[index];
			for (int i = 0; i<len; i++)
			{
				s = s + _LV<8>(p[i]).to_hex();
				std::cout<<_LV<8>(p[i]).to_hex();
			}
			std::cout<<s<<std::endl;
			fec_output.result_0 = _LV<FEC_PACKET_SIZE>(s,16); // 16 is base......
//			fec_output.is_parity = index >= FEC_QUEUE_NUMBER ? _LV<1>(1) : _LV<1>(0);

			delete[] fb.pdata[index];
			fb.pdata[index] = nullptr;
		}

		if (op & OP_PREPARE_DECODING)
		{
			if (fb.pdata[0] == nullptr)
			{
				for (int i=0; i<FEC_QUEUE_NUMBER+FEC_PARITY_NUMBER; i++)
				{
					fb.pdata[i] = new fec_sym[len];
				}
				fb.block_C = len;
				fb.block_N = FEC_QUEUE_NUMBER+FEC_PARITY_NUMBER;
			}
			fec_sym* p = fb.pdata[index];

			for (int i = 0; i<len; i++)
			{
				p[i] = (fec_sym) fec_input.packet.slice(FEC_PACKET_SIZE-(i*8)-1,FEC_PACKET_SIZE-(i*8)-8).to_ulong();
			}

			if (index < FEC_QUEUE_NUMBER)
			{
				fb.pdata[index] = p;
				fb.cbi[index] = index;
				fb.plen[index] = len;
				if (index % 2 == 1)
				{
					fb.pstat[index] = FEC_FLAG_WANTED;
					fb.pdata[index][0] = 0;
					fb.pdata[index][1] = 0;
					fb.pdata[index][2] = 0;
					fb.pdata[index][3] = 0;
				}
				else
				{
					fb.pstat[index] = FEC_FLAG_KNOWN;
				}
				std::cout<< "[P4] Decoder: stored a packet at position " << index<<std::endl;
			}
			else
			{
				fec_sym bias = index - 5;
				fec_sym z = FEC_MAX_N - bias - 1;             /* Codeword index */
				fb.cbi[index] = z;
				fb.plen[index] = fb.block_C;
				fb.pstat[index] = FEC_FLAG_KNOWN;
				std::cout<< "[P4] Decoder: stored a parity packet at position " << index<<std::endl;
			}

		}

		if (op & OP_DECODE)
		{
			fec_block_print();
			rse_code(1);
			fec_block_print();
		}

		if (op & OP_GET_DECODED)
		{

			std::cout<<"[P4] index = "<<index<<std::endl;
			std::string s = "";
			fec_sym* p = fb.pdata[index];
			for (int i = 0; i<len; i++)
			{
				s = s + _LV<8>(p[i]).to_hex();
			}
			std::cout<<s<<std::endl;
			fec_output.result_0 = _LV<FEC_PACKET_SIZE>(s,16);

			delete[] fb.pdata[index];
			fb.pdata[index] = nullptr;

		}

		// inout and output tuples:
		std::cout << "final inout and output tuples:" << std::endl;
		std::cout << "	fec_output = " << fec_output.to_string() << std::endl;
		std::cout << "Exiting engine " << _name << std::endl;
		std::cout << "===================================================================" << std::endl;
	}
};
//######################################################
// top-level DPI function
extern "C" void fec_0_t_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_fec_0_t
