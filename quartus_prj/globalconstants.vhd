library ieee;
use ieee.std_logic_1164.all;

package global_constants is

	-- IP and MAC addresses of the board
	constant DEVICE_IP : STD_LOGIC_VECTOR (31 downto 0) := x"82664267";
	constant DEVICE_MAC: STD_LOGIC_VECTOR (47 downto 0) := x"00aa0062c609";
	
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
