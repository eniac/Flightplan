#ifndef SDNET_ENGINE_fec_encode_0_t
#define SDNET_ENGINE_fec_encode_0_t

#include "sdnet_lib.hpp"
#include "rse.h"

// NOTE we only work with a single block of Vencore's fbk buffer in our prototype
#define FB_INDEX 0

namespace SDNET {

#define BUFFER_SIZE (FEC_MAX_PACKET_SIZE + FEC_PACKET_LENGTH_WIDTH / 8)

//######################################################
class fec_encode_0_t { // UserEngine
public:

	// tuple types
	struct Update_fl_t {
		static const size_t _SIZE = 24;
		_LV<8> k_1;
		_LV<8> h_1;
		_LV<8> tmp_2;
		Update_fl_t& operator=(_LV<24> _x) {
			k_1 = _x.slice(23,16);
			h_1 = _x.slice(15,8);
			tmp_2 = _x.slice(7,0);
			return *this;
		}
		_LV<24> get_LV() { return (k_1,h_1,tmp_2); }
		operator _LV<24>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tk_1 = " + k_1.to_string() + "\n" + "\t\th_1 = " + h_1.to_string() + "\n" + "\t\ttmp_2 = " + tmp_2.to_string() + "\n" + "\t)";
		}
		Update_fl_t() {} 
		Update_fl_t( _LV<8> _k_1, _LV<8> _h_1, _LV<8> _tmp_2) {
			k_1 = _k_1;
			h_1 = _h_1;
			tmp_2 = _tmp_2;
		}
	};
	struct hdr_t_0 {
		static const size_t _SIZE = 146;
		struct _struct_eth {
			static const size_t _SIZE = 113;
			_LV<1> isValid;
			_LV<48> dst;
			_LV<48> src;
			_LV<16> type;
			_struct_eth& operator=(_LV<113> _x) {
				isValid = _x.slice(112,112);
				dst = _x.slice(111,64);
				src = _x.slice(63,16);
				type = _x.slice(15,0);
				return *this;
			}
			_LV<113> get_LV() { return (isValid,dst,src,type); }
			operator _LV<113>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\tdst = " + dst.to_string() + "\n" + "\t\tsrc = " + src.to_string() + "\n" + "\t\ttype = " + type.to_string() + "\n" + "\t)";
			}
			_struct_eth() {} 
			_struct_eth( _LV<1> _isValid, _LV<48> _dst, _LV<48> _src, _LV<16> _type) {
				isValid = _isValid;
				dst = _dst;
				src = _src;
				type = _type;
			}
		};
		_struct_eth eth;
		struct _struct_fec {
			static const size_t _SIZE = 33;
			_LV<1> isValid;
			_LV<3> traffic_class;
			_LV<5> block_index;
			_LV<8> packet_index;
			_LV<16> original_type;
			_struct_fec& operator=(_LV<33> _x) {
				isValid = _x.slice(32,32);
				traffic_class = _x.slice(31,29);
				block_index = _x.slice(28,24);
				packet_index = _x.slice(23,16);
				original_type = _x.slice(15,0);
				return *this;
			}
			_LV<33> get_LV() { return (isValid,traffic_class,block_index,packet_index,original_type); }
			operator _LV<33>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\ttraffic_class = " + traffic_class.to_string() + "\n" + "\t\tblock_index = " + block_index.to_string() + "\n" + "\t\tpacket_index = " + packet_index.to_string() + "\n" + "\t\toriginal_type = " + original_type.to_string() + "\n" + "\t)";
			}
			_struct_fec() {} 
			_struct_fec( _LV<1> _isValid, _LV<3> _traffic_class, _LV<5> _block_index, _LV<8> _packet_index, _LV<16> _original_type) {
				isValid = _isValid;
				traffic_class = _traffic_class;
				block_index = _block_index;
				packet_index = _packet_index;
				original_type = _original_type;
			}
		};
		_struct_fec fec;
		hdr_t_0& operator=(_LV<146> _x) {
			eth = _x.slice(145,33);
			fec = _x.slice(32,0);
			return *this;
		}
		_LV<146> get_LV() { return (eth.isValid,eth.dst,eth.src,eth.type,fec.isValid,fec.traffic_class,fec.block_index,fec.packet_index,fec.original_type); }
		operator _LV<146>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\teth = " + eth.to_string() + "\n" + "\t\tfec = " + fec.to_string() + "\n" + "\t)";
		}
		hdr_t_0() {} 
		hdr_t_0( _LV<113> _eth, _LV<33> _fec) {
			eth = _eth;
			fec = _fec;
		}
	};
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
	struct local_state_t {
		static const size_t _SIZE = 16;
		_LV<16> id;
		local_state_t& operator=(_LV<16> _x) {
			id = _x.slice(15,0);
			return *this;
		}
		_LV<16> get_LV() { return (id); }
		operator _LV<16>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tid = " + id.to_string() + "\n" + "\t)";
		}
		local_state_t() {} 
		local_state_t( _LV<16> _id) {
			id = _id;
		}
	};
	struct Parser_extracts_t {
		static const size_t _SIZE = 32;
		_LV<32> size;
		Parser_extracts_t& operator=(_LV<32> _x) {
			size = _x.slice(31,0);
			return *this;
		}
		_LV<32> get_LV() { return (size); }
		operator _LV<32>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tsize = " + size.to_string() + "\n" + "\t)";
		}
		Parser_extracts_t() {} 
		Parser_extracts_t( _LV<32> _size) {
			size = _size;
		}
	};
	struct fec_encode_input_t {
		static const size_t _SIZE = 50;
		_LV<1> stateful_valid;
		struct _struct_fec {
			static const size_t _SIZE = 33;
			_LV<1> isValid;
			_LV<3> traffic_class;
			_LV<5> block_index;
			_LV<8> packet_index;
			_LV<16> original_type;
			_struct_fec& operator=(_LV<33> _x) {
				isValid = _x.slice(32,32);
				traffic_class = _x.slice(31,29);
				block_index = _x.slice(28,24);
				packet_index = _x.slice(23,16);
				original_type = _x.slice(15,0);
				return *this;
			}
			_LV<33> get_LV() { return (isValid,traffic_class,block_index,packet_index,original_type); }
			operator _LV<33>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\ttraffic_class = " + traffic_class.to_string() + "\n" + "\t\tblock_index = " + block_index.to_string() + "\n" + "\t\tpacket_index = " + packet_index.to_string() + "\n" + "\t\toriginal_type = " + original_type.to_string() + "\n" + "\t)";
			}
			_struct_fec() {} 
			_struct_fec( _LV<1> _isValid, _LV<3> _traffic_class, _LV<5> _block_index, _LV<8> _packet_index, _LV<16> _original_type) {
				isValid = _isValid;
				traffic_class = _traffic_class;
				block_index = _block_index;
				packet_index = _packet_index;
				original_type = _original_type;
			}
		};
		_struct_fec fec;
		_LV<8> k;
		_LV<8> h;
		fec_encode_input_t& operator=(_LV<50> _x) {
			stateful_valid = _x.slice(49,49);
			fec = _x.slice(48,16);
			k = _x.slice(15,8);
			h = _x.slice(7,0);
			return *this;
		}
		_LV<50> get_LV() { return (stateful_valid,fec.isValid,fec.traffic_class,fec.block_index,fec.packet_index,fec.original_type,k,h); }
		operator _LV<50>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid = " + stateful_valid.to_string() + "\n" + "\t\tfec = " + fec.to_string() + "\n" + "\t\tk = " + k.to_string() + "\n" + "\t\th = " + h.to_string() + "\n" + "\t)";
		}
		fec_encode_input_t() {} 
		fec_encode_input_t( _LV<1> _stateful_valid, _LV<33> _fec, _LV<8> _k, _LV<8> _h) {
			stateful_valid = _stateful_valid;
			fec = _fec;
			k = _k;
			h = _h;
		}
	};
	struct fec_encode_output_t {
		static const size_t _SIZE = 8;
		_LV<8> packet_index;
		fec_encode_output_t& operator=(_LV<8> _x) {
			packet_index = _x.slice(7,0);
			return *this;
		}
		_LV<8> get_LV() { return (packet_index); }
		operator _LV<8>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tpacket_index = " + packet_index.to_string() + "\n" + "\t)";
		}
		fec_encode_output_t() {} 
		fec_encode_output_t( _LV<8> _packet_index) {
			packet_index = _packet_index;
		}
	};
	struct CONTROL_STRUCT {
		static const size_t _SIZE = 36;
		_LV<14> offset;
		_LV<14> virtual_offset;
		_LV<3> section;
		_LV<1> activeBank;
		_LV<1> done;
		_LV<3> error;
		CONTROL_STRUCT& operator=(_LV<36> _x) {
			offset = _x.slice(35,22);
			virtual_offset = _x.slice(21,8);
			section = _x.slice(7,5);
			activeBank = _x.slice(4,4);
			done = _x.slice(3,3);
			error = _x.slice(2,0);
			return *this;
		}
		_LV<36> get_LV() { return (offset,virtual_offset,section,activeBank,done,error); }
		operator _LV<36>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\toffset = " + offset.to_string() + "\n" + "\t\tvirtual_offset = " + virtual_offset.to_string() + "\n" + "\t\tsection = " + section.to_string() + "\n" + "\t\tactiveBank = " + activeBank.to_string() + "\n" + "\t\tdone = " + done.to_string() + "\n" + "\t\terror = " + error.to_string() + "\n" + "\t)";
		}
		CONTROL_STRUCT() {} 
		CONTROL_STRUCT( _LV<14> _offset, _LV<14> _virtual_offset, _LV<3> _section, _LV<1> _activeBank, _LV<1> _done, _LV<3> _error) {
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
	Update_fl_t Update_fl;
	hdr_t_0 hdr;
	ioports_t ioports;
	local_state_t local_state;
	Parser_extracts_t Parser_extracts;
	fec_encode_input_t fec_encode_input;
	fec_encode_output_t fec_encode_output;

	int maximum_packet_size;
	int packet_index;

	// engine ctor
	fec_encode_0_t(std::string _n, std::string _filename = "") : _name(_n) {

		packet_index = 0;
	}

	// engine function
	bool operator()() {
		std::cout << "===================================================================" << std::endl;
		std::cout << "Entering engine " << _name << std::endl;
		// input packet
		std::cout << "input packet (" << packet_in.size() << " bytes)" << std::endl;
		std::cout << packet_in;
		// input and inout tuples:
		std::cout << "initial input and inout tuples:" << std::endl;
		std::cout << "	control = " << control.to_string() << std::endl;
		std::cout << "	Update_fl = " << Update_fl.to_string() << std::endl;
		std::cout << "	hdr = " << hdr.to_string() << std::endl;
		std::cout << "	ioports = " << ioports.to_string() << std::endl;
		std::cout << "	local_state = " << local_state.to_string() << std::endl;
		std::cout << "	Parser_extracts = " << Parser_extracts.to_string() << std::endl;
		std::cout << "	fec_encode_input = " << fec_encode_input.to_string() << std::endl;
		// clear internal and output-only tuples:
		std::cout << "clear internal and output-only tuples" << std::endl;
		fec_encode_output = 0;
		std::cout << "	fec_encode_output = " << fec_encode_output.to_string() << std::endl;

		bool generate_packet = false;

		packet_out = packet_in;

		if (fec_encode_input.stateful_valid.to_ulong() == 1)
		{
			unsigned long k = fec_encode_input.k.to_ulong();
			unsigned long h = fec_encode_input.h.to_ulong();

			if (packet_index == 0)
			{
				int ret = rse_init();

				for (int i = 0; i < k + h; i++)
				{
					if (fbk[FB_INDEX].pdata[i] != nullptr)
					{
						delete fbk[FB_INDEX].pdata[i];
						fbk[FB_INDEX].pdata[i] = nullptr;
					}

					fbk[FB_INDEX].pdata[i] = new fec_sym[BUFFER_SIZE];
					for (int j = 0; j < BUFFER_SIZE; j++)
						fbk[FB_INDEX].pdata[i][j] = 0;
				}

				fbk[FB_INDEX].block_C = BUFFER_SIZE;
				fbk[FB_INDEX].block_N = k + h;

				maximum_packet_size = 0;
			}

			if (packet_index < k)
			{
				fec_sym * packet = fbk[FB_INDEX].pdata[packet_index];
				for (int i = 0; i<packet_in.size(); i++)
					packet[i] = (fec_sym) packet_in[i];

				fbk[FB_INDEX].cbi[packet_index] = packet_index;
				fbk[FB_INDEX].plen[packet_index] = packet_in.size();
				fbk[FB_INDEX].pstat[packet_index] = FEC_FLAG_KNOWN;

				if (packet_in.size() > maximum_packet_size)
					maximum_packet_size = packet_in.size();

				fbk[FB_INDEX].cbi[k + packet_index] = FEC_MAX_N - packet_index - 1;
				fbk[FB_INDEX].pstat[k + packet_index] = FEC_FLAG_WANTED;

				if (packet_index == k - 1)
				{
					rse_code(FB_INDEX, 'e');

					fec_block_print(FB_INDEX);
				}
			}
			else
			{
				fec_sym * packet = fbk[FB_INDEX].pdata[packet_index];
				packet_out.resize(FEC_ETH_HEADER_SIZE / 8);
				for (int i = FEC_MAX_PACKET_SIZE; i < BUFFER_SIZE; i++)
					packet_out.push_back(packet[i]);
				for (int i = 0; i<maximum_packet_size; i++)
					packet_out.push_back(packet[i]);
			}

			generate_packet = packet_index >= k - 1 && packet_index < k + h - 1;

			fec_encode_output.packet_index = packet_index;

			packet_index = (packet_index + 1) % (k + h);
		}

		control.done = 1;

		// inout and output tuples:
		std::cout << "final inout and output tuples:" << std::endl;
		std::cout << "	control = " << control.to_string() << std::endl;
		std::cout << "	Update_fl = " << Update_fl.to_string() << std::endl;
		std::cout << "	hdr = " << hdr.to_string() << std::endl;
		std::cout << "	ioports = " << ioports.to_string() << std::endl;
		std::cout << "	local_state = " << local_state.to_string() << std::endl;
		std::cout << "	Parser_extracts = " << Parser_extracts.to_string() << std::endl;
		std::cout << "	fec_encode_output = " << fec_encode_output.to_string() << std::endl;
		// output packet
		std::cout << "output packet (" << packet_out.size() << " bytes)" << std::endl;
		std::cout << packet_out;
		std::cout << "Exiting engine " << _name << std::endl;
		std::cout << "===================================================================" << std::endl;

		return generate_packet;
	}
};
//######################################################
// top-level DPI function
extern "C" void fec_encode_0_t_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_fec_encode_0_t
