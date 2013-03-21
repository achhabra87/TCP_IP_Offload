library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.global_constants.all;


entity tcp_state is
	generic(
		input_width: integer:=64;

	);
	port(
		-- inputs
		data_i				: in std_logic_vector(input_width-1 downto 0);
		clk					: in std_logic; -- clock input
		en_tcp_state		: in std_logic;
		index 				: in integer;
		reg_o 				: in std_logic_vector(input_width-1 downto 0); -- send an intermediate value to TCP and/or IP checksum module. 


		rst_o				:	out std_logic; -- sends RST1 1 to all the other modules when indentifies an error in any of the fields i




		-- not required for design but useful to debug
		s_tcp				:	buffer std_logic_vector(5 downto 0)	
	);
end tcp_state;

architecture rtl_comb of tcp_state is

type states is (closed,listen,syn_recv,syn_sent, established, fin_wait_1,fin_wait_1,time_wait,close_wait,last_ack);
signal tcp: states;
signal tmpvector: std_logic_vector (input_width-1 downto 0);

signal tcp_length:std_logic_vector(3 downto 0):=(others=>'0');

signal payload_byte_counter: integer:=0;


begin -- begining of architecture


process(clk, EN)
begin
if (EN = '0') then
	y <= start;
	rst_o<='0';

	
elsif (clk'EVENT and clk = '1') then
case y is 
	when closed=>
		if (EN = '1') then 
				if(start_packet='1') then
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
		eth_byte_counter<=4;
		-- src_mac, dst_mac
		if data_i(15 downto 0)=eth_type_ip4  then  	-- IP4
		start_ind:=0;
		y<=ip_hdr;
		elsif data_i(15 downto 0)=eth_type_arp  then -- ARP
			rst_o<=0;
			y<=start;
		elsif data_i(15 downto 0)=eth_type_ipx  then -- Internet Packet eXchange
			rst_o<=0;
			y<=start;
		elsif data_i(15 downto 0)=eth_type_ip6 then -- IPv6
			rst_o<=0;
			y<=start;
		end if;
		
		
	-- eth_type_len
	when eth_type_len=>
			index_msb:=0;
			if clk_cnt = clk_offset + 2 then
			end if;
			
		
	-- ip_hdr starts readin the header for IP4
	when ip_hdr_1=>
		ip_byte_counter<=ip_byte_counter+4;
		
		if index_msb= 0 then --
--	Version first 4 bits
--	Header length 4 bits 
-- Service Type 1 bytes    
-- Total Length 2 bytes
-- Identifcation 2 bytes
-- flags 3 bits
-- frgrament offset 13 bits
    end if;
    
	when ip_hdr2=>
		if index_msb=0 then
-- Time To Live  1 byte
-- Protocol     1 bytes
-- Header Checksum 2 bytes           
-- Source_IP_Address 4 bytes                                              

		end if;



	when ip_hdr3=>
		if index_msb=0 then
		-- Destination_IP_Address	4 bytes
		-- if any IP_options 4 bytes
		-- if header length is 20 then start processing tcp
		end if;
		
		
	when ip_opt=>
		if clk_cnt = clk_offset + STDdelay+ 1 then
								
		end if;
		
							
	-- source_port 2 bytes
	-- dst_port 2 bytes
	-- sequencec number  4 bytes
	when tcp_hdr_1=>
		if clk_cnt = clk_offset + STDdelay+2 then

		end if;
	
	
	
	
	
	-- acknowledgment number  4 bytes
	-- Data offset 4 bits
	-- Reserved 4 bites
	-- flags 1 byte
	-- Window Size 2 bytes						
	when tcp_hdr_2=>
	if clk_cnt = clk_offset + STDdelay+4 then
								
							end if;
							
							
							
	-- checksum 2
-- urgent pointer 2 bytes
-- tcp options if any 4 bytes						
	when tcp_hdr_3=>
		if(clk_cnt=clk_offset + STDdelay + 5) then

			end if;
			
			
			
	when payload=>
		if(clk_cnt=clk_offset + STDdelay + 5) then

		end if;
	end case;
	end if;
end process;



process(y)	   --------------------------- STATE VARIABLE	
begin
	if y =start then
		s_tcp <= "0000";
	elsif y =preamble then
		s_tcp <= "0001";
	elsif y =eth_mac then
		s <= "0010";
	elsif y =eth_type_len1 then
		s_tcp <= "0011";
	elsif y =eth_type_len2 then
		s_tcp <= "0100";
	elsif y =ip_hdr_1 then
		s_tcp <= "0101";
	elsif y =ip_hdr_2 then
		s_tcp <= "0110";
	elsif y =ip_hdr_3 then
		s_tcp <= "0111";
	elsif y =ip_opt then
		s_tcp <= "1000";
	elsif y =tcp_hdr_1 then
		s_tcp <= "1001";
	elsif y =tcp_hdr_2 then
		s_tcp <= "1010";
	elsif y =tcp_hdr_3 then
		s_tcp <= "1011";
	elsif y =payload then
	 s_tcp <= "1100";
	end if;
end process;
end rtl_comb;




