#include "XilinxSwitch.hpp"

namespace SDNET {

// top-level DPI function
extern "C" void XilinxSwitch_DPI( 
	const char* _packet_in_filename,            
	int   _bozo1, // dont care                  
	const char* _tuple_in_filename,             
	int   _packet_out_format, // 0:LBUS; 1:AXI  
	int   _bus_width,                           
	int   _bozo2  // dont care                  
) {
		// TODO: convert packet file to vector of packets
		std::vector<Packet> _packets;
		bool _swapped = true;
		std::ifstream _packet_user(_packet_in_filename, std::fstream::in | std::fstream::binary);
		if(!_packet_user.is_open()) {
		    std::cerr << "Could not open input packet file: " << _packet_in_filename << std::endl;
		    exit(1);
		}
		bool _PCAP = false;
		if (ReadPcapGlobalHeader(_packet_user, _swapped)) {
		    std::cerr << "detected PCAP format" << std::endl;
		    _PCAP = true;
		} else {
		    std::cerr << "detected TEXT format" << std::endl;
		    _packet_user.clear();
		    _packet_user.seekg(0);
		};
		while(_packet_user.good() && !_packet_user.bad() && !_packet_user.eof()) {
		    Packet _packet = _PCAP ? ReadPcapPacket(_packet_user, _swapped) : ReadPacket(_packet_user);
		    if (_packet.empty()) break;
		    _packets.push_back(_packet);
		}
		std::cerr << "Read in " << _packets.size() << " packets" << std::endl;
		// convert tuple file to vector of vector of strings according to the number of input+inout tuples
		std::vector<std::vector<std::string>> _tuples;
		std::ifstream _tuple_user(_tuple_in_filename);
		std::string _tuple_str;
		std::vector<std::string> _tuple_vector;
		if(!_tuple_user.is_open()) {
		    std::cerr << "Could not open input tuple file: " << _tuple_in_filename << ", setting all input/inout tuples to zero" << std::endl;
		    _tuple_vector.resize(1, "0");
		    _tuples.resize(_packets.size(), _tuple_vector);
		}
		else {  
		  int t =1;
		  while(!_tuple_user.eof()) {
		    std::string line;
		    std::getline(_tuple_user, line);
		    if (line.length() == 0) {
		      continue;
		    } else if (line.find_first_of('#') != std::string::npos) {
		      // strip comments
		      size_t i = line.find_first_of('#');
		      line.erase(i, line.length()-i);
		      if (line.length() == 0)
		        continue;
		    }
		    std::istringstream iss(line);
		    for (; iss >> _tuple_str; t++) {   		    
		      _tuple_vector.push_back(_tuple_str);  
		      //std::cout << "Reading token #" << t << " " << _tuple_str << std::endl;          
		      if (t % 1 == 0) {            
			_tuples.push_back(_tuple_vector);           
			_tuple_vector.clear();                      
		      }                                               
		    } 
		  }                                                  
		}                                                       
		// TODO: check for the same number of packets and tuples
		// TODO: check for tuple engine and resize _packets
		// create/open packet stimulus file
		std::ofstream _packet_in_pcap("Packet_in.pcap");
		std::ofstream _packet_in_bus(_packet_out_format ? "Packet_in.axi" : "Packet_in.lbus");
		// create/open packet checker file
		std::ofstream _packet_out_pcap("Packet_expect.pcap");
		std::ofstream _packet_out_bus(_packet_out_format ? "Packet_expect.axi" : "Packet_expect.lbus");
		WritePcapGlobalHeader(_packet_in_pcap);
		WritePcapGlobalHeader(_packet_out_pcap);
		// create/open tuple stimulus file
		std::ofstream _tuple_in_stream("Tuple_in.txt");
		// create/open tuple checker file
		std::ofstream _tuple_out_stream("Tuple_expect.txt");
		// engine instance
		XilinxSwitch _DUT("XilinxSwitch");
		// packet/tuple evaluation loop
		for (int _p = 0; _p < _packets.size(); _p++) {
			std::cout << "Evaluating packet #" << (_p+1) << '(' << _packets[_p].size() << " bytes)" << std::endl;
			std::cout << _packets[_p];
			// input packet
			_DUT.packet_in = _packets[_p];
			WritePcapPacket(_packet_in_pcap,  _packets[_p]);
			busFormatPacket(_packet_in_bus,   _packets[_p], _bus_width, _packet_out_format);
			// load input and inout tuples
			_DUT.ioports = _LV<8>(_tuples[_p][0], 16);
			// format input and inout tuples
			_tuple_in_stream << ((_LV<8>)_DUT.ioports).to_hex() << ' ';
			_tuple_in_stream << std::endl;
			bool repeat;
			do
			{
  			  // eval engine
			  repeat = _DUT();
			  // format packet
			  WritePcapPacket(_packet_out_pcap,  _DUT.packet_out);
			  busFormatPacket(_packet_out_bus,   _DUT.packet_out, _bus_width, _packet_out_format);
			  // format output and inout tuples
			  _tuple_out_stream << ((_LV<8>)_DUT.ioports).to_hex() << ' ';
			  _tuple_out_stream << std::endl;
			} while (repeat);
		} // for _p
		// close files
		_packet_in_pcap.close();
		_packet_in_bus.close();
		_packet_in_pcap.close();
		_packet_in_bus.close();
		_tuple_in_stream.close();
		_tuple_out_stream.close();
	} // XilinxSwitch_DPI

} // namespace SDNET

int main(int argc, char *argv[]) {
	char *packet_user_filename = (argc > 1) ? argv[1] : (char*)"Packet.user";
	char *tuple_user_filename  = (argc > 2) ? argv[2] : (char*)"Tuple.user";
	int bus_type               =  1; 
	int bus_width              = 64;
	SDNET::XilinxSwitch_DPI(packet_user_filename, 0, tuple_user_filename, bus_type, bus_width, 0);
	return 0;
}

