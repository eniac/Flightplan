#ifndef SDNET_ENGINE_headerCompress_0_t
#define SDNET_ENGINE_headerCompress_0_t

#include "sdnet_lib.hpp"
#include "Compressor.h"
namespace SDNET {

//######################################################
class headerCompress_0_t { // UserEngine
public:

	// tuple types
	struct CheckTcp_fl_t {
		static const size_t _SIZE = 1;
		_LV<1> forward_1;
		CheckTcp_fl_t& operator=(_LV<1> _x) {
			forward_1 = _x.slice(0,0);
			return *this;
		}
		_LV<1> get_LV() { return (forward_1); }
		operator _LV<1>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tforward_1 = " + forward_1.to_string() + "\n" + "\t)";
		}
		CheckTcp_fl_t() {} 
		CheckTcp_fl_t( _LV<1> _forward_1) {
			forward_1 = _forward_1;
		}
	};
	struct hdr_t_0 {
		static const size_t _SIZE = 725;
		struct _struct_fph {
			static const size_t _SIZE = 257;
			_LV<1> isValid;
			_LV<48> dst;
			_LV<48> src;
			_LV<16> type;
			_LV<4> from_segment;
			_LV<4> to_segment;
			_LV<8> byte1;
			_LV<8> byte2;
			_LV<8> byte3;
			_LV<8> byte4;
			_LV<8> byte5;
			_LV<8> byte6;
			_LV<8> byte7;
			_LV<8> byte8;
			_LV<8> byte9;
			_LV<8> byte10;
			_LV<8> byte11;
			_LV<8> byte12;
			_LV<8> byte13;
			_LV<8> byte14;
			_LV<8> byte15;
			_LV<8> byte16;
			_LV<8> byte17;
			_struct_fph& operator=(_LV<257> _x) {
				isValid = _x.slice(256,256);
				dst = _x.slice(255,208);
				src = _x.slice(207,160);
				type = _x.slice(159,144);
				from_segment = _x.slice(143,140);
				to_segment = _x.slice(139,136);
				byte1 = _x.slice(135,128);
				byte2 = _x.slice(127,120);
				byte3 = _x.slice(119,112);
				byte4 = _x.slice(111,104);
				byte5 = _x.slice(103,96);
				byte6 = _x.slice(95,88);
				byte7 = _x.slice(87,80);
				byte8 = _x.slice(79,72);
				byte9 = _x.slice(71,64);
				byte10 = _x.slice(63,56);
				byte11 = _x.slice(55,48);
				byte12 = _x.slice(47,40);
				byte13 = _x.slice(39,32);
				byte14 = _x.slice(31,24);
				byte15 = _x.slice(23,16);
				byte16 = _x.slice(15,8);
				byte17 = _x.slice(7,0);
				return *this;
			}
			_LV<257> get_LV() { return (isValid,dst,src,type,from_segment,to_segment,byte1,byte2,byte3,byte4,byte5,byte6,byte7,byte8,byte9,byte10,byte11,byte12,byte13,byte14,byte15,byte16,byte17); }
			operator _LV<257>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\tdst = " + dst.to_string() + "\n" + "\t\tsrc = " + src.to_string() + "\n" + "\t\ttype = " + type.to_string() + "\n" + "\t\tfrom_segment = " + from_segment.to_string() + "\n" + "\t\tto_segment = " + to_segment.to_string() + "\n" + "\t\tbyte1 = " + byte1.to_string() + "\n" + "\t\tbyte2 = " + byte2.to_string() + "\n" + "\t\tbyte3 = " + byte3.to_string() + "\n" + "\t\tbyte4 = " + byte4.to_string() + "\n" + "\t\tbyte5 = " + byte5.to_string() + "\n" + "\t\tbyte6 = " + byte6.to_string() + "\n" + "\t\tbyte7 = " + byte7.to_string() + "\n" + "\t\tbyte8 = " + byte8.to_string() + "\n" + "\t\tbyte9 = " + byte9.to_string() + "\n" + "\t\tbyte10 = " + byte10.to_string() + "\n" + "\t\tbyte11 = " + byte11.to_string() + "\n" + "\t\tbyte12 = " + byte12.to_string() + "\n" + "\t\tbyte13 = " + byte13.to_string() + "\n" + "\t\tbyte14 = " + byte14.to_string() + "\n" + "\t\tbyte15 = " + byte15.to_string() + "\n" + "\t\tbyte16 = " + byte16.to_string() + "\n" + "\t\tbyte17 = " + byte17.to_string() + "\n" + "\t)";
			}
			_struct_fph() {} 
			_struct_fph( _LV<1> _isValid, _LV<48> _dst, _LV<48> _src, _LV<16> _type, _LV<4> _from_segment, _LV<4> _to_segment, _LV<8> _byte1, _LV<8> _byte2, _LV<8> _byte3, _LV<8> _byte4, _LV<8> _byte5, _LV<8> _byte6, _LV<8> _byte7, _LV<8> _byte8, _LV<8> _byte9, _LV<8> _byte10, _LV<8> _byte11, _LV<8> _byte12, _LV<8> _byte13, _LV<8> _byte14, _LV<8> _byte15, _LV<8> _byte16, _LV<8> _byte17) {
				isValid = _isValid;
				dst = _dst;
				src = _src;
				type = _type;
				from_segment = _from_segment;
				to_segment = _to_segment;
				byte1 = _byte1;
				byte2 = _byte2;
				byte3 = _byte3;
				byte4 = _byte4;
				byte5 = _byte5;
				byte6 = _byte6;
				byte7 = _byte7;
				byte8 = _byte8;
				byte9 = _byte9;
				byte10 = _byte10;
				byte11 = _byte11;
				byte12 = _byte12;
				byte13 = _byte13;
				byte14 = _byte14;
				byte15 = _byte15;
				byte16 = _byte16;
				byte17 = _byte17;
			}
		};
		_struct_fph fph;
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
		struct _struct_ipv4 {
			static const size_t _SIZE = 161;
			_LV<1> isValid;
			_LV<4> version;
			_LV<4> ihl;
			_LV<8> diffserv;
			_LV<16> totallen;
			_LV<16> identification;
			_LV<3> flags;
			_LV<13> fragoffset;
			_LV<8> ttl;
			_LV<8> protocol;
			_LV<16> hdrchecksum;
			_LV<32> srcAddr;
			_LV<32> dstAddr;
			_struct_ipv4& operator=(_LV<161> _x) {
				isValid = _x.slice(160,160);
				version = _x.slice(159,156);
				ihl = _x.slice(155,152);
				diffserv = _x.slice(151,144);
				totallen = _x.slice(143,128);
				identification = _x.slice(127,112);
				flags = _x.slice(111,109);
				fragoffset = _x.slice(108,96);
				ttl = _x.slice(95,88);
				protocol = _x.slice(87,80);
				hdrchecksum = _x.slice(79,64);
				srcAddr = _x.slice(63,32);
				dstAddr = _x.slice(31,0);
				return *this;
			}
			_LV<161> get_LV() { return (isValid,version,ihl,diffserv,totallen,identification,flags,fragoffset,ttl,protocol,hdrchecksum,srcAddr,dstAddr); }
			operator _LV<161>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\tversion = " + version.to_string() + "\n" + "\t\tihl = " + ihl.to_string() + "\n" + "\t\tdiffserv = " + diffserv.to_string() + "\n" + "\t\ttotallen = " + totallen.to_string() + "\n" + "\t\tidentification = " + identification.to_string() + "\n" + "\t\tflags = " + flags.to_string() + "\n" + "\t\tfragoffset = " + fragoffset.to_string() + "\n" + "\t\tttl = " + ttl.to_string() + "\n" + "\t\tprotocol = " + protocol.to_string() + "\n" + "\t\thdrchecksum = " + hdrchecksum.to_string() + "\n" + "\t\tsrcAddr = " + srcAddr.to_string() + "\n" + "\t\tdstAddr = " + dstAddr.to_string() + "\n" + "\t)";
			}
			_struct_ipv4() {} 
			_struct_ipv4( _LV<1> _isValid, _LV<4> _version, _LV<4> _ihl, _LV<8> _diffserv, _LV<16> _totallen, _LV<16> _identification, _LV<3> _flags, _LV<13> _fragoffset, _LV<8> _ttl, _LV<8> _protocol, _LV<16> _hdrchecksum, _LV<32> _srcAddr, _LV<32> _dstAddr) {
				isValid = _isValid;
				version = _version;
				ihl = _ihl;
				diffserv = _diffserv;
				totallen = _totallen;
				identification = _identification;
				flags = _flags;
				fragoffset = _fragoffset;
				ttl = _ttl;
				protocol = _protocol;
				hdrchecksum = _hdrchecksum;
				srcAddr = _srcAddr;
				dstAddr = _dstAddr;
			}
		};
		_struct_ipv4 ipv4;
		struct _struct_tcp {
			static const size_t _SIZE = 161;
			_LV<1> isValid;
			_LV<16> sport;
			_LV<16> dport;
			_LV<32> seq;
			_LV<32> ack;
			_LV<16> flags;
			_LV<16> window;
			_LV<16> check;
			_LV<16> urgent;
			_struct_tcp& operator=(_LV<161> _x) {
				isValid = _x.slice(160,160);
				sport = _x.slice(159,144);
				dport = _x.slice(143,128);
				seq = _x.slice(127,96);
				ack = _x.slice(95,64);
				flags = _x.slice(63,48);
				window = _x.slice(47,32);
				check = _x.slice(31,16);
				urgent = _x.slice(15,0);
				return *this;
			}
			_LV<161> get_LV() { return (isValid,sport,dport,seq,ack,flags,window,check,urgent); }
			operator _LV<161>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\tsport = " + sport.to_string() + "\n" + "\t\tdport = " + dport.to_string() + "\n" + "\t\tseq = " + seq.to_string() + "\n" + "\t\tack = " + ack.to_string() + "\n" + "\t\tflags = " + flags.to_string() + "\n" + "\t\twindow = " + window.to_string() + "\n" + "\t\tcheck = " + check.to_string() + "\n" + "\t\turgent = " + urgent.to_string() + "\n" + "\t)";
			}
			_struct_tcp() {} 
			_struct_tcp( _LV<1> _isValid, _LV<16> _sport, _LV<16> _dport, _LV<32> _seq, _LV<32> _ack, _LV<16> _flags, _LV<16> _window, _LV<16> _check, _LV<16> _urgent) {
				isValid = _isValid;
				sport = _sport;
				dport = _dport;
				seq = _seq;
				ack = _ack;
				flags = _flags;
				window = _window;
				check = _check;
				urgent = _urgent;
			}
		};
		_struct_tcp tcp;
		hdr_t_0& operator=(_LV<725> _x) {
			fph = _x.slice(724,468);
			eth = _x.slice(467,355);
			fec = _x.slice(354,322);
			ipv4 = _x.slice(321,161);
			tcp = _x.slice(160,0);
			return *this;
		}
		_LV<725> get_LV() { return (fph.isValid,fph.dst,fph.src,fph.type,fph.from_segment,fph.to_segment,fph.byte1,fph.byte2,fph.byte3,fph.byte4,fph.byte5,fph.byte6,fph.byte7,fph.byte8,fph.byte9,fph.byte10,fph.byte11,fph.byte12,fph.byte13,fph.byte14,fph.byte15,fph.byte16,fph.byte17,eth.isValid,eth.dst,eth.src,eth.type,fec.isValid,fec.traffic_class,fec.block_index,fec.packet_index,fec.original_type,ipv4.isValid,ipv4.version,ipv4.ihl,ipv4.diffserv,ipv4.totallen,ipv4.identification,ipv4.flags,ipv4.fragoffset,ipv4.ttl,ipv4.protocol,ipv4.hdrchecksum,ipv4.srcAddr,ipv4.dstAddr,tcp.isValid,tcp.sport,tcp.dport,tcp.seq,tcp.ack,tcp.flags,tcp.window,tcp.check,tcp.urgent); }
		operator _LV<725>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tfph = " + fph.to_string() + "\n" + "\t\teth = " + eth.to_string() + "\n" + "\t\tfec = " + fec.to_string() + "\n" + "\t\tipv4 = " + ipv4.to_string() + "\n" + "\t\ttcp = " + tcp.to_string() + "\n" + "\t)";
		}
		hdr_t_0() {} 
		hdr_t_0( _LV<257> _fph, _LV<113> _eth, _LV<33> _fec, _LV<161> _ipv4, _LV<161> _tcp) {
			fph = _fph;
			eth = _eth;
			fec = _fec;
			ipv4 = _ipv4;
			tcp = _tcp;
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
	struct headerCompress_input_t {
		static const size_t _SIZE = 1;
		_LV<1> stateful_valid;
		headerCompress_input_t& operator=(_LV<1> _x) {
			stateful_valid = _x.slice(0,0);
			return *this;
		}
		_LV<1> get_LV() { return (stateful_valid); }
		operator _LV<1>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid = " + stateful_valid.to_string() + "\n" + "\t)";
		}
		headerCompress_input_t() {} 
		headerCompress_input_t( _LV<1> _stateful_valid) {
			stateful_valid = _stateful_valid;
		}
	};
	struct headerCompress_output_t {
		static const size_t _SIZE = 1;
		_LV<1> forward;
		headerCompress_output_t& operator=(_LV<1> _x) {
			forward = _x.slice(0,0);
			return *this;
		}
		_LV<1> get_LV() { return (forward); }
		operator _LV<1>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tforward = " + forward.to_string() + "\n" + "\t)";
		}
		headerCompress_output_t() {} 
		headerCompress_output_t( _LV<1> _forward) {
			forward = _forward;
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
	CheckTcp_fl_t CheckTcp_fl;
	hdr_t_0 hdr;
	ioports_t ioports;
	local_state_t local_state;
	Parser_extracts_t Parser_extracts;
	headerCompress_input_t headerCompress_input;
	headerCompress_output_t headerCompress_output;
 	Packet Forward_Packet;
	hdr_t_0 Forward_hdr;
	bool repeat;

	// TODO: ***************************
	// TODO: *** USER ENGINE MEMBERS ***
	// TODO: ***************************

	// engine ctor
	headerCompress_0_t(std::string _n, std::string _filename = "") : _name(_n) {

		// TODO: **********************************
		// TODO: *** USER ENGINE INITIALIZATION ***
		// TODO: **********************************

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
		std::cout << "	CheckTcp_fl = " << CheckTcp_fl.to_string() << std::endl;
		std::cout << "	hdr = " << hdr.to_string() << std::endl;
		std::cout << "	ioports = " << ioports.to_string() << std::endl;
		std::cout << "	local_state = " << local_state.to_string() << std::endl;
		std::cout << "	Parser_extracts = " << Parser_extracts.to_string() << std::endl;
		std::cout << "	headerCompress_input = " << headerCompress_input.to_string() << std::endl;
		// clear internal and output-only tuples:
		std::cout << "clear internal and output-only tuples" << std::endl;
		headerCompress_output = 0;
		std::cout << "	headerCompress_output = " << headerCompress_output.to_string() << std::endl;
		// TODO: *********************************
		// TODO: *** USER ENGINE FUNCTIONALITY ***
		// TODO: *********************************
	    	//char * packet = packet_block.data;
		repeat = 0;
		packet_out = packet_in;

		hls::stream<input_tuples> Input_tuples;
		input_tuples Tuple;
		Tuple.Hdr.Eth.Is_valid = hdr.eth.isValid.to_ulong();
		Tuple.Hdr.Eth.Dst = hdr.eth.dst.to_ulong();
		Tuple.Hdr.Eth.Src = hdr.eth.src.to_ulong();
		Tuple.Hdr.Eth.Type = hdr.eth.type.to_ulong();
		Tuple.Hdr.FEC.Is_valid = hdr.fec.isValid.to_ulong();
		Tuple.Hdr.FEC.Traffic_class = hdr.fec.traffic_class.to_ulong();
		Tuple.Hdr.FEC.Block_index = hdr.fec.block_index.to_ulong();
		Tuple.Hdr.FEC.Packet_index = hdr.fec.packet_index.to_ulong();
		Tuple.Hdr.FEC.Original_type = hdr.fec.original_type.to_ulong();
		Tuple.Hdr.Ipv4.isValid = hdr.ipv4.isValid.to_ulong();
		Tuple.Hdr.Ipv4.diffserv = hdr.ipv4.diffserv.to_ulong();
		Tuple.Hdr.Ipv4.flags = hdr.ipv4.flags.to_ulong();
		Tuple.Hdr.Ipv4.fragoffset = hdr.ipv4.fragoffset.to_ulong();
		Tuple.Hdr.Ipv4.hdrchecksum = hdr.ipv4.hdrchecksum.to_ulong();
		Tuple.Hdr.Ipv4.identification = hdr.ipv4.identification.to_ulong();
		Tuple.Hdr.Ipv4.ihl = hdr.ipv4.ihl.to_ulong();
		Tuple.Hdr.Ipv4.protocol = hdr.ipv4.protocol.to_ulong();
		Tuple.Hdr.Ipv4.srcAddr = hdr.ipv4.srcAddr.to_ulong();
		Tuple.Hdr.Ipv4.dstAddr = hdr.ipv4.dstAddr.to_ulong();
		Tuple.Hdr.Ipv4.ttl = hdr.ipv4.ttl.to_ulong();
		Tuple.Hdr.Ipv4.totallen = hdr.ipv4.totallen.to_ulong();
		Tuple.Hdr.Ipv4.version = hdr.ipv4.version.to_ulong();
		Tuple.Hdr.Tcp.urgent = hdr.tcp.urgent.to_ulong();
		Tuple.Hdr.Tcp.dport = hdr.tcp.dport.to_ulong();
		Tuple.Hdr.Tcp.check = hdr.tcp.check.to_ulong();
		Tuple.Hdr.Tcp.isValid = hdr.tcp.isValid.to_ulong();
		Tuple.Hdr.Tcp.window = hdr.tcp.window.to_ulong();
		Tuple.Hdr.Tcp.flags = hdr.tcp.flags.to_ulong();
		Tuple.Hdr.Tcp.ack = hdr.tcp.ack.to_ulong();
		Tuple.Hdr.Tcp.seq = hdr.tcp.seq.to_ulong();
		Tuple.Hdr.Tcp.sport = hdr.tcp.sport.to_ulong();
		Tuple.headerCompress_input.Stateful_valid = headerCompress_input.stateful_valid.to_ulong();
		Tuple.Ioports.Egress_port = ioports.egress_port.to_ulong();
		Tuple.Ioports.Ingress_port = ioports.ingress_port.to_ulong();
		Tuple.Local_state.Id = local_state.id.to_ulong();
		Tuple.Parser_extracts.Size = Parser_extracts.size.to_ulong();
		Tuple.CheckTcp.forward = CheckTcp_fl.forward_1.to_ulong();
		Input_tuples.write(Tuple);

		hls::stream<packet_interface> Packet_input;
		unsigned Words_per_packet = DIVIDE_AND_ROUNDUP(packet_in.size(), BYTES_PER_WORD);
		std::cout <<"Enter USER ENGINE FUNCTION" << std::endl;
		for (int i = 0; i < Words_per_packet; i++)
		{	
			ap_uint<MEM_AXI_BUS_WIDTH> WORD = 0;
			for (int j = 0; j < BYTES_PER_WORD; j++)
			{
				WORD <<= 8;
				unsigned Offset = BYTES_PER_WORD * i + j;
				if (Offset < packet_in.size())
					WORD |= packet_in[Offset];
			}
			bool End = i == Words_per_packet - 1;
			packet_interface Input;
			Input.Data = WORD;
			std::cout << WORD << std::endl;
			Input.Start_of_frame = i == 0;
			Input.End_of_frame = End;
			Input.Count = packet_in.size() % BYTES_PER_WORD;
			if (Input.Count == 0 || !End)
				Input.Count = 8;
			Input.Error = 0;
			Packet_input.write(Input);
			
		}
		hls::stream<output_tuples> Output_tuples;
		hls::stream<packet_interface> Packet_output;
		Compressor(Input_tuples, Output_tuples, Packet_input, Packet_output);
		output_tuples Tuple_out;
		Tuple_out = Output_tuples.read();
		//packet_out.resize(PAYLOAD_OFFSET_UDP - MEMCACHED_UDP_HEADER);
		packet_out.resize(0);
		packet_interface Output;
		do 
		{
			Output = Packet_output.read();
			for (int i = 0; i < Output.Count; i++)
			{
				char Byte = (Output.Data >> (8 * (BYTES_PER_WORD - i -1))) & 0xFF;
				packet_out.push_back(Byte);
			}	
		}while(!Output.End_of_frame);

		hdr.eth.isValid =Tuple_out.Hdr.Eth.Is_valid.to_uint();
		hdr.eth.dst = Tuple_out.Hdr.Eth.Dst.to_uint64();
		hdr.eth.src = Tuple_out.Hdr.Eth.Src.to_uint64();
		hdr.eth.type = Tuple_out.Hdr.Eth.Type.to_uint();
		hdr.fec.isValid = Tuple_out.Hdr.FEC.Is_valid.to_uint();
		hdr.fec.traffic_class = Tuple_out.Hdr.FEC.Traffic_class.to_uint();
		hdr.fec.block_index = Tuple_out.Hdr.FEC.Block_index.to_uint();
		hdr.fec.packet_index = Tuple_out.Hdr.FEC.Packet_index.to_uint();
		hdr.fec.original_type = Tuple_out.Hdr.FEC.Original_type.to_uint();
		hdr.ipv4.isValid = Tuple_out.Hdr.Ipv4.isValid.to_uint();
		hdr.ipv4.diffserv = Tuple_out.Hdr.Ipv4.diffserv.to_uint();
		hdr.ipv4.flags= Tuple_out.Hdr.Ipv4.flags.to_uint();
		hdr.ipv4.fragoffset = Tuple_out.Hdr.Ipv4.fragoffset.to_uint();
		hdr.ipv4.hdrchecksum = Tuple_out.Hdr.Ipv4.hdrchecksum.to_uint();
		hdr.ipv4.identification = Tuple_out.Hdr.Ipv4.identification.to_uint();
		hdr.ipv4.ihl = Tuple_out.Hdr.Ipv4.ihl.to_uint();
		hdr.ipv4.protocol = Tuple_out.Hdr.Ipv4.protocol.to_uint();
		hdr.ipv4.srcAddr = Tuple_out.Hdr.Ipv4.srcAddr.to_uint64();
		hdr.ipv4.dstAddr = Tuple_out.Hdr.Ipv4.dstAddr.to_uint64();
		hdr.ipv4.ttl = Tuple_out.Hdr.Ipv4.ttl.to_uint();
		hdr.ipv4.totallen = Tuple_out.Hdr.Ipv4.totallen.to_uint();
		hdr.ipv4.version = Tuple_out.Hdr.Ipv4.version.to_uint();
		hdr.tcp.urgent = Tuple_out.Hdr.Tcp.urgent.to_uint();
		hdr.tcp.dport = Tuple_out.Hdr.Tcp.dport.to_uint(); 
		hdr.tcp.check = Tuple_out.Hdr.Tcp.check.to_uint(); 
		hdr.tcp.isValid = Tuple_out.Hdr.Tcp.isValid.to_uint(); 
		hdr.tcp.window = Tuple_out.Hdr.Tcp.window.to_uint();
		hdr.tcp.flags = Tuple_out.Hdr.Tcp.flags.to_uint();
		hdr.tcp.ack = Tuple_out.Hdr.Tcp.ack.to_uint();
		hdr.tcp.seq = Tuple_out.Hdr.Tcp.seq.to_uint();
		hdr.tcp.sport = Tuple_out.Hdr.Tcp.sport.to_uint();
		return repeat;
	}
};
//######################################################
// top-level DPI function
extern "C" void headerCompress_0_t_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET
#endif 
