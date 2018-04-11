#ifndef SDNET_ENGINE_XilinxSwitch
#define SDNET_ENGINE_XilinxSwitch

#include "../Parser_t.TB/Parser_t.hpp"

#include "../Update_lvl_t.TB/Update_lvl_t.hpp"

#include "../Update_lvl_0_t.TB/Update_lvl_0_t.hpp"

#include "../fec_0_t.TB/fec_0_t.hpp"

#include "../Update_lvl_1_t.TB/Update_lvl_1_t.hpp"

#include "../Deparser_t.TB/Deparser_t.hpp"

#include "sdnet_lib.hpp"

namespace SDNET {

//######################################################
class XilinxSwitch { // System
public:

	// tuple types
	struct ioports_t {
		static const size_t _SIZE = 8;
		_LV<4> ingress_port;
		_LV<4> egress_port;
		ioports_t& operator=(_LV<8> _x) {
			ingress_port = _x.slice(7,4);
			egress_port = _x.slice(3,0);
			return *this;
		}
		_LV<8> get_LV() { return (ingress_port,egress_port); }
		operator _LV<8>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tingress_port = " + ingress_port.to_string() + "\n" + "\t\tegress_port = " + egress_port.to_string() + "\n" + "\t)";
		}
		ioports_t() {} 
		ioports_t( _LV<4> _ingress_port, _LV<4> _egress_port) {
			ingress_port = _ingress_port;
			egress_port = _egress_port;
		}
	};

	// system members
	std::string _name;
	Packet packet_in;
	Packet packet_out;
	ioports_t ioports;


	// system engines
	Parser_t Parser;
	Update_lvl_t Update_lvl;
	Update_lvl_0_t Update_lvl_0;
	fec_0_t fec_0;
	Update_lvl_1_t Update_lvl_1;
	Deparser_t Deparser;

	// system ctor
	XilinxSwitch(std::string n) : _name(n),
		Parser("Parser"),
		Update_lvl("Update_lvl"),
		Update_lvl_0("Update_lvl_0"),
		fec_0("fec_0"),
		Update_lvl_1("Update_lvl_1"),
		Deparser("Deparser") { }

	// system function
	bool operator()() {
		std::cout << "===================================================================" << std::endl;
		std::cout << "Entering system " << _name << std::endl;
		// input packet
		std::cout << "input packet (" << packet_in.size() << " bytes)" << std::endl;
		std::cout << packet_in;
		// input and inout tuples:
		std::cout << "initial input and inout tuples:" << std::endl;
		std::cout << "	ioports = " << ioports.to_string() << std::endl;
		// clear internal and output-only tuples:
		std::cout << "clear internal and output-only tuples" << std::endl;

		// evaluate engines in topologically-sorted order

		Parser.packet_in = packet_in;
		Parser.control = 0;
		Parser();

		Update_lvl.hdr = Parser.hdr;
		Update_lvl.ioports = ioports;
		Update_lvl();

		Update_lvl_0.Update_fl = Update_lvl.Update_fl;
		Update_lvl_0.hdr = Update_lvl.hdr;
		Update_lvl_0.ioports = Update_lvl.ioports;
		Update_lvl_0.local_state = Update_lvl.local_state;
		Update_lvl_0();

		fec_0.fec_input = Update_lvl_0.fec_input;
		fec_0.Update_fl = Update_lvl_0.Update_fl;
		fec_0.hdr = Update_lvl_0.hdr;
		fec_0.ioports = Update_lvl_0.ioports;
		fec_0.local_state = Update_lvl_0.local_state;
		fec_0.packet_in = Parser.packet_out;
		fec_0.control = 0;
		fec_0.control.error = Parser.control.error.any() || Parser.control.done.none() || Parser.control.section.any();
		fec_0.Parser_extracts = Parser.Parser_extracts;
		bool repeat = fec_0();

		Update_lvl_1.Update_fl = fec_0.Update_fl;
		Update_lvl_1.hdr = fec_0.hdr;
		Update_lvl_1.ioports = fec_0.ioports;
		Update_lvl_1.local_state = fec_0.local_state;
		Update_lvl_1.fec_output = fec_0.fec_output;
		Update_lvl_1();

		Deparser.hdr = Update_lvl_1.hdr;
		Deparser.packet_in = fec_0.packet_out;
		Deparser.control = 0;
		Deparser.control.error = fec_0.control.error.any() || fec_0.control.done.none() || fec_0.control.section.any();
		Deparser.Deparser_extracts = fec_0.Parser_extracts;
		Deparser();

		// assign system outputs
		ioports = Update_lvl_1.ioports;
		packet_out = Deparser.packet_out;

		// inout and output tuples:
		std::cout << "final inout and output tuples:" << std::endl;
		std::cout << "	ioports = " << ioports.to_string() << std::endl;
		// output packet
		std::cout << "output packet (" << packet_out.size() << " bytes)" << std::endl;
		std::cout << packet_out;
		std::cout << "Exiting system " << _name << std::endl;
		std::cout << "===================================================================" << std::endl;
		
		return repeat;
	}
};
//######################################################
// top-level DPI function
extern "C" void XilinxSwitch_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_XilinxSwitch
