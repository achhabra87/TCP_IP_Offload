library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.global_constants.all;


entity packetizer is
	generic(
		input_width: integer:=64;
		
	);
	port(
		-- inputs
		data_i				:	in	std_logic_vector(input_width-1 downto 0);
		clk					: in std_logic; -- clock input
		start_packet		: in std_logic; -- indicates when packet start arriving
		end_packet			: in std_logic; -- indicates when packet stops receving
		
		
		-- outputs
		en_ip_ck			: out std_logic; -- if packet contains IP header - Activates IP checksum module;
		en_tcp_ck			: out std_logic;-- if packet contains TCP header - Activates TCP checksum module
		en_tcp_state		: out std_logic;
		rst_o					:	out std_logic; -- sends RST1 1 to all the other modules when indentifies an error in any of the fields i
		reg_o 				: out	std_logic_vector(input_width-1 downto 0); -- send an intermediate value to TCP and/or IP checksum module. 
		index 				: out integer;
		
		
		-- not required for design but useful to debug
		s							:	buffer std_logic_vector(5 downto 0)	
	 );
end packetizer;

architecture rtl_packetizer of packetizer is

type states is (start,drop_packet,preamble,eth_mac,eth_vlan,ip_hdr_s1,ip_hdr_s2,ip_hdr_opt,ip_hdr_opt,tcp_hdr_s1,tcp_hdr_s2,tcp_hdr_opt,payload,done);
signal y: states;
signal tmpvector: std_logic_vector (input_width-1 downto 0);

-- to count size of each type of header 
signal eth_byte_counter: integer:=0;
signal ip_byte_counter: integer:=0;
signal tcp_byte_counter: integer:=0;
signal eth_byte_count_nxt: integer:=0;
signal ip_byte_counter_nxt: integer:=0;
signal tcp_byte_counter_nxt: integer:=0;
signal tcp_length:std_logic_vector(3 downto 0):=(others=>'0');
signal ip_length:std_logic_vector(3 downto 0):=(others=>'0');

signal payload_byte_counter: integer:=0;
signal ip_opt: std_logic:='0';


begin -- begining of architecture
variable index_msb: integer:=0;
variable tag_loc: integer:=0;

process(clk, EN)
begin
if (EN = '0') then
	y <= start;
	rst_o<='0';
	en_ip_chk<='0';
	en_tcp_chk <='0';
	en_tcp_state<='0';
	
elsif (clk'EVENT and clk = '1') then
case y is 
	when start=>
			if (EN = '1') then 
				if(start_packet='1') then
					dest_mac_addr(1)<=(others=>'0');
					src_mac_addr(1)<=(others=>'0');
					eth_byte_counter<=0;
					ip_byte_counter<=0;
					tcp_byte_counter<=0;
					payload_byte_counter<=0;
					y <= preamble;
				else
					y<=start;
				end if;
			else
				y<=start;
			end if;

	--	preamble state captures the preamble passthrough mode is enabled 
	--	size of preamble field is 8 byte 
	when preamble=>

		y<=eth_mac;
		
		
		
	-- eth_mac extacts the destination and source mac address, ethernet type_len
	-- first 6 bytes of the input are destination mac, next 6 bytes are source mac address
	-- next 2 bytes contains type of packet
	when eth_mac=>
			dest_mac_addr(1)<=data_i(input_width-1 downto input_width-mac_addr_size-1);
			src_mac_addr(1)<=data_i(input_width-mac_addr_size-2 downto input_width-mac_addr_Size-mac_addr_size-2);
			eth_byte_counter<=4;
			-- src_mac, dst_mac
			if data_i(15 downto 0)=eth_type_ip4  then  	-- IP4
				start_ind:=0;
				y<=ip_hdr_s1;
			elsif data_i(15 downto 0)=eth_type_arp  then -- ARP
				rst_o<=0;
				y<=start;
			elsif data_i(15 downto 0)=eth_type_ipx  then -- Internet Packet eXchange
				rst_o<=0;
				y<=start;
			elsif data_i(15 downto 0)=eth_type_ip6 then -- IPv6
				rst_o<=0;
				y<=start;
			elsif data_i(15 downto 0)=eth_type_vlan then -- IPv6
				rst_o<=0;
				y<=eth_vlan;
			else
				y<=drop_packet;
				rst_o<=1;
			end if;
		
		
	-- eth_type_vlan
	when eth_vlan=>
			index_msb:=0;
			if data_i(input_width-1-vlanip_start downto input_width-1-vlanip_end) = eth_type_ip4 then
				y<=ip_hdr_s1;
			else
				y<=drop_packet;
				rst_o<=1;
			end if;
			
		
		
	-- ip_hdr state starts reading the header for IP4
	-- check if IP verison is 4 if IP/=4 drop_packet
	-- 		if IPV=4 check what Header Length
	-- if header length=5 set ip_opt=1 else ip_opt
	when ip_hdr1=>				
		--	Version first 4 bits
		--	Header length 4 bits 
		-- Service Type 1 bytes    
		-- Total Length 2 bytes
		-- Identifcation 2 bytes
		-- flags 3 bits
		-- frgrament offset 13 bits
			ip_byte_counter<=ip_byte_counter+4;
			y<=ip_hdr_s2;
    
	when ip_hdr2=>
		-- Time To Live  1 byte
		-- Protocol     1 bytes
		-- Header Checksum 2 bytes           
		-- Source_IP_Address 4 bytes 
		y<=ip_hdr_opt;



	when ip_hdr_opt=>
		-- Destination_IP_Address	4 bytes
		-- if any IP_options 4 bytes
		-- if header length is 20 then start processing tcp
		y<=tcp_hdr_s1;
		

		
							

	when tcp_hdr_s1=>	
		-- source_port 2 bytes
		-- dst_port 2 bytes
		-- sequencec number  4 bytes
		y<=tcp_hdr_s2;
	
	
	
	
	
						
	when tcp_hdr_s2=>
		-- acknowledgment number  4 bytes
		-- Data offset 4 bits
		-- Reserved 4 bites
		-- flags 1 byte
		-- Window Size 2 bytes
		y<=tcp_hdr_opt;
							
							
							
						
	when tcp_hdr_opt=>
		-- checksum 2
		-- urgent pointer 2 bytes
		-- tcp options if any 4 bytes	
		y<=payload;
	when payload=>
		y<=done;
	when done=>
		if(end_packet='1')
			y<=start;
		else
			y<=start;
		end if;
		
	
	when drop_packet=>
		y<=start;

	end case;
	end if;
end process;




process(y)	   --------------------------- STATE VARIABLE	
begin
	if y =start then
		s <= "0000";
	elsif y =preamble then
		s <= "0001";
	elsif y =eth_mac then
		s <= "0010";
	elsif y =eth_vlan then
		s <= "0011";
	elsif y =ip_hdr_s1 then
		s <= "0100";
	elsif y =,ip_hdr_s2 then
		s <= "0101";
	elsif y =ip_hdr_opt then
		s <= "0110";
	elsif y =tcp_hdr_s1 then
		s <= "0111";
	elsif y =tcp_hdr_s2 then
		s <= "1000";
	elsif y =tcp_hdr_opt then
		s <= "1001";
	elsif y =payload then
		s <= "1010";
	elsif y =drop_packet then
		s <= "1011";
	end if;
end process;
end rtl_packetizer;




