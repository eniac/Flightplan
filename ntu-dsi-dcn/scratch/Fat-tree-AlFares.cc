// Construction of Fat-tree Architecture
// Authors: Linh Vu, Daji Wong

/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * Copyright (c) 2013 Nanyang Technological University 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Authors: Linh Vu <linhvnl89@gmail.com>, Daji Wong <wong0204@e.ntu.edu.sg>
 */

#include <iostream>
#include <fstream>
#include <string>
#include <cassert>

#include "ns3/flow-monitor-module.h"
#include "ns3/bridge-helper.h"
#include "ns3/bridge-net-device.h"
#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/applications-module.h"
#include "ns3/ipv4-global-routing-helper.h"
#include "ns3/csma-module.h"
#include "ns3/ipv4-nix-vector-helper.h"
#include "ns3/random-variable.h"

/*
	- This work goes along with the paper "Towards Reproducible Performance Studies of Datacenter Network Architectures Using An Open-Source Simulation Approach"

	- The code is constructed in the following order:
		1. Creation of Node Containers 
		2. Initialize settings for On/Off Application
		3. Connect hosts to edge switches
		4. Connect edge switches to aggregate switches
		5. Connect aggregate switches to core switches
		6. Start Simulation

	- Addressing scheme:
		1. Address of host: 10.pod.switch.0 /24
		2. Address of edge and aggregation switch: 10.pod.switch.0 /16
		3. Address of core switch: 10.(group number + k).switch.0 /8
		   (Note: there are k/2 group of core switch)

	- On/Off Traffic of the simulation: addresses of client and server are randomly selected everytime
	
	- Simulation Settings:
                - Number of nodes: 16-3456
                - Number of pods (k): 4, 16, 24
		- Simulation running time: 100 seconds
		- Packet size: 1024 bytes
		- Data rate for packet sending: 96 Mbps
		- Data rate for device channel: 1536 Mbps
		- Delay time for device: 0.001 ms
		- Communication pairs selection: Random Selection with uniform probability
		- Traffic flow pattern: Exponential random traffic
		- Routing protocol: Nix-Vector


        - Statistics Output:
                - Flowmonitor XML output file: Fat-tree-AlFares.xml is located in the /statistics folder
                 


*/

using namespace ns3;
using namespace std;
NS_LOG_COMPONENT_DEFINE ("Fat-Tree-Architecture");

// Function to create address string from numbers
//
char * toString(int a,int b, int c, int d){

	int first = a;
	int second = b;
	int third = c;
	int fourth = d;

	char *address =  new char[30];
	char firstOctet[30], secondOctet[30], thirdOctet[30], fourthOctet[30];	
	//address = firstOctet.secondOctet.thirdOctet.fourthOctet;

	bzero(address,30);

	snprintf(firstOctet,10,"%d",first);
	strcat(firstOctet,".");
	snprintf(secondOctet,10,"%d",second);
	strcat(secondOctet,".");
	snprintf(thirdOctet,10,"%d",third);
	strcat(thirdOctet,".");
	snprintf(fourthOctet,10,"%d",fourth);

	strcat(thirdOctet,fourthOctet);
	strcat(secondOctet,thirdOctet);
	strcat(firstOctet,secondOctet);
	strcat(address,firstOctet);

	return address;
}

