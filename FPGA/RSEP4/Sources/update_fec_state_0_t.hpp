#ifndef SDNET_ENGINE_update_fec_state_0_t
#define SDNET_ENGINE_update_fec_state_0_t

#include "sdnet_lib.hpp"

#define TRAFFIC_CLASSES 3

namespace SDNET {

//######################################################
class update_fec_state_0_t { // UserEngine
public:

	// tuple types
	struct update_fec_state_input_t {
		static const size_t _SIZE = 20;
		_LV<1> stateful_valid_0;
		_LV<3> traffic_class;
		_LV<8> k;
		_LV<8> h;
		update_fec_state_input_t& operator=(_LV<20> _x) {
			stateful_valid_0 = _x.slice(19,19);
			traffic_class = _x.slice(18,16);
			k = _x.slice(15,8);
			h = _x.slice(7,0);
			return *this;
		}
		_LV<20> get_LV() { return (stateful_valid_0,traffic_class,k,h); }
		operator _LV<20>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid_0 = " + stateful_valid_0.to_string() + "\n" + "\t\ttraffic_class = " + traffic_class.to_string() + "\n" + "\t\tk = " + k.to_string() + "\n" + "\t\th = " + h.to_string() + "\n" + "\t)";
		}
		update_fec_state_input_t() {} 
		update_fec_state_input_t( _LV<1> _stateful_valid_0, _LV<3> _traffic_class, _LV<8> _k, _LV<8> _h) {
			stateful_valid_0 = _stateful_valid_0;
			traffic_class = _traffic_class;
			k = _k;
			h = _h;
		}
	};
	struct update_fec_state_output_t {
		static const size_t _SIZE = 13;
		_LV<5> block_index;
		_LV<8> packet_index;
		update_fec_state_output_t& operator=(_LV<13> _x) {
			block_index = _x.slice(12,8);
			packet_index = _x.slice(7,0);
			return *this;
		}
		_LV<13> get_LV() { return (block_index,packet_index); }
		operator _LV<13>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tblock_index = " + block_index.to_string() + "\n" + "\t\tpacket_index = " + packet_index.to_string() + "\n" + "\t)";
		}
		update_fec_state_output_t() {} 
		update_fec_state_output_t( _LV<5> _block_index, _LV<8> _packet_index) {
			block_index = _block_index;
			packet_index = _packet_index;
		}
	};

	// engine members
	std::string _name;
	update_fec_state_input_t update_fec_state_input;
	update_fec_state_output_t update_fec_state_output;

	int block_indices[TRAFFIC_CLASSES];
	int packet_indices[TRAFFIC_CLASSES];

	// engine ctor
	update_fec_state_0_t(std::string _n, std::string _filename = "") : _name(_n) {
		for (int i = 0; i < TRAFFIC_CLASSES; i++) {
			block_indices[i] = 0;
			packet_indices[i] = 0;
		}
	}

	// engine function
	void operator()() {
		std::cout << "===================================================================" << std::endl;
		std::cout << "Entering engine " << _name << std::endl;
		// input and inout tuples:
		std::cout << "initial input and inout tuples:" << std::endl;
		std::cout << "	update_fec_state_input = " << update_fec_state_input.to_string() << std::endl;
		// clear internal and output-only tuples:
		std::cout << "clear internal and output-only tuples" << std::endl;
		update_fec_state_output = 0;
		std::cout << "	update_fec_state_output = " << update_fec_state_output.to_string() << std::endl;

		if (update_fec_state_input.stateful_valid_0.to_ulong() == 1)
		{
			unsigned long traffic_class = update_fec_state_input.traffic_class.to_ulong();
			unsigned long k = update_fec_state_input.k.to_ulong();
			unsigned long h = update_fec_state_input.h.to_ulong();

			unsigned n = k + h;

			update_fec_state_output.block_index = block_indices[traffic_class];
			update_fec_state_output.packet_index = packet_indices[traffic_class];

			if (packet_indices[traffic_class] < n - 1) {
				packet_indices[traffic_class]++;
			} else {
				packet_indices[traffic_class] = 0;
				block_indices[traffic_class]++;
			}
		}

		// inout and output tuples:
		std::cout << "final inout and output tuples:" << std::endl;
		std::cout << "	update_fec_state_output = " << update_fec_state_output.to_string() << std::endl;
		std::cout << "Exiting engine " << _name << std::endl;
		std::cout << "===================================================================" << std::endl;
	}
};
//######################################################
// top-level DPI function
extern "C" void update_fec_state_0_t_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_update_fec_state_0_t
