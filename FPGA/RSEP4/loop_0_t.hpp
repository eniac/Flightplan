#ifndef SDNET_ENGINE_loop_0_t
#define SDNET_ENGINE_loop_0_t

#include "sdnet_lib.hpp"

#include "Configuration.h"

namespace SDNET {

//######################################################
class loop_0_t { // UserEngine
public:

	// tuple types
	struct loop_input_t {
		static const size_t _SIZE = 10;
		_LV<1> stateful_valid_0;
		_LV<1> addr;
		_LV<8> max;
		loop_input_t& operator=(_LV<10> _x) {
			stateful_valid_0 = _x.slice(9,9);
			addr = _x.slice(8,8);
			max = _x.slice(7,0);
			return *this;
		}
		_LV<10> get_LV() { return (stateful_valid_0,addr,max); }
		operator _LV<10>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid_0 = " + stateful_valid_0.to_string() + "\n" + "\t\taddr = " + addr.to_string() + "\n" + "\t\tmax = " + max.to_string() + "\n" + "\t)";
		}
		loop_input_t() {} 
		loop_input_t( _LV<1> _stateful_valid_0, _LV<1> _addr, _LV<8> _max) {
			stateful_valid_0 = _stateful_valid_0;
			addr = _addr;
			max = _max;
		}
	};
	struct loop_output_t {
		static const size_t _SIZE = 8;
		_LV<8> result_0;
		loop_output_t& operator=(_LV<8> _x) {
			result_0 = _x.slice(7,0);
			return *this;
		}
		_LV<8> get_LV() { return (result_0); }
		operator _LV<8>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tresult_0 = " + result_0.to_string() + "\n" + "\t)";
		}
		loop_output_t() {} 
		loop_output_t( _LV<8> _result_0) {
			result_0 = _result_0;
		}
	};

	// engine members
	std::string _name;
	loop_input_t loop_input;
	loop_output_t loop_output;


	// TODO: ***************************
	// TODO: *** USER ENGINE MEMBERS ***
	// TODO: ***************************
	_LV<FEC_PACKET_INDEX_WIDTH> reg[FEC_REG_COUNT];

	// engine ctor
	loop_0_t(std::string _n, std::string _filename = "") : _name(_n) {

		// TODO: **********************************
		// TODO: *** USER ENGINE INITIALIZATION ***
		// TODO: **********************************
		for (int i = 0; i < FEC_REG_COUNT; i++)
		{
			reg[i] = 0;
		}
	}

	// engine function
	void operator()() {
		std::cout << "===================================================================" << std::endl;
		std::cout << "Entering engine " << _name << std::endl;
		// input and inout tuples:
		std::cout << "initial input and inout tuples:" << std::endl;
		std::cout << "	loop_input = " << loop_input.to_string() << std::endl;
		// clear internal and output-only tuples:
		std::cout << "clear internal and output-only tuples" << std::endl;
		loop_output = 0;
		std::cout << "	loop_output = " << loop_output.to_string() << std::endl;

		// TODO: *********************************
		// TODO: *** USER ENGINE FUNCTIONALITY ***
		// TODO: *********************************

		unsigned long addr =loop_input.addr.to_ulong();

		loop_output.result_0 = reg[addr];

		reg[addr] = reg[addr] + 1;
		if (reg[addr].to_ulong() >= loop_input.max.to_ulong())
			reg[addr] = 0;

		// inout and output tuples:
		std::cout << "final inout and output tuples:" << std::endl;
		std::cout << "	loop_output = " << loop_output.to_string() << std::endl;
		std::cout << "Exiting engine " << _name << std::endl;
		std::cout << "===================================================================" << std::endl;
	}
};
//######################################################
// top-level DPI function
extern "C" void loop_0_t_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_loop_0_t