// Main function
//
int 
	main(int argc, char *argv[])
{
//=========== Define parameters based on value of k ===========//
//
	int k = 4;			// number of ports per switch
	int num_pod = k;		// number of pod
	int num_host = (k/2);		// number of hosts under a switch
	int num_edge = (k/2);		// number of edge switch in a pod
	int num_bridge = num_edge;	// number of bridge in a pod
	int num_agg = (k/2);		// number of aggregation switch in a pod
	int num_group = k/2;		// number of group of core switches
        int num_core = (k/2);		// number of core switch in a group
	int total_host = k*k*k/4;	// number of hosts in the entire network	
	char filename [] = "statistics/Fat-tree-AlFares.xml";// filename for Flow Monitor xml output file

// Define variables for On/Off Application
// These values will be used to serve the purpose that addresses of server and client are selected randomly
// Note: the format of host's address is 10.pod.switch.(host+2)
//
	int podRand = 0;	//	
	int swRand = 0;		// Random values for servers' address
	int hostRand = 0;	//

	int rand1 =0;		//
	int rand2 =0;		// Random values for clients' address	
	int rand3 =0;		//

// Initialize other variables
//
	int i = 0;	
	int j = 0;	
	int h = 0;

// Initialize parameters for On/Off application
//
	int port = 9;
	int packetSize = 1024;		// 1024 bytes
	char dataRate_OnOff [] = "96Mbps";
	char maxBytes [] = "70000";	// 70,000 bytes

// Initialize parameters for Csma and PointToPoint protocol
//
	char dataRate [] = "1536Mbps";	// 1Gbps
	int delay = 0.001;		// 0.001 ms

	
// Output some useful information
//	
	std::cout << "Value of k =  "<< k<<"\n";
	std::cout << "Total number of hosts =  "<< total_host<<"\n";
	std::cout << "Number of hosts under each switch =  "<< num_host<<"\n";
	std::cout << "Number of edge switch under each pod =  "<< num_edge<<"\n";
	std::cout << "------------- "<<"\n";

// Initialize Internet Stack and Routing Protocols
//	
	InternetStackHelper internet;
	Ipv4NixVectorHelper nixRouting; 
	Ipv4StaticRoutingHelper staticRouting;
	Ipv4ListRoutingHelper list;
	list.Add (staticRouting, 0);	
	list.Add (nixRouting, 10);	
	internet.SetRoutingHelper(list);

//=========== Creation of Node Containers ===========//
//
	NodeContainer core[num_group];				// NodeContainer for core switches
	for (i=0; i<num_group;i++){  	
		core[i].Create (num_core);
		internet.Install (core[i]);		
	}
	NodeContainer agg[num_pod];				// NodeContainer for aggregation switches
	for (i=0; i<num_pod;i++){  	
		agg[i].Create (num_agg);
		internet.Install (agg[i]);
	}
	NodeContainer edge[num_pod];				// NodeContainer for edge switches
  	for (i=0; i<num_pod;i++){  	
		edge[i].Create (num_bridge);
		internet.Install (edge[i]);
	}
	NodeContainer bridge[num_pod];				// NodeContainer for edge bridges
  	for (i=0; i<num_pod;i++){  	
		bridge[i].Create (num_bridge);
		internet.Install (bridge[i]);
	}
	NodeContainer host[num_pod][num_bridge];		// NodeContainer for hosts
  	for (i=0; i<k;i++){
		for (j=0;j<num_bridge;j++){  	
			host[i][j].Create (num_host);		
			internet.Install (host[i][j]);
		}
	}

//=========== Initialize settings for On/Off Application ===========//
//

// Generate traffics for the simulation
//	
	ApplicationContainer app[total_host];
	for (i=0;i<total_host;i++){	
	// Randomly select a server
		podRand = rand() % num_pod + 0;
		swRand = rand() % num_edge + 0;
		hostRand = rand() % num_host + 0;
		hostRand = hostRand+2;
		char *add;
		add = toString(10, podRand, swRand, hostRand);

	// Initialize On/Off Application with addresss of server
		OnOffHelper oo = OnOffHelper("ns3::UdpSocketFactory",Address(InetSocketAddress(Ipv4Address(add), port))); // ip address of server
	        oo.SetAttribute("OnTime",RandomVariableValue(ExponentialVariable(1)));  
	        oo.SetAttribute("OffTime",RandomVariableValue(ExponentialVariable(1))); 
 	        oo.SetAttribute("PacketSize",UintegerValue (packetSize));
 	       	oo.SetAttribute("DataRate",StringValue (dataRate_OnOff));      
	        oo.SetAttribute("MaxBytes",StringValue (maxBytes));

	// Randomly select a client
		rand1 = rand() % num_pod + 0;
		rand2 = rand() % num_edge + 0;
		rand3 = rand() % num_host + 0;

		while (rand1== podRand && swRand == rand2 && (rand3+2) == hostRand){
			rand1 = rand() % num_pod + 0;
			rand2 = rand() % num_edge + 0;
			rand3 = rand() % num_host + 0;
		} // to make sure that client and server are different

	// Install On/Off Application to the client
		NodeContainer onoff;
		onoff.Add(host[rand1][rand2].Get(rand3));
	     	app[i] = oo.Install (onoff);
	}
	std::cout << "Finished creating On/Off traffic"<<"\n";

// Inintialize Address Helper
//	
  	Ipv4AddressHelper address;

// Initialize PointtoPoint helper
//	
	PointToPointHelper p2p;
  	p2p.SetDeviceAttribute ("DataRate", StringValue (dataRate));
  	p2p.SetChannelAttribute ("Delay", TimeValue (MilliSeconds (delay)));

// Initialize Csma helper
//
  	CsmaHelper csma;
  	csma.SetChannelAttribute ("DataRate", StringValue (dataRate));
  	csma.SetChannelAttribute ("Delay", TimeValue (MilliSeconds (delay)));

//=========== Connect edge switches to hosts ===========//
//	
	NetDeviceContainer hostSw[num_pod][num_bridge];		
	NetDeviceContainer bridgeDevices[num_pod][num_bridge];	
	Ipv4InterfaceContainer ipContainer[num_pod][num_bridge];

	for (i=0;i<num_pod;i++){
		for (j=0;j<num_bridge; j++){
			NetDeviceContainer link1 = csma.Install(NodeContainer (edge[i].Get(j), bridge[i].Get(j)));
			hostSw[i][j].Add(link1.Get(0));				
			bridgeDevices[i][j].Add(link1.Get(1));			

			for (h=0; h< num_host;h++){			
				NetDeviceContainer link2 = csma.Install (NodeContainer (host[i][j].Get(h), bridge[i].Get(j)));
				hostSw[i][j].Add(link2.Get(0));			
				bridgeDevices[i][j].Add(link2.Get(1));						
			}

			BridgeHelper bHelper;
			bHelper.Install (bridge[i].Get(j), bridgeDevices[i][j]);
			//Assign address
			char *subnet;
			subnet = toString(10, i, j, 0);
			address.SetBase (subnet, "255.255.255.0");
			ipContainer[i][j] = address.Assign(hostSw[i][j]);			
		}
	}
	std::cout << "Finished connecting edge switches and hosts  "<< "\n";

//=========== Connect aggregate switches to edge switches ===========//
//
	NetDeviceContainer ae[num_pod][num_agg][num_edge]; 	
	Ipv4InterfaceContainer ipAeContainer[num_pod][num_agg][num_edge];
	for (i=0;i<num_pod;i++){
		for (j=0;j<num_agg;j++){
			for (h=0;h<num_edge;h++){
				ae[i][j][h] = p2p.Install(agg[i].Get(j), edge[i].Get(h));

				int second_octet = i;		
				int third_octet = j+(k/2);	
				int fourth_octet;
				if (h==0) fourth_octet = 1;
				else fourth_octet = h*2+1;
				//Assign subnet
				char *subnet;
				subnet = toString(10, second_octet, third_octet, 0);
				//Assign base
				char *base;
				base = toString(0, 0, 0, fourth_octet);
				address.SetBase (subnet, "255.255.255.0",base);
				ipAeContainer[i][j][h] = address.Assign(ae[i][j][h]);
			}			
		}		
	}
	std::cout << "Finished connecting aggregation switches and edge switches  "<< "\n";

//=========== Connect core switches to aggregate switches ===========//
//
	NetDeviceContainer ca[num_group][num_core][num_pod]; 		
	Ipv4InterfaceContainer ipCaContainer[num_group][num_core][num_pod];
	int fourth_octet =1;
	
	for (i=0; i<num_group; i++){		
		for (j=0; j < num_core; j++){
			fourth_octet = 1;
			for (h=0; h < num_pod; h++){			
				ca[i][j][h] = p2p.Install(core[i].Get(j), agg[h].Get(i)); 	

				int second_octet = k+i;		
				int third_octet = j;
				//Assign subnet
				char *subnet;
				subnet = toString(10, second_octet, third_octet, 0);
				//Assign base
				char *base;
				base = toString(0, 0, 0, fourth_octet);
				address.SetBase (subnet, "255.255.255.0",base);
				ipCaContainer[i][j][h] = address.Assign(ca[i][j][h]);
				fourth_octet +=2;
			}
		}
	}
	std::cout << "Finished connecting core switches and aggregation switches  "<< "\n";
	std::cout << "------------- "<<"\n";

//=========== Start the simulation ===========//
//

	std::cout << "Start Simulation.. "<<"\n";
	for (i=0;i<total_host;i++){
		app[i].Start (Seconds (0.0));
  		app[i].Stop (Seconds (100.0));
	}
  	Ipv4GlobalRoutingHelper::PopulateRoutingTables ();
// Calculate Throughput using Flowmonitor
//
  	FlowMonitorHelper flowmon;
	Ptr<FlowMonitor> monitor = flowmon.InstallAll();
// Run simulation.
//
  	NS_LOG_INFO ("Run Simulation.");
  	Simulator::Stop (Seconds(101.0));
  	Simulator::Run ();

  	monitor->CheckForLostPackets ();
  	monitor->SerializeToXmlFile(filename, true, true);

	std::cout << "Simulation finished "<<"\n";

  	Simulator::Destroy ();
  	NS_LOG_INFO ("Done.");

	return 0;
}




