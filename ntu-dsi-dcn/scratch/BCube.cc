// Construction of BCube Architecture
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

/*
	- This work goes along with the paper "Towards Reproducible Performance Studies of Datacenter Network Architectures Using An Open-Source Simulation Approach"

	- The code is constructed in the following order:
		1. Creation of Node Containers 
		2. Initialize settings for On/Off Application
		3. Connect hosts level 0 switches
		4. Connect hosts level 1 switches
		5. Connect hosts level 2 switches
		6. Start Simulation

	- Addressing scheme:
		1. Address of host: 10.level.switch.0 /24
		2. Address of BCube switch: 10.level.switch.0 /16

	- On/Off Traffic of the simulation: addresses of client and server are randomly selected everytime	

	- Simulation Settings:
                - Number of nodes: 64-3375 (run the simulation with different values of n)
                - Number of BCube levels: 3 (ie k=2 is fixed)
                - Number of nodes in BCube0 (n): 4-15
		- Simulation running time: 100 seconds
		- Packet size: 1024 bytes
		- Data rate for packet sending: 1 Mbps
		- Data rate for device channel: 1000 Mbps
		- Delay time for device: 0.001 ms
		- Communication pairs selection: Random Selection with uniform probability
		- Traffic flow pattern: Exponential random traffic
		- Routing protocol: Nix-Vector
        
        - Statistics Output:
                - Flowmonitor XML output file: BCube.xml is located in the /statistics folder
            
*/


using namespace ns3;
using namespace std;

NS_LOG_COMPONENT_DEFINE ("BCube-Architecture");

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

  	LogComponentEnable ("UdpEchoClientApplication", LOG_LEVEL_INFO);
  	LogComponentEnable ("UdpEchoServerApplication", LOG_LEVEL_INFO);

//=========== Define parameters based on value of k ===========//
//
	int k = 2;			// number of BCube level, For BCube with 3 levels, level0 to level2, k should be set as 2			
	int n = 4;			// number of servers in one BCube;
	int num_sw = pow (n,k);		// number of switch at each level (all levels have same number of switch) = n^k;
	int num_host = num_sw*n;	// total number of host
	char filename [] = "statistics/BCube.xml";	// filename for Flow Monitor xml output file

// Initialize other variables
//
	int i = 0;		
	int j = 0;				
	int temp = 0;		

// Define variables for On/Off Application
// These values will be used to serve the purpose that addresses of server and client are selected randomly
// Note: the format of host's address is 10.pod.switch.(host+2)
//
	int levelRand = 0;	//	
	int swRand = 0;		// Random values for servers' address
	int hostRand = 0;	//

	int randHost =0;	// Random values for clients' address

// Initialize parameters for On/Off application
//
	int port = 9;
	int packetSize = 1024;		// 1024 bytes
	char dataRate_OnOff [] = "1Mbps";
	char maxBytes [] = "0";		// unlimited

// Initialize parameters for Csma protocol
//
	char dataRate [] = "1000Mbps";	// 1Gbps
	int delay = 0.001;		// 0.001 ms

// Output some useful information
//	
	std::cout << "Number of BCube level =  "<< k+1<<"\n";
	std::cout << "Number of switch in each BCube level =  "<< num_sw<<"\n";
	std::cout << "Number of host under each switch =  "<< n <<"\n";
	std::cout << "Total number of host =  "<< num_host<<"\n";

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
	NodeContainer host;				// NodeContainer for hosts;  				
	host.Create (num_host);				
	internet.Install (host);			

	NodeContainer swB0;				// NodeContainer for B0 switches 
	swB0.Create (num_sw);				
	internet.Install (swB0);
				
	NodeContainer bridgeB0;				// NodeContainer for B0 bridges
  	bridgeB0.Create (num_sw);
	internet.Install (bridgeB0);

	NodeContainer swB1;				// NodeContainer for B1 switches
	swB1.Create (num_sw);				
	internet.Install (swB1);			

	NodeContainer bridgeB1;				// NodeContainer for B1 bridges
  	bridgeB1.Create (num_sw);
	internet.Install (bridgeB1);

	NodeContainer swB2;				// NodeContainer for B2 switches
	swB2.Create (num_sw);				
	internet.Install (swB2);			

	NodeContainer bridgeB2;				// NodeContainer for B2 bridges
	bridgeB2.Create (num_sw);
	internet.Install (bridgeB2);


//=========== Initialize settings for On/Off Application ===========//
//

// Generate traffics for the simulation
//
	ApplicationContainer app[num_host];
	for (i=0;i<num_host;i++){
	// Randomly select a server
		levelRand = 0;
		swRand = rand() % num_sw + 0;
		hostRand = rand() % n + 0;
		hostRand = hostRand+2;
		char *add;
		add = toString(10, levelRand, swRand, hostRand);

	// Initialize On/Off Application with addresss of server
		OnOffHelper oo = OnOffHelper("ns3::UdpSocketFactory",Address(InetSocketAddress(Ipv4Address(add), port))); // ip address of server
	        oo.SetAttribute("OnTime",RandomVariableValue(ExponentialVariable(1)));  
	        oo.SetAttribute("OffTime",RandomVariableValue(ExponentialVariable(1))); 
 	        oo.SetAttribute("PacketSize",UintegerValue (packetSize));
 	       	oo.SetAttribute("DataRate",StringValue (dataRate_OnOff));      
	        oo.SetAttribute("MaxBytes",StringValue (maxBytes));

	// Randomly select a client
		randHost = rand() % num_host + 0;		
		int temp = n*swRand + (hostRand-2);
		while (temp== randHost){
			randHost = rand() % num_host + 0;
		} 
		// to make sure that client and server are different

	// Install On/Off Application to the client
		NodeContainer onoff;
		onoff.Add(host.Get(randHost));
	     	app[i] = oo.Install (onoff);
	}

	std::cout << "Finished creating On/Off traffic"<<"\n";	
