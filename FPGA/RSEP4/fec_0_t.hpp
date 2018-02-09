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
		static const size_t _SIZE = 37;
		_LV<1> stateful_valid;
		_LV<4> operation;
		_LV<16> index;
		_LV<16> data_offset;
		fec_input_t& operator=(_LV<37> _x) {
			stateful_valid = _x.slice(36,36);
			operation = _x.slice(35,32);
			index = _x.slice(31,16);
			data_offset = _x.slice(15,0);
			return *this;
		}
		_LV<37> get_LV() { return (stateful_valid,operation,index,data_offset); }
		operator _LV<37>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid = " + stateful_valid.to_string() + "\n" + "\t\toperation = " + operation.to_string() + "\n" + "\t\tindex = " + index.to_string() + "\n" + "\t\tdata_offset = " + data_offset.to_string() + "\n" + "\t)";
		}
		fec_input_t() {} 
		fec_input_t( _LV<1> _stateful_valid, _LV<4> _operation, _LV<16> _index, _LV<16> _data_offset) {
			stateful_valid = _stateful_valid;
			operation = _operation;
			index = _index;
			data_offset = _data_offset;
		}
	};
	struct fec_output_t {
		static const size_t _SIZE = 1;
		_LV<1> result;
		fec_output_t& operator=(_LV<1> _x) {
			result = _x.slice(0,0);
			return *this;
		}
		_LV<1> get_LV() { return (result); }
		operator _LV<1>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tresult = " + result.to_string() + "\n" + "\t)";
		}
		fec_output_t() {} 
		fec_output_t( _LV<1> _result) {
			result = _result;
		}
	};
	struct CONTROL_STRUCT {
		static const size_t _SIZE = 37;
		_LV<14> offset;
		_LV<14> virtual_offset;
		_LV<4> section;
		_LV<1> activeBank;
		_LV<1> done;
		_LV<3> error;
		CONTROL_STRUCT& operator=(_LV<37> _x) {
			offset = _x.slice(36,23);
			virtual_offset = _x.slice(22,9);
			section = _x.slice(8,5);
			activeBank = _x.slice(4,4);
			done = _x.slice(3,3);
			error = _x.slice(2,0);
			return *this;
		}
		_LV<37> get_LV() { return (offset,virtual_offset,section,activeBank,done,error); }
		operator _LV<37>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\toffset = " + offset.to_string() + "\n" + "\t\tvirtual_offset = " + virtual_offset.to_string() + "\n" + "\t\tsection = " + section.to_string() + "\n" + "\t\tactiveBank = " + activeBank.to_string() + "\n" + "\t\tdone = " + done.to_string() + "\n" + "\t\terror = " + error.to_string() + "\n" + "\t)";
		}
		CONTROL_STRUCT() {} 
		CONTROL_STRUCT( _LV<14> _offset, _LV<14> _virtual_offset, _LV<4> _section, _LV<1> _activeBank, _LV<1> _done, _LV<3> _error) {
			offset = _offset;
			virtual_offset = _virtual_offset;
			section = _section;
			activeBank = _activeBank;
			done = _done;
			error = _error;
		}
	};

	// engine members
	std::string _name;
	Packet packet_in;
	Packet packet_out;
	CONTROL_STRUCT control;
	fec_input_t fec_input;
	fec_output_t fec_output;


	// TODO: ***************************
	// TODO: *** USER ENGINE MEMBERS ***
	// TODO: ***************************

#define FEC_QUEUE_NUMBER 8
#define FEC_PARITY_NUMBER 4
#define ETH_MTU (200)

#define OP_START_ENCODER	(1<<0)
#define OP_ENCODE_PACKET	(1<<1)
#define OP_GET_ENCODED 		(1<<2)

	// engine ctor
	fec_0_t(std::string _n, std::string _filename = "") : _name(_n) {

		// TODO: **********************************
		// TODO: *** USER ENGINE INITIALIZATION ***
		// TODO: **********************************
	  	int ret = rse_init();
		std::cout<< "[P4] rse init result: "<<ret<<std::endl;      
	}

	// engine function
	void operator()() {
		if (fec_input.stateful_valid.to_ulong() == 0)
		{
			control.done = 1;
			return;
		}
		std::cout << "===================================================================" << std::endl;
		std::cout << "Entering engine " << _name << std::endl;
		// input packet
		std::cout << "input packet (" << packet_in.size() << " bytes)" << std::endl;
		std::cout << packet_in;
		// input and inout tuples:
		std::cout << "initial input and inout tuples:" << std::endl;
		std::cout << "	control = " << control.to_string() << std::endl;
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
		unsigned long offset = fec_input.data_offset.to_ulong();
		fec_sym* p;

		std::cerr<<"packet size = "<<packet_in.size()<<std::endl;
		packet_out = packet_in;

		if (op & OP_START_ENCODER)
		{
			int ret = rse_init();
			std::cout<< "[P4] rse init result: "<<ret<<std::endl;      

			for (int i=0; i<FEC_QUEUE_NUMBER+FEC_PARITY_NUMBER; i++)
			{
				if (fb.pdata[i] != nullptr)
				{
					delete fb.pdata[i];
					fb.pdata[i] = nullptr;
				}
				fb.pdata[i] = new fec_sym[ETH_MTU];
			}

			fb.block_C = ETH_MTU;
			fb.block_N = FEC_QUEUE_NUMBER+FEC_PARITY_NUMBER;
		}

		if (op & OP_ENCODE_PACKET)
		{

			p = fb.pdata[index];

			/*[!] assuming fec_sym is 8 bits wide */
			for (int i = 0; i<packet_in.size(); i++)
			{
				p[i] = (fec_sym) packet_in[i];
			}

			fb.cbi[index] = index;
			fb.plen[index] = packet_in.size();
			fb.pstat[index] = FEC_FLAG_KNOWN;
			std::cout<< "[P4] Encoder: stored a packet at position " << index<<std::endl;


			fec_sym y = FEC_QUEUE_NUMBER + index;                                  /* FEC block index */
			fec_sym z = FEC_MAX_N - index - 1;             /* Codeword index */
			fb.cbi[y] = z;
			fb.plen[y] = fb.block_C;
			fb.pstat[y] = FEC_FLAG_WANTED;

			if (index == FEC_QUEUE_NUMBER-1)
			{
				rse_code(1);
				fec_block_print();
			}
		}

		if (op & OP_GET_ENCODED)
		{
			std::cout<<"[P4] offset = "<<offset<<std::endl;
			p = fb.pdata[index];
			int packet_size = packet_out.size();
			for (int i = offset/8; i<packet_size; i++)
			{
				packet_out.pop_back();
			}
			for (int i = 0; i<packet_size - 2; i++)
			{
				packet_out.push_back(p[i]);
			}
		}
	
		control.done = 1;

		// inout and output tuples:
		std::cout << "final inout and output tuples:" << std::endl;
		std::cout << "	control = " << control.to_string() << std::endl;
		std::cout << "	fec_output = " << fec_output.to_string() << std::endl;
		// output packet
		std::cout << "output packet (" << packet_out.size() << " bytes)" << std::endl;
		std::cout << packet_out;
		std::cout << "Exiting engine " << _name << std::endl;
		std::cout << "===================================================================" << std::endl;
	}
};
//######################################################
// top-level DPI function
extern "C" void fec_0_t_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_fec_0_t
