
Getting started
--------------------------------------
The NTU-DSI-DCN simulation framework is built on top of the core ns-3 simulator (http://www.nsnam.org). The version used is ns-3.13 instead of the latest, for robustness and stability concerns. The fat tree and the BCube architectures have been implemented into the framework. Users can simply simulate the architectures and reproduce their performance models through a simple command line invocation.

More information can be found in our paper:

1. D. Wong, K.T. Seow, C.H. Foh and R. Kanagavelu, “Towards Reproducible Performance Studies of Datacenter Network Architectures Using An Open-Source Simulation Approach”, Proceedings of the IEEE Global Communications Conference (GLOBECOM’13), December 2013, Atlanta, GA, USA. \[[Download as PDF](https://drive.google.com/file/d/0B_2UOgK6adKGRmxGVHRtTkRoaWc/edit?usp=sharing)\]



Pre-requisities
--------------------------------------
- A commodity PC with a Linux-based Operating System (eg. Ubuntu, Fedora, Red Hat etc)
- Mercurial source control tool (http://mercurial.selenic.com)
- Go through the ns-3 tutorial (http://www.nsnam.org/docs/release/3.13/tutorial/singlehtml/index.html) (Optional)
- NTU-DSI-DCN requires ns-3.13 and Ubuntu 12.04 LTS.



Installation Steps
--------------------------------------
- Install a Linux Operating System and the Mercurial tool onto a physical computer. 
- Download the simulation framework by checking out the codes from the 'ntu-dsi-dcn' repository using Mercurial 

```
hg clone https://github.com/ntu-dsi-dcn/ntu-dsi-dcn.git
```

- Setup and install the necessary packages needed by ns-3 in order to compile and run the simulation framework later
(http://www.nsnam.org/wiki/index.php/Installation)


- Go into the project folder 'ntu-dsi-dcn' and run the command to configure the simulation framework first

```
./waf configure
```

- To compile the NTU-DSI-DCN simulation framework

```
./waf
```



Running the simulations
--------------------------------------
The network topologies, configurations for the network devices and protocols, and the traffic flow generation have been implemented and documented. The source codes in the "/scratch" folder contains all the documentation for the implementation details of the architectures, as well as the simulation settings that are used. Users can customize the codes and/or edit the setting variables if necessary for their own needs.

- To simulate the Fat tree architecture, use this command:

```
./waf --run scratch/Fat-tree
```

- To simulate the BCube architecture, use this command:

```
./waf --run scratch/BCube
```

- To run the experiments stated in the paper's discussion on 'Section IV: Towards Reproducible Simulation Studies', use these commands:

```
./waf --run scratch/Fat-tree-Bilal

./waf --run scratch/Fat-tree-AlFares
```

- The performance statistics outputs are generated in the "/statistics" folder in XML format. Statistics output information such as the average throughput, number of packets transmitted and packet delay can be found by opening the XML file in a text editor. For example, consider this command:

```
./waf --run scratch/Fat-tree 
```

The above command will produce a "/statistics/Fat-tree.xml" output file with the statistics information when the simulation is completed.




Extending the simulation framework
--------------------------------------
If you wish to extend a DCN topology of interest, which is currently not found in the framework, use the simulation codes in the "/scratch" folder as the basis template to get started.

The source code documentation and comments should give you some idea of how to go about building a new DCN topology.

If you wish to contribute a DCN performance model that you have built into NTU-DSI-DCN framework (or any other improvements that you might have), drop us an email over at ntu.dsi.dcn@gmail.com and we can get in touch to discuss the details. Due credits and acknowledgement will be given to the work done by the original authors. We strictly do not claim ownership of works not done by us.




Contributions from the community
--------------------------------------
16 Jan 2015 - Arfath Ahamed's Fat-tree implementation with NetAnim on ns-3.21.

For those who wish to use this framework to simulate the Fat-tree architecture on ns-3.21 and above, you can use the following source codes contributed by Arfath Ahamed. He can be contacted at <arfathsm@gmail.com>. Download these source codes into the "/scratch" folder of ns-3 to run it. 

- [Fat-tree] (https://drive.google.com/file/d/0B_2UOgK6adKGajM5ODhuV01yN0U/view?usp=sharing)
- [Fat-tree by Bilal et al] (https://drive.google.com/file/d/0B_2UOgK6adKGSWlnOTM5a0k3YjQ/view?usp=sharing)
- [Fat-tree by Al-Fares] (https://drive.google.com/file/d/0B_2UOgK6adKGQklfS1ZiaFRxejQ/view?usp=sharing) 


Researchers
--------------------------------------
* Daji Wong
* Kiam Tian Seow
* Chuan Heng Foh
* Renuga Kanagavelu
* Ngoc Linh Vu

This research initiative is a collaborative effort between Nanyang Technological University (Singapore) and A*STAR Data Storage Institute (Singapore).

License
--------------------------------------
Licensed under the [GNU General Public License](https://github.com/ntu-dsi-dcn/ntu-dsi-dcn/blob/master/LICENSE).
