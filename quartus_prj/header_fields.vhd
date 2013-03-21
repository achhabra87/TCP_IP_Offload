library ieee;
use ieee.std_logic_1164.all;

package header_fields is
	constant num_packets:integer:=5;
	constant id_tag_size: integer:=5;
	constant dirty_bit_size: integer:=32;
	
	-- Size of each field in Ethernet Header
	constant mac_addr_size :integer:=48;
	constant vlan_sz : integer:=32;
	constant eth_type_sz:integer:=16;

	
	constant ip_v_size: integer:=4;
	constant ip_hlen_size: integer:=4;
	constant ip_tos_size: integer:=8;
	constant ip_len_size: integer:=16;
	constant ip_id_size: integer:=16;
	constant ip_flags_size: integer:=3;
	constant ip_fragoff_size: integer:=13;
	constant ip_ttl_size: integer:=8;
	constant ip_checksum_size: integer:=16;
	constant ip_protocol_size: integer:=8;
	constant ip_src_addr_size: integer:=32;
	constant ip_dst_addr_size: integer:=32;
	
	-- Size of each field in TCP Header
	constant seq_size: integer:=32;
	
	-- definition of rom type of different data fields, e.g. for 32 bit wide field ROM is rom_type32 and so on.
	type rom_type48 is array (0 to num_packets) of std_logic_vector(48+id_tag_size+dirty_bit_size-1 downto 0);
	type rom_type32 is array (0 to num_packets) of std_logic_vector(32+id_tag_size+dirty_bit_size-1 downto 0);
	type rom_type16 is array (0 to num_packets) of std_logic_vector(16+id_tag_size+dirty_bit_size-1 downto 0);
	type rom_type8 is array (0 to num_packets) of std_logic_vector(8+id_tag_size+dirty_bit_size-1 downto 0);
	type rom_type4 is array (0 to num_packets) of std_logic_vector(4+id_tag_size+dirty_bit_size-1 downto 0);
		
	--Ethernet Header Fields
	signal dest_mac_addr :rom_type48;
	signal src_mac_addr : rom_type48;
	signal vlan : rom_type16;  
	signal eth_type:rom_type16;


	-- IP Header Fields
	signal ip_v: rom_type4;				--	Version
	signal ip_hlen:rom_type4;			--	Header length
	signal ip_tos:rom_type8;			-- Service Type
	signal ip_len:rom_type16;			-- Total Length
	signal ip_id:rom_type16;			-- Identifcation
	signal ip_flag_fragoff:rom_type16;	-- flags-- frgrament offs
	signal ip_ttl:rom_type8;			-- Time To Live
	signal ip_checksum:rom_type16;		-- Header Checksum
	signal ip_protocol:rom_type8;		-- Protocol
	signal ip_src_addr:rom_type32;		-- Source_IP_Address
	signal ip_dst_addr:rom_type32;		-- Dst_IP_Address

	
	-- TCP Header Fields
	

end package header_fields;
	--	Version first 4 bits
	--	Header length 4 bits 
	-- Service Type 1 bytes    
	-- Total Length 2 bytes
	-- Identifcation 2 bytes
	-- flags 3 bits
	-- frgrament offset 13 bits
	-- Time To Live  1 byte
	-- Protocol     1 bytes
	-- Header Checksum 2 bytes           
	-- Source_IP_Address 4 bytes
	-- DST_IP_Address 4 bytes
	
