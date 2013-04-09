library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.header_fields.all;

package global_constants is

	-- IP and MAC addresses of the board
	constant host_ip1 : STD_LOGIC_VECTOR (31 downto 0) := x"82664267";
	constant host_mac1: STD_LOGIC_VECTOR (47 downto 0) := x"00aa0062c609";
	constant dest_mac1: STD_LOGIC_VECTOR (47 downto 0) := x"525400123502";
	constant ip_dest1:STD_LOGIC_VECTOR (31 downto 0) := x"4A7DE443"; -- Google.com
	constant ip_dest2:STD_LOGIC_VECTOR (31 downto 0) := x"cebe242d"; -- yahoo.com
	constant sport_1:STD_LOGIC_VECTOR (15 downto 0) :=conv_std_logic_vector(37587,16);
	constant sport_2:STD_LOGIC_VECTOR (15 downto 0) :=conv_std_logic_vector(37580,16);
	constant dport_1:STD_LOGIC_VECTOR (15 downto 0) :=conv_std_logic_vector(80,16);
	constant dport_2:STD_LOGIC_VECTOR (15 downto 0) :=conv_std_logic_vector(80,16);
	
	-- IP header Length and TCP Header length 
	constant ip_hdr_len: std_logic_vector(15 downto 0):=x"0000";
	constant tcp_hdr_len: std_logic_vector(15 downto 0):=x"0000";
	
	
	
	-- Ethernet Type Length Field
	constant eth_type_pause: std_logic_vector(15 downto 0):=x"8808";
	constant eth_type_ip4: std_logic_vector(15 downto 0):=x"0800";
	constant eth_type_ip6: std_logic_vector(15 downto 0):=x"86dd";
	constant eth_type_arp: std_logic_vector(15 downto 0):=x"0806";
	constant eth_type_ipx: std_logic_vector(15 downto 0):=x"8137";
	constant eth_type_vlan: std_logic_vector(15 downto 0):=x"8100";
	constant vlan_ptag: integer:=3;
	constant vlan_cfitag: integer:=1;
	constant vlan_idtag: integer:=12;
	constant vlan_typetag: integer:=16;
	constant vlanip_start: integer:=vlan_ptag+vlan_cfitag+vlan_idtag;
	constant vlanip_end: integer:=vlan_ptag+vlan_cfitag+vlan_idtag+vlan_typetag;
	
	-- 	0 - 1500 length field (IEEE 802.3 and/or 802.2)
	--	0x0800 IP(v4), Internet Protocol version 4
	-- 	0x0806 ARP, Address Resolution Protocol
	-- 	0x8137 IPX, Internet Packet eXchange (Novell)
	-- 	0x86dd IPv6, Internet Protocol version 6
	-- 	0x8100 VLAN, Virtual Bridged LAN (VLAN, IEEE 802.1Q)
	
	
	constant ip_v: std_logic_vector(3 downto 0):=conv_std_logic_vector(4,4);				--	Version
	constant ip_hlen:logic_v4:=conv_std_logic_vector(5,4);			--	Header length
	constant ip_tos:logic_v8:=x"00";			-- Service Type
	constant ip_flag_frag_off:logic_v16:="0100000000000000";	-- flags-- frgrament offs
	constant ip_ttl:logic_v8:=conv_std_logic_vector(250,8);			-- Time To Live
	constant ip_chk_initial:logic_v16:=x"0000";		-- Header Checksum
	constant ip_protocol:logic_v8:=conv_std_logic_vector(6,8);		-- Protocol, set it TCP for packet generation
	
	constant ip_options: logic_v32:=x"00000000";
	constant tcp_window: logic_v16:=conv_std_logic_vector(65355,16);
	
end package global_constants;


-- IP datagram header format
--
--	0          4          8                      16      19             24                    31
--	--------------------------------------------------------------------------------------------
--	| Version  | *Header  |    Service Type      |        Total Length including header        |
--	|   (4)    |  Length  |     (ignored)        |                 (in bytes)                  |
--	--------------------------------------------------------------------------------------------
--	|           Identification                   | Flags |       Fragment Offset               |
--	|                                            |       |      (in 32 bit words)              |
--	--------------------------------------------------------------------------------------------
--	|    Time To Live     |       Protocol       |             Header Checksum                 |
--	|     (ignored)       |                      |                                             |
--	--------------------------------------------------------------------------------------------
--	|                                   Source IP Address                                      |
--	|                                                                                          |
--	--------------------------------------------------------------------------------------------
--	|                                 Destination IP Address                                   |
--	|                                                                                          |
--	--------------------------------------------------------------------------------------------
--	|                          Options (if any - ignored)               |       Padding        |
--	|                                                                   |      (if needed)     |
--	--------------------------------------------------------------------------------------------
--	|                                          Data (TCP/UDP//)                                |
--	|                                                                                          |
--	--------------------------------------------------------------------------------------------
--	|                                          ....                                            |
--	|                                                                                          |
--	--------------------------------------------------------------------------------------------
--
-- * - in 32 bit words 



-- source_port 2 bytes
-- dst_port 2 bytes
-- sequencec number  4 bytes
-- acknowledgment number  4 bytes
-- Data offset 4 bits
-- Reserved 4 bites
-- flags 1 byte
-- Window Size 2 bytes
-- checksum 2
-- urgent pointer 2 bytes
-- tcp options if any 4 bytes




-- TCP datagram header format

--TCPHDR1
--	0          4          8                      16      19             24                    31
--	--------------------------------------------------------------------------------------------
--	| 				source port     						|        					dst port       |
--	--------------------------------------------------------------------------------------------
--	|           								Sequencen Number       						   |       
--	--------------------------------------------------------------------------------------------
--	|    								Acknowledgment Number          						   |
--	--------------------------------------------------------------------------------------------
--	| Data      |          |     Flag             |        Window Size				           |
--	| offset    | Reserved  |     		          |                                            |
--	--------------------------------------------------------------------------------------------
--	|    		checksum				          |             Urgent Pointer                 |
--	|    						                  |                                             
--	--------------------------------------------------------------------------------------------
--	|                          Options (if any - ignored)               |       Padding        |
--	|                                                                   |      (if needed)     |
--	--------------------------------------------------------------------------------------------
--	|                                          Data                                            |
--	|                                                                                          |
--	--------------------------------------------------------------------------------------------
--	|                                          ....                                            |
--	|                                                                                          |
--	--------------------------------------------------------------------------------------------
--
-- * - in 32 bit words 
