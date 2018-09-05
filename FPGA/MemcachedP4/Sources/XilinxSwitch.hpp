#ifndef SDNET_ENGINE_XilinxSwitch
#define SDNET_ENGINE_XilinxSwitch

#include "../Parser_t.TB/Parser_t.hpp"

#include "../CheckCache_lvl_t.TB/CheckCache_lvl_t.hpp"

#include "../CheckCache_lvl_0_t.TB/CheckCache_lvl_0_t.hpp"

#include "../memcached_0_t.TB/memcached_0_t.hpp"

#include "../CheckCache_lvl_1_t.TB/CheckCache_lvl_1_t.hpp"

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
	int Forward;

	// system engines
	Parser_t Parser;
	CheckCache_lvl_t CheckCache_lvl;
	CheckCache_lvl_0_t CheckCache_lvl_0;
	memcached_0_t memcached_0;
	CheckCache_lvl_1_t CheckCache_lvl_1;
	Deparser_t Deparser;

	// system ctor
	XilinxSwitch(std::string n) : _name(n),
		Parser("Parser"),
		CheckCache_lvl("CheckCache_lvl"),
		CheckCache_lvl_0("CheckCache_lvl_0"),
		memcached_0("memcached_0"),
		CheckCache_lvl_1("CheckCache_lvl_1"),
		Deparser("Deparser"),
		Forward(0) { }

	// system function
	bool operator()() {
		if (Forward ==0)
		{
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

		CheckCache_lvl.hdr = Parser.hdr;
		CheckCache_lvl.ioports = ioports;
		CheckCache_lvl();

		CheckCache_lvl_0.CheckCache_fl = CheckCache_lvl.CheckCache_fl;
		CheckCache_lvl_0.hdr = CheckCache_lvl.hdr;
		CheckCache_lvl_0.ioports = CheckCache_lvl.ioports;
		CheckCache_lvl_0.local_state = CheckCache_lvl.local_state;
		CheckCache_lvl_0();

		memcached_0.memcached_input = CheckCache_lvl_0.memcached_input;
		memcached_0.CheckCache_fl = CheckCache_lvl_0.CheckCache_fl;
		memcached_0.hdr = CheckCache_lvl_0.hdr;
		memcached_0.ioports = CheckCache_lvl_0.ioports;
		memcached_0.local_state = CheckCache_lvl_0.local_state;
		memcached_0.packet_in = Parser.packet_out;
		memcached_0.control = 0;
		memcached_0.Parser_extracts = Parser.Parser_extracts;
		}
		Forward = memcached_0();

		CheckCache_lvl_1.CheckCache_fl = memcached_0.CheckCache_fl;
		CheckCache_lvl_1.hdr = memcached_0.hdr;
		CheckCache_lvl_1.ioports = memcached_0.ioports;
		CheckCache_lvl_1.local_state = memcached_0.local_state;
		CheckCache_lvl_1.memcached_output = memcached_0.memcached_output;
		CheckCache_lvl_1();

		Deparser.hdr = CheckCache_lvl_1.hdr;
		Deparser.packet_in = memcached_0.packet_out;
		Deparser.control = 0;
		Deparser.Deparser_extracts = memcached_0.Parser_extracts;
		Deparser();

		// assign system outputs
		ioports = CheckCache_lvl_1.ioports;
		packet_out = Deparser.packet_out;

		// inout and output tuples:
		std::cout << "final inout and output tuples:" << std::endl;
		std::cout << "	ioports = " << ioports.to_string() << std::endl;
		// output packet
		std::cout << "output packet (" << packet_out.size() << " bytes)" << std::endl;
		std::cout << packet_out;
		std::cout << "Exiting system " << _name << std::endl;
		std::cout << "===================================================================" << std::endl;
		
		return Forward;
	}
};
//######################################################
// top-level DPI function
extern "C" void XilinxSwitch_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_XilinxSwitch
