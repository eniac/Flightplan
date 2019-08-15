1)Follow the steps in sections 9,10,11 and 12 to install and test snort on your machine.
https://snort-org-site.s3.amazonaws.com/production/document_files/files/000/000/122/original/Snort_2.9.9.x_on_Ubuntu_14-16.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIXACIED2SPMSC7GA%2F20190808%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190808T143428Z&X-Amz-Expires=172800&X-Amz-SignedHeaders=host&X-Amz-Signature=fefd2185302eabf47ddc3d8d249fb64e944b0bca1381af638f5284aad8853b1a

2) configure snort to use the community-rules ruleset — this is a commonly used set of ~3000 rules to detect malware, etc: https://snort.org/downloads/community/community-rules.tar.gz

3) once that’s working (i.e., you verify that snort loads all the rules and actually processes the packets you send in), learn how to use the “performance monitor (perfmon)” plugin of snort. Perfmon is a module that you enable in the snort configuration that can report all kinds of performance details like throughput, latency, etc. It will give you everything you need.
You can find more details about perfmon in section 2.2.6 of the snort manual: https://snort-org-site.s3.amazonaws.com/production/document_files/files/000/000/178/original/snort_manual.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIXACIED2SPMSC7GA%2F20190808%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190808T142929Z&X-Amz-Expires=172800&X-Amz-SignedHeaders=host&X-Amz-Signature=708a0f47da5bcd49222bbed835cd8005f5546731a0ab742e90001395d62350a2

Additional notes: 
1) Use snort 2.X — there is also a snort 3.X, but 2.X is still more widely used and there are more guides on how to use it.
2) Ignore everything about “barnyard2” and “pulledpork”, these are just plugins to make logging more efficient and auto-download new rulesets — not necessary for us

Test case setup:

1) Run the client with tcpreplay to achieve specific throughput.

2) Run the snort binary on the server machine(dcomp1), with the following configuration:
sudo snort -l ~/logs/snort_test_8.70/snort_log/ --perfmon-file ~/logs/snort_test_8.70/snort_log/snort.stats -q -u snort -g snort -c /etc/snort/snort.conf -i eno1

Where -l refers to log file directory
--perfmon-file : File to which perfmon values will be written. 
-c is the config file to use.
-i is the interface over which snort monitors data.

3) When using the run_snort.sh script for automating test use case, make certain to enter the rate values as integer, not float. i.e, instead of '5.00' , input '5'. This is a current limitation for the script if it needs to work.  