// Inintialize Address Helper
//	
  	Ipv4AddressHelper address;

// Initialize Csma helper
//
  	CsmaHelper csma;
  	csma.SetChannelAttribute ("DataRate", StringValue (dataRate));
  	csma.SetChannelAttribute ("Delay", TimeValue (MilliSeconds (delay)));

//=========== Connect BCube 0 switches to hosts ===========//
//	
	NetDeviceContainer hostSwDevices0[num_sw];		
	NetDeviceContainer bridgeDevices0[num_sw];		
	Ipv4InterfaceContainer ipContainer0[num_sw];

	temp = 0;
	for (i=0;i<num_sw;i++){
		NetDeviceContainer link1 = csma.Install(NodeContainer (swB0.Get(i), bridgeB0.Get(i)));
		hostSwDevices0[i].Add(link1.Get(0));			
		bridgeDevices0[i].Add(link1.Get(1));			
		temp = j;
		for (j=temp;j<temp+n; j++){
			NetDeviceContainer link2 = csma.Install(NodeContainer (host.Get(j), bridgeB0.Get(i)));
			hostSwDevices0[i].Add(link2.Get(0));		
			bridgeDevices0[i].Add(link2.Get(1));			 
		}	
		BridgeHelper bHelper0;
		bHelper0.Install (bridgeB0.Get(i), bridgeDevices0[i]);	
		//Assign address
		char *subnet;
		subnet = toString(10, 0, i, 0);
		address.SetBase (subnet, "255.255.255.0");
		ipContainer0[i] = address.Assign(hostSwDevices0[i]);	
	}
	std::cout <<"Fininshed BCube 0 connection"<<"\n";

//=========== Connect BCube 1 switches to hosts ===========//
//
	NetDeviceContainer hostSwDevices1[num_sw];		
	NetDeviceContainer bridgeDevices1[num_sw];		
	Ipv4InterfaceContainer ipContainer1[num_sw];
	
	j = 0; temp = 0;

	for (i=0;i<num_sw;i++){
		NetDeviceContainer link1 = csma.Install(NodeContainer (swB1.Get(i), bridgeB1.Get(i)));
		hostSwDevices1[i].Add(link1.Get(0));			
		bridgeDevices1[i].Add(link1.Get(1));
	
		if (i==0){
			j = 0; 
			temp = j;
		}

		if (i%n !=0){
			j = temp + 1;
			temp = j;
		}

		if ((i%n == 0)&&(i!=0)){
			j = temp - n + 1;
			j = j + n*n;
			temp = j;
		}
		
		for (j=temp;j<temp+n*n; j=j+n){
			NetDeviceContainer link2 = csma.Install(NodeContainer (host.Get(j), bridgeB1.Get(i)));
			hostSwDevices1[i].Add(link2.Get(0));		
			bridgeDevices1[i].Add(link2.Get(1));			 
		}	
		BridgeHelper bHelper1;
		bHelper1.Install (bridgeB1.Get(i), bridgeDevices1[i]);
		//Assign address
		char *subnet;
		subnet = toString(10, 1, i, 0);
		address.SetBase (subnet, "255.255.255.0");
		ipContainer1[i] = address.Assign(hostSwDevices1[i]);		
	}
	std::cout <<"Fininshed BCube 1 connection"<<"\n";

//=========== Connect BCube 2 switches to hosts ===========//
//
	NetDeviceContainer hostSwDevices2[num_sw];		
	NetDeviceContainer bridgeDevices2[num_sw];	
	Ipv4InterfaceContainer ipContainer2[num_sw];
	
	j = 0; temp = 0; 
	int temp2 =n*n;
	int temp3 = n*n*n;

	for (i=0;i<num_sw;i++){
		NetDeviceContainer link1 = csma.Install(NodeContainer (swB2.Get(i), bridgeB2.Get(i)));
		hostSwDevices2[i].Add(link1.Get(0));			
		bridgeDevices2[i].Add(link1.Get(1));

		if (i==0){
			j = 0; 
			temp = j;
		}

		if (i%temp2 !=0){
			j = temp + 1;
			temp = j;
		}

		if ((i%temp2 == 0)&&(i!=0)){
			j = temp - temp2 + 1;
			j = j + temp3;
			temp = j;
		}

		for (j=temp;j<temp+temp3; j=j+temp2){
			NetDeviceContainer link2 = csma.Install(NodeContainer (host.Get(j), bridgeB2.Get(i)));
			hostSwDevices2[i].Add(link2.Get(0));		
			bridgeDevices2[i].Add(link2.Get(1)); 
		}	
		BridgeHelper bHelper2;
		bHelper2.Install (bridgeB2.Get(i), bridgeDevices2[i]);	
		//Assign address
		char *subnet;
		subnet = toString(10, 2, i, 0);
		address.SetBase (subnet, "255.255.255.0");
		ipContainer2[i] = address.Assign(hostSwDevices2[i]);
		
	}
	std::cout <<"Fininshed BCube 2 connection"<<"\n";
	std::cout << "------------- "<<"\n";

//=========== Start the simulation ===========//
//

	std::cout << "Start Simulation.. "<<"\n";
	for (i=0;i<num_host;i++){
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
  	monitor->SerializeToXmlFile(filename, true, false);

	std::cout << "Simulation finished "<<"\n";

  	Simulator::Destroy ();
  	NS_LOG_INFO ("Done.");

	return 0;
}
