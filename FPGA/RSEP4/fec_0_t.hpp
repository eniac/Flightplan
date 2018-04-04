#ifndef SDNET_ENGINE_fec_0_t
#define SDNET_ENGINE_fec_0_t

#include "sdnet_lib.hpp"
#include "rse.h"

namespace SDNET {

#define BUFFER_SIZE (FEC_MAX_PACKET_SIZE + FEC_PACKET_LENGTH_SIZE / 8)

//######################################################
class fec_0_t { // UserEngine
public:

	// tuple types
	struct fec_input_t {
		static const size_t _SIZE = 12;
		_LV<1> stateful_valid;
		_LV<3> operation;
		_LV<8> index;
		fec_input_t& operator=(_LV<12> _x) {
			stateful_valid = _x.slice(11,11);
			operation = _x.slice(10,8);
			index = _x.slice(7,0);
			return *this;
		}
		_LV<12> get_LV() { return (stateful_valid,operation,index); }
		operator _LV<12>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid = " + stateful_valid.to_string() + "\n" + "\t\toperation = " + operation.to_string() + "\n" + "\t\tindex = " + index.to_string() + "\n" + "\t)";
		}
		fec_input_t() {} 
		fec_input_t( _LV<1> _stateful_valid, _LV<3> _operation, _LV<8> _index) {
			stateful_valid = _stateful_valid;
			operation = _operation;
			index = _index;
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

	int maximum_packet_size;

	// engine ctor
	fec_0_t(std::string _n, std::string _filename = "") : _name(_n) {

	  	int ret = rse_init();
		std::cout<< "[P4] rse init result: "<<ret<<std::endl;      
	}

	// engine function
	void operator()() {
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

		if (fec_input.stateful_valid.to_ulong() == 1)
		{
			unsigned long op = fec_input.operation.to_ulong();
			unsigned long index = fec_input.index.to_ulong();
			fec_sym* p;

			std::cerr<<"packet size = "<<packet_in.size()<<std::endl;
			packet_out = packet_in;

			if (op & FEC_OP_START_ENCODER)
			{
				int ret = rse_init();
				std::cout<< "[P4] rse init result: "<<ret<<std::endl;      

				for (int i=0; i<FEC_K+FEC_H; i++)
				{
					if (fb.pdata[i] != nullptr)
					{
						delete fb.pdata[i];
						fb.pdata[i] = nullptr;
					}
					fb.pdata[i] = new fec_sym[BUFFER_SIZE];
					for (int j = 0; j < BUFFER_SIZE; j++)
						fb.pdata[i][j] = 0;
				}

				fb.block_C = BUFFER_SIZE;
				fb.block_N = FEC_K+FEC_H;

				maximum_packet_size = 0;
			}

			if (op & FEC_OP_ENCODE_PACKET)
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

				if (packet_in.size() > maximum_packet_size)
					maximum_packet_size = packet_in.size();

				fec_sym y = FEC_K + index;                                  /* FEC block index */
				fec_sym z = FEC_MAX_N - index - 1;             /* Codeword index */
				fb.cbi[y] = z;
				fb.pstat[y] = FEC_FLAG_WANTED;

				if (index == FEC_K-1)
				{
					rse_code(1);
					fec_block_print();
				}
			}

			if (op & FEC_OP_GET_ENCODED)
			{
				p = fb.pdata[index];
				int packet_size = packet_out.size();
				for (int i = (FEC_ETH_HEADER_SIZE + FEC_HEADER_SIZE) / 8; i<packet_size; i++)
				{
					packet_out.pop_back();
				}
				for (int i = FEC_MAX_PACKET_SIZE; i < BUFFER_SIZE; i++)
                                {
					packet_out.push_back(p[i]);
                                }
				for (int i = 0; i<maximum_packet_size; i++)
				{
					packet_out.push_back(p[i]);
				}
			}
		}
		else
		{
			packet_out = packet_in;
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
