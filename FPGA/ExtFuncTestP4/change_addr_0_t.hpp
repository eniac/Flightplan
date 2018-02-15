#ifndef SDNET_ENGINE_change_addr_0_t
#define SDNET_ENGINE_change_addr_0_t

#include "sdnet_lib.hpp"

namespace SDNET {

//######################################################
class change_addr_0_t { // UserEngine
public:

	// tuple types
	struct change_addr_input_t {
		static const size_t _SIZE = 49;
		_LV<1> stateful_valid;
		_LV<48> addr1;
		change_addr_input_t& operator=(_LV<49> _x) {
			stateful_valid = _x.slice(48,48);
			addr1 = _x.slice(47,0);
			return *this;
		}
		_LV<49> get_LV() { return (stateful_valid,addr1); }
		operator _LV<49>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid = " + stateful_valid.to_string() + "\n" + "\t\taddr1 = " + addr1.to_string() + "\n" + "\t)";
		}
		change_addr_input_t() {} 
		change_addr_input_t( _LV<1> _stateful_valid, _LV<48> _addr1) {
			stateful_valid = _stateful_valid;
			addr1 = _addr1;
		}
	};
	struct change_addr_output_t {
		static const size_t _SIZE = 48;
		_LV<48> addr2;
		change_addr_output_t& operator=(_LV<48> _x) {
			addr2 = _x.slice(47,0);
			return *this;
		}
		_LV<48> get_LV() { return (addr2); }
		operator _LV<48>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\taddr2 = " + addr2.to_string() + "\n" + "\t)";
		}
		change_addr_output_t() {} 
		change_addr_output_t( _LV<48> _addr2) {
			addr2 = _addr2;
		}
	};

	// engine members
	std::string _name;
	change_addr_input_t change_addr_input;
	change_addr_output_t change_addr_output;


	// engine ctor
	change_addr_0_t(std::string _n, std::string _filename = "") : _name(_n) {
	}

	// engine function
	void operator()() {
		std::cout << "===================================================================" << std::endl;
		std::cout << "Entering engine " << _name << std::endl;
		// input and inout tuples:
		std::cout << "initial input and inout tuples:" << std::endl;
		std::cout << "	change_addr_input = " << change_addr_input.to_string() << std::endl;
		// clear internal and output-only tuples:
		std::cout << "clear internal and output-only tuples" << std::endl;
		change_addr_output = 0;
		std::cout << "	change_addr_output = " << change_addr_output.to_string() << std::endl;

		if (change_addr_input.get_LV()[48])
			change_addr_output = change_addr_input.get_LV().slice(47, 0) + 1;

		// inout and output tuples:
		std::cout << "final inout and output tuples:" << std::endl;
		std::cout << "	change_addr_output = " << change_addr_output.to_string() << std::endl;
		std::cout << "Exiting engine " << _name << std::endl;
		std::cout << "===================================================================" << std::endl;
	}
};
//######################################################
// top-level DPI function
extern "C" void change_addr_0_t_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_change_addr_0_t
