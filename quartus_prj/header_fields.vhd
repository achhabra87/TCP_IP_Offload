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
		
	
	subtype logic_v48 is std_logic_vector(47 downto 0);
	subtype logic_v16 is std_logic_vector(15 downto 0);
	subtype logic_v8 is std_logic_vector(7 downto 0);
	subtype logic_v4 is std_logic_vector(3 downto 0);
	subtype logic_v32 is std_logic_vector(31 downto 0);
	--Ethernet Header Fields
	signal dest_mac_addr :rom_type48;
	signal src_mac_addr : rom_type48;
	signal vlan : rom_type16;  
	signal eth_type:rom_type16;


	
	type tcp_states is (start,drop_packet,preamble,eth_mac,eth_src_mac,eth_vlan,ip_hdr_s1,ip_hdr_s2,ip_hdr_opt,tcp_hdr_s1,tcp_hdr_s2,tcp_hdr_opt,payload,done);
	-- Ethernet Header Fields
	type ethernet_record is
	record
		eth_src:logic_v48;
		eth_dst:logic_v48;
		eth_type:logic_v16;
	end record;
	
	-- IP Header Fields
	
type ip_record is
  record
	ip_v: logic_v4;				--	Version
	ip_hlen:logic_v4;			--	Header length
	ip_tos:logic_v8;			-- Service Type
	ip_len:logic_v16;			-- Total Length
	ip_id: logic_v16;			-- Identifcation
	ip_flag_frag_off:logic_v16;	-- flags-- frgrament offs
	ip_ttl:logic_v8;			-- Time To Live
	ip_checksum:logic_v16;		-- Header Checksum
	ip_protocol:logic_v8;		-- Protocol
	ip_src_addr:logic_v32;		-- Source_IP_Address
	ip_dst_addr:logic_v32;		-- Dst_IP_Address
	ip_options: logic_v32;		-- IP options if any
  end record;
  
  -- TCP Header Fields
 type tcp_record is
  record
	tcp_src_port:logic_v16;
	tcp_dst_port:logic_v16;
	tcp_seq:logic_v32;
	tcp_ack:logic_v32;
	tcp_dat_off_res:logic_v8;
	tcp_flags:logic_v8;
	tcp_window:logic_v16;
	tcp_checksum:logic_v16;
	tcp_urg:logic_v16;
	tcp_options:logic_v32;
 end record;
 
 
  type session_record is
  record
	eth_src:logic_v48;
	eth_dst:logic_v48;
	ip_src_addr:logic_v32;		-- Source_IP_Address
	ip_dst_addr:logic_v32;		-- Dst_IP_Address
	tcp_src_port:logic_v16;
	tcp_dst_port:logic_v16;
 end record;
  

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
	
