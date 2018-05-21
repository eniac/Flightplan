#ifndef SDNET_ENGINE_fec_0_t
#define SDNET_ENGINE_fec_0_t

#include "sdnet_lib.hpp"
#include "rse.h"

// NOTE we only work with a single block of Vencore's fbk buffer in our prototype
#define FB_INDEX 0

namespace SDNET {

#define BUFFER_SIZE (FEC_MAX_PACKET_SIZE + FEC_PACKET_LENGTH_WIDTH / 8)

//######################################################
class fec_0_t { // UserEngine
public:

	// tuple types
	struct Update_fl_t {
		static const size_t _SIZE = 16;
		_LV<8> k_1;
		_LV<8> h_1;
		Update_fl_t& operator=(_LV<16> _x) {
			k_1 = _x.slice(15,8);
			h_1 = _x.slice(7,0);
			return *this;
		}
		_LV<16> get_LV() { return (k_1,h_1); }
		operator _LV<16>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tk_1 = " + k_1.to_string() + "\n" + "\t\th_1 = " + h_1.to_string() + "\n" + "\t)";
		}
		Update_fl_t() {} 
		Update_fl_t( _LV<8> _k_1, _LV<8> _h_1) {
			k_1 = _k_1;
			h_1 = _h_1;
		}
	};
	struct hdr_t_0 {
		static const size_t _SIZE = 433;
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
			_LV<8> tos;
			_LV<16> len;
			_LV<16> id;
			_LV<3> flags;
			_LV<13> frag;
			_LV<8> ttl;
			_LV<8> proto;
			_LV<16> chksum;
			_LV<32> src;
			_LV<32> dst;
			_struct_ipv4& operator=(_LV<161> _x) {
				isValid = _x.slice(160,160);
				version = _x.slice(159,156);
				ihl = _x.slice(155,152);
				tos = _x.slice(151,144);
				len = _x.slice(143,128);
				id = _x.slice(127,112);
				flags = _x.slice(111,109);
				frag = _x.slice(108,96);
				ttl = _x.slice(95,88);
				proto = _x.slice(87,80);
				chksum = _x.slice(79,64);
				src = _x.slice(63,32);
				dst = _x.slice(31,0);
				return *this;
			}
			_LV<161> get_LV() { return (isValid,version,ihl,tos,len,id,flags,frag,ttl,proto,chksum,src,dst); }
			operator _LV<161>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\tversion = " + version.to_string() + "\n" + "\t\tihl = " + ihl.to_string() + "\n" + "\t\ttos = " + tos.to_string() + "\n" + "\t\tlen = " + len.to_string() + "\n" + "\t\tid = " + id.to_string() + "\n" + "\t\tflags = " + flags.to_string() + "\n" + "\t\tfrag = " + frag.to_string() + "\n" + "\t\tttl = " + ttl.to_string() + "\n" + "\t\tproto = " + proto.to_string() + "\n" + "\t\tchksum = " + chksum.to_string() + "\n" + "\t\tsrc = " + src.to_string() + "\n" + "\t\tdst = " + dst.to_string() + "\n" + "\t)";
			}
			_struct_ipv4() {} 
			_struct_ipv4( _LV<1> _isValid, _LV<4> _version, _LV<4> _ihl, _LV<8> _tos, _LV<16> _len, _LV<16> _id, _LV<3> _flags, _LV<13> _frag, _LV<8> _ttl, _LV<8> _proto, _LV<16> _chksum, _LV<32> _src, _LV<32> _dst) {
				isValid = _isValid;
				version = _version;
				ihl = _ihl;
				tos = _tos;
				len = _len;
				id = _id;
				flags = _flags;
				frag = _frag;
				ttl = _ttl;
				proto = _proto;
				chksum = _chksum;
				src = _src;
				dst = _dst;
			}
		};
		_struct_ipv4 ipv4;
		struct _struct_lldp_tlv_chassis_id {
			static const size_t _SIZE = 25;
			_LV<1> isValid;
			_LV<7> tlv_type;
			_LV<9> tlv_length;
			_LV<8> tlv_value;
			_struct_lldp_tlv_chassis_id& operator=(_LV<25> _x) {
				isValid = _x.slice(24,24);
				tlv_type = _x.slice(23,17);
				tlv_length = _x.slice(16,8);
				tlv_value = _x.slice(7,0);
				return *this;
			}
			_LV<25> get_LV() { return (isValid,tlv_type,tlv_length,tlv_value); }
			operator _LV<25>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\ttlv_type = " + tlv_type.to_string() + "\n" + "\t\ttlv_length = " + tlv_length.to_string() + "\n" + "\t\ttlv_value = " + tlv_value.to_string() + "\n" + "\t)";
			}
			_struct_lldp_tlv_chassis_id() {} 
			_struct_lldp_tlv_chassis_id( _LV<1> _isValid, _LV<7> _tlv_type, _LV<9> _tlv_length, _LV<8> _tlv_value) {
				isValid = _isValid;
				tlv_type = _tlv_type;
				tlv_length = _tlv_length;
				tlv_value = _tlv_value;
			}
		};
		_struct_lldp_tlv_chassis_id lldp_tlv_chassis_id;
		struct _struct_lldp_tlv_port_id {
			static const size_t _SIZE = 25;
			_LV<1> isValid;
			_LV<7> tlv_type;
			_LV<9> tlv_length;
			_LV<8> tlv_value;
			_struct_lldp_tlv_port_id& operator=(_LV<25> _x) {
				isValid = _x.slice(24,24);
				tlv_type = _x.slice(23,17);
				tlv_length = _x.slice(16,8);
				tlv_value = _x.slice(7,0);
				return *this;
			}
			_LV<25> get_LV() { return (isValid,tlv_type,tlv_length,tlv_value); }
			operator _LV<25>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\ttlv_type = " + tlv_type.to_string() + "\n" + "\t\ttlv_length = " + tlv_length.to_string() + "\n" + "\t\ttlv_value = " + tlv_value.to_string() + "\n" + "\t)";
			}
			_struct_lldp_tlv_port_id() {} 
			_struct_lldp_tlv_port_id( _LV<1> _isValid, _LV<7> _tlv_type, _LV<9> _tlv_length, _LV<8> _tlv_value) {
				isValid = _isValid;
				tlv_type = _tlv_type;
				tlv_length = _tlv_length;
				tlv_value = _tlv_value;
			}
		};
		_struct_lldp_tlv_port_id lldp_tlv_port_id;
		struct _struct_lldp_tlv_ttl_id {
			static const size_t _SIZE = 25;
			_LV<1> isValid;
			_LV<7> tlv_type;
			_LV<9> tlv_length;
			_LV<8> tlv_value;
			_struct_lldp_tlv_ttl_id& operator=(_LV<25> _x) {
				isValid = _x.slice(24,24);
				tlv_type = _x.slice(23,17);
				tlv_length = _x.slice(16,8);
				tlv_value = _x.slice(7,0);
				return *this;
			}
			_LV<25> get_LV() { return (isValid,tlv_type,tlv_length,tlv_value); }
			operator _LV<25>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\ttlv_type = " + tlv_type.to_string() + "\n" + "\t\ttlv_length = " + tlv_length.to_string() + "\n" + "\t\ttlv_value = " + tlv_value.to_string() + "\n" + "\t)";
			}
			_struct_lldp_tlv_ttl_id() {} 
			_struct_lldp_tlv_ttl_id( _LV<1> _isValid, _LV<7> _tlv_type, _LV<9> _tlv_length, _LV<8> _tlv_value) {
				isValid = _isValid;
				tlv_type = _tlv_type;
				tlv_length = _tlv_length;
				tlv_value = _tlv_value;
			}
		};
		_struct_lldp_tlv_ttl_id lldp_tlv_ttl_id;
		struct _struct_lldp_prefix {
			static const size_t _SIZE = 17;
			_LV<1> isValid;
			_LV<7> tlv_type;
			_LV<9> tlv_length;
			_struct_lldp_prefix& operator=(_LV<17> _x) {
				isValid = _x.slice(16,16);
				tlv_type = _x.slice(15,9);
				tlv_length = _x.slice(8,0);
				return *this;
			}
			_LV<17> get_LV() { return (isValid,tlv_type,tlv_length); }
			operator _LV<17>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\ttlv_type = " + tlv_type.to_string() + "\n" + "\t\ttlv_length = " + tlv_length.to_string() + "\n" + "\t)";
			}
			_struct_lldp_prefix() {} 
			_struct_lldp_prefix( _LV<1> _isValid, _LV<7> _tlv_type, _LV<9> _tlv_length) {
				isValid = _isValid;
				tlv_type = _tlv_type;
				tlv_length = _tlv_length;
			}
		};
		_struct_lldp_prefix lldp_prefix;
		struct _struct_lldp_activate_fec {
			static const size_t _SIZE = 9;
			_LV<1> isValid;
			_LV<8> tlv_value;
			_struct_lldp_activate_fec& operator=(_LV<9> _x) {
				isValid = _x.slice(8,8);
				tlv_value = _x.slice(7,0);
				return *this;
			}
			_LV<9> get_LV() { return (isValid,tlv_value); }
			operator _LV<9>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\ttlv_value = " + tlv_value.to_string() + "\n" + "\t)";
			}
			_struct_lldp_activate_fec() {} 
			_struct_lldp_activate_fec( _LV<1> _isValid, _LV<8> _tlv_value) {
				isValid = _isValid;
				tlv_value = _tlv_value;
			}
		};
		_struct_lldp_activate_fec lldp_activate_fec;
		struct _struct_lldp_tlv_end {
			static const size_t _SIZE = 25;
			_LV<1> isValid;
			_LV<7> tlv_type;
			_LV<9> tlv_length;
			_LV<8> tlv_value;
			_struct_lldp_tlv_end& operator=(_LV<25> _x) {
				isValid = _x.slice(24,24);
				tlv_type = _x.slice(23,17);
				tlv_length = _x.slice(16,8);
				tlv_value = _x.slice(7,0);
				return *this;
			}
			_LV<25> get_LV() { return (isValid,tlv_type,tlv_length,tlv_value); }
			operator _LV<25>() { return get_LV(); } 
			std::string to_string() const {
				return std::string("(\n")  + "\t\tisValid = " + isValid.to_string() + "\n" + "\t\ttlv_type = " + tlv_type.to_string() + "\n" + "\t\ttlv_length = " + tlv_length.to_string() + "\n" + "\t\ttlv_value = " + tlv_value.to_string() + "\n" + "\t)";
			}
			_struct_lldp_tlv_end() {} 
			_struct_lldp_tlv_end( _LV<1> _isValid, _LV<7> _tlv_type, _LV<9> _tlv_length, _LV<8> _tlv_value) {
				isValid = _isValid;
				tlv_type = _tlv_type;
				tlv_length = _tlv_length;
				tlv_value = _tlv_value;
			}
		};
		_struct_lldp_tlv_end lldp_tlv_end;
		hdr_t_0& operator=(_LV<433> _x) {
			eth = _x.slice(432,320);
			fec = _x.slice(319,287);
			ipv4 = _x.slice(286,126);
			lldp_tlv_chassis_id = _x.slice(125,101);
			lldp_tlv_port_id = _x.slice(100,76);
			lldp_tlv_ttl_id = _x.slice(75,51);
			lldp_prefix = _x.slice(50,34);
			lldp_activate_fec = _x.slice(33,25);
			lldp_tlv_end = _x.slice(24,0);
			return *this;
		}
		_LV<433> get_LV() { return (eth.isValid,eth.dst,eth.src,eth.type,fec.isValid,fec.traffic_class,fec.block_index,fec.packet_index,fec.original_type,ipv4.isValid,ipv4.version,ipv4.ihl,ipv4.tos,ipv4.len,ipv4.id,ipv4.flags,ipv4.frag,ipv4.ttl,ipv4.proto,ipv4.chksum,ipv4.src,ipv4.dst,lldp_tlv_chassis_id.isValid,lldp_tlv_chassis_id.tlv_type,lldp_tlv_chassis_id.tlv_length,lldp_tlv_chassis_id.tlv_value,lldp_tlv_port_id.isValid,lldp_tlv_port_id.tlv_type,lldp_tlv_port_id.tlv_length,lldp_tlv_port_id.tlv_value,lldp_tlv_ttl_id.isValid,lldp_tlv_ttl_id.tlv_type,lldp_tlv_ttl_id.tlv_length,lldp_tlv_ttl_id.tlv_value,lldp_prefix.isValid,lldp_prefix.tlv_type,lldp_prefix.tlv_length,lldp_activate_fec.isValid,lldp_activate_fec.tlv_value,lldp_tlv_end.isValid,lldp_tlv_end.tlv_type,lldp_tlv_end.tlv_length,lldp_tlv_end.tlv_value); }
		operator _LV<433>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\teth = " + eth.to_string() + "\n" + "\t\tfec = " + fec.to_string() + "\n" + "\t\tipv4 = " + ipv4.to_string() + "\n" + "\t\tlldp_tlv_chassis_id = " + lldp_tlv_chassis_id.to_string() + "\n" + "\t\tlldp_tlv_port_id = " + lldp_tlv_port_id.to_string() + "\n" + "\t\tlldp_tlv_ttl_id = " + lldp_tlv_ttl_id.to_string() + "\n" + "\t\tlldp_prefix = " + lldp_prefix.to_string() + "\n" + "\t\tlldp_activate_fec = " + lldp_activate_fec.to_string() + "\n" + "\t\tlldp_tlv_end = " + lldp_tlv_end.to_string() + "\n" + "\t)";
		}
		hdr_t_0() {} 
		hdr_t_0( _LV<113> _eth, _LV<33> _fec, _LV<161> _ipv4, _LV<25> _lldp_tlv_chassis_id, _LV<25> _lldp_tlv_port_id, _LV<25> _lldp_tlv_ttl_id, _LV<17> _lldp_prefix, _LV<9> _lldp_activate_fec, _LV<25> _lldp_tlv_end) {
			eth = _eth;
			fec = _fec;
			ipv4 = _ipv4;
			lldp_tlv_chassis_id = _lldp_tlv_chassis_id;
			lldp_tlv_port_id = _lldp_tlv_port_id;
			lldp_tlv_ttl_id = _lldp_tlv_ttl_id;
			lldp_prefix = _lldp_prefix;
			lldp_activate_fec = _lldp_activate_fec;
			lldp_tlv_end = _lldp_tlv_end;
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
	struct fec_input_t {
		static const size_t _SIZE = 17;
		_LV<1> stateful_valid;
		_LV<8> k;
		_LV<8> h;
		fec_input_t& operator=(_LV<17> _x) {
			stateful_valid = _x.slice(16,16);
			k = _x.slice(15,8);
			h = _x.slice(7,0);
			return *this;
		}
		_LV<17> get_LV() { return (stateful_valid,k,h); }
		operator _LV<17>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tstateful_valid = " + stateful_valid.to_string() + "\n" + "\t\tk = " + k.to_string() + "\n" + "\t\th = " + h.to_string() + "\n" + "\t)";
		}
		fec_input_t() {} 
		fec_input_t( _LV<1> _stateful_valid, _LV<8> _k, _LV<8> _h) {
			stateful_valid = _stateful_valid;
			k = _k;
			h = _h;
		}
	};
	struct fec_output_t {
		static const size_t _SIZE = 8;
		_LV<8> packet_index;
		fec_output_t& operator=(_LV<8> _x) {
			packet_index = _x.slice(7,0);
			return *this;
		}
		_LV<8> get_LV() { return (packet_index); }
		operator _LV<8>() { return get_LV(); } 
		std::string to_string() const {
			return std::string("(\n")  + "\t\tpacket_index = " + packet_index.to_string() + "\n" + "\t)";
		}
		fec_output_t() {} 
		fec_output_t( _LV<8> _packet_index) {
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
	fec_input_t fec_input;
	fec_output_t fec_output;

	int maximum_packet_size;
	int packet_index;

	// engine ctor
	fec_0_t(std::string _n, std::string _filename = "") : _name(_n) {

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
		std::cout << "	fec_input = " << fec_input.to_string() << std::endl;
		// clear internal and output-only tuples:
		std::cout << "clear internal and output-only tuples" << std::endl;
		fec_output = 0;
		std::cout << "	fec_output = " << fec_output.to_string() << std::endl;

		bool generate_packet = false;

		packet_out = packet_in;

		if (fec_input.stateful_valid.to_ulong() == 1)
		{
			unsigned long k = fec_input.k.to_ulong();
			unsigned long h = fec_input.h.to_ulong();

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

			fec_output.packet_index = packet_index;

			packet_index = (packet_index + 1) % (k + h);
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

		return generate_packet;
	}
};
//######################################################
// top-level DPI function
extern "C" void fec_0_t_DPI(const char*, int, const char*, int, int, int);


} // namespace SDNET

#endif // SDNET_ENGINE_fec_0_t
