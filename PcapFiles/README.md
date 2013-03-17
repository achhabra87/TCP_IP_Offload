PcapFiles
=================

//March 16,2013

There .pcap files were captured from Wireshark for test_bench and simulation purposes.


* pcap_to_dat.c

This software helps to convert .pcap file into .dat where data is converted * from .pcap format to .dat (output is '0' or/and '1').
Outfile can be read in VHDL. It can be used to pass data of pcap file to 
VHDL test benches.
To run this program for input file dataDumped.pcap

gcc -o pcap_to_dat pcap_to_dat.c
./pcap_to_data dataDumped


