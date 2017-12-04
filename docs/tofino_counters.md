#### Fixed counters in the Tofino ####


The Tofino has many fixed counters at different points in its hardware data
path. These can be accessed through the bf-sde runtime CLI or Thrift
interface.

##### Path Counters #####
Interface: ```bf-sde.pipe_mgr.pkt_path_counter```


Counters:
- Hdr byte counter. 
- Idle counter. 
- Pkt drop counter. 
- Output FIFO full counter. 
- Output FIFO full stall counter. 
- No TCAM match counter. 
- Partial Hdr error counter. 
- Ctr Range error counter. 
- Excess state iterations error counter. 
- Excess clock cycles error counter. - 
- Extraction source error counter. 
- Container destination/size error counter. 
- PHV Ownership error counter. 
- PHV Multi Wr error counter. 
- Action RAM single-bit error counter. 
- Action RAM multie-bit error counter. 
- FCS error counter. 
- Checksum error counter. 
- TCAM parity error counter. 
- Channel Deparser Packet Dropped. Number of packet which have been dropped as a result of the MAU/Deparser.
- Channel Statistics Packet Discarded inside the ingress buffer. Number of packet which have been discarded due to the ingress buffer being full.
- Channel Statistics Packet Truncated inside the ingress buffer. Number of packet which have been truncated (truncated and flag with error due to the ingress buffer being full.
- Channel Statistics Packet Discarded. Number of recirculated packet which have been discarded due to the ingress buffer being full.
- Channel Statistics Packet Discarded. Number of packet which have been discarded by the parser due to the ingress buffer being almost full.
- Channel Statistics Packet Sent to Parser. Number of packet which have been sent to the parser.
- Channel Statistics Packet Sent to Deparser. Number of packet which have been sent to the deparser.
- Channel Statistics Packet Received from MAC. Number of packet which have been received from the MAC.
- Channel Statistics Packet Received for recirculation. Number of packet which have been received for recirculation.
- Egress Bypass packet counter. Count the number of packet bypassing the egress pipeline 
- Egress Pipelinine Packet counter. Count the number of packet to Egress pipe for this channel
- FCS and checksum are parser errors.

##### Parser Counters #####

Interface: ```bf-sde.pipe_mgr.iprsr-counter```

Counters: 
-  Total Pkts Dropped on Channel			*(prsr_reg.pkt_drop_cnt[	]   )*
-  output fifo full counter              	*(prsr_reg.op_fifo_full_cnt     )*
-  output fifo stall counter             	*(prsr_reg.op_fifo_full_stall_cnt)*
-  TCAM match Error                      	*(prsr_reg.no_tcam_match_err_cnt)*
-  Counter Range Error                   	*(prsr_reg.ctr_range_err_cnt    )*
-  Timeout or Excess state iteration Error	*(prsr_reg.timeout_iter_err_cnt )*
-  Timeout or Excess clock cycle         	*(prsr_reg.timeout_cycle_err_cnt)*
-  Extraction source error counter       	*(prsr_reg.src_ext_err_cnt      )*
-  Container size error counter          	*(prsr_reg.dst_cont_err_cnt     )*
-  PHV owner error counter               	*(prsr_reg.phv_owner_err_cnt    )*
-  PHV multiple write error              	*(prsr_reg.multi_wr_err_cnt     )*
-  FCS error                             	*(prsr_reg.fcs_err_cnt          )*
-  Checksum error                        	*(prsr_reg.csum_err_cnt         )*
-  TCAM parity error                     	*(prsr_reg.tcam_par_err_cnt  )*
