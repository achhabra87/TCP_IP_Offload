library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.global_constants.all;
use work.header_fields.all;

entity packetizer is
	generic(
		input_width: integer:=64;
		bit_width48:integer:=48
		
	);
	port(
		-- inputs
		data_i				:	in	std_logic_vector(input_width-1 downto 0);
		clk					: in std_logic; -- clock input
		start_packet		: in std_logic; -- indicates when packet start arriving
		end_packet			: in std_logic; -- indicates when packet stops receving
		EN					: in std_logic; -- EN
		
		-- outputs
		eth_header	:out ethernet_record;
		ip_header	: out ip_record;
		tcp_header : out tcp_record;
		--en_ip_ck			: out std_logic; -- if packet contains IP header - Activates IP checksum module;
		--en_tcp_ck			: out std_logic;-- if packet contains TCP header - Activates TCP checksum module
		--en_tcp_state		: out std_logic;
		rst_o					:	out std_logic; -- sends RST1 1 to all the other modules when indentifies an error in any of the fields i
		--reg_o 				: out	std_logic_vector(input_width-1 downto 0); -- send an intermediate value to TCP and/or IP checksum module. 
		--index 				: out integer;
		
		
		-- not required for design but useful to debug
		s							:	buffer std_logic_vector(5 downto 0)	
	 );
end packetizer;

architecture rtl_packetizer of packetizer is

type states is (start,drop_packet,preamble,eth_mac,eth_src_mac,eth_vlan,ip_hdr_s1,ip_hdr_s2,ip_hdr_opt,tcp_hdr_s1,tcp_hdr_s2,tcp_hdr_opt,payload,done);
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
signal index_vlan: integer:=0;
signal tag_loc: integer:=0;
signal start_ind: integer:=0;

-- signal to ether_dst_header memory
signal mem_addr   : unsigned(3 downto 0);  -- this is the address location
signal eth_dst_we  : std_logic:='0';             -- write enable
signal eth_dst_di  : unsigned(bit_width48-1 downto 0);  -- data in
signal eth_dst_do  : unsigned(bit_width48-1 downto 0); -- data out



-- signal to ether_dst_header memory
signal eth_src_we  : std_logic:='0';             -- write enable
signal eth_src_di  : unsigned(bit_width48-1 downto 0);  -- data in
signal eth_src_do  : unsigned(bit_width48-1 downto 0); -- data out

--subtype logic_v16 is std_logic_vector(15 downto 0);
--subtype logic_v8 is std_logic_vector(7 downto 0);
--subtype logic_v4 is std_logic_vector(3 downto 0);
--subtype logic_v32 is std_logic_vector(31 downto 0);

-- IP Header Fields
signal ip_v: logic_v4;				--	Version
signal ip_hlen:logic_v4;			--	Header length
signal ip_tos:logic_v8;			-- Service Type
signal ip_len:logic_v16;			-- Total Length
signal ip_id: logic_v16;			-- Identifcation
signal ip_flag_frag_off:logic_v16;	-- flags-- frgrament offs
signal ip_ttl:logic_v8;			-- Time To Live
signal ip_checksum:logic_v16;		-- Header Checksum
signal ip_protocol:logic_v8;		-- Protocol
signal ip_src_addr:logic_v32;		-- Source_IP_Address
signal ip_dst_addr:logic_v32;		-- Dst_IP_Address
signal ip_options: logic_v32;		-- IP options if any


signal tcp_src_port:logic_v16;
signal tcp_dst_port:logic_v16;
signal tcp_seq:logic_v32;
signal tcp_ack:logic_v32;
signal tcp_dat_off_res:logic_v8;
signal tcp_flags:logic_v8;
signal tcp_window:logic_v16;
signal tcp_checksum:logic_v16;
signal tcp_urg:logic_v16;
signal tcp_options:logic_v32;

signal payload_dat:logic_v32;

component ram_infr
generic( memorysize: integer:=15;
			bit_width : integer:= 48
);
	port (
		clk : in std_logic;             -- clock
		we  : in std_logic;             -- write enable
		a   : in unsigned(3 downto 0);  -- this is the address location
		di  : in unsigned(bit_width-1 downto 0);  -- data in
		
		do  : out unsigned(bit_width-1 downto 0) -- data out
	);
end component;

begin -- begining of architecture





process(clk, EN)
begin
if (EN = '0') then
	y <= start;
	rst_o<='0';
	--en_ip_chk<='0';
	--en_tcp_chk <='0';
	--en_tcp_state<='0';
	
elsif (clk'EVENT and clk = '1') then
case y is 
	when start=>
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
	-- s1
	when preamble=>

		y<=eth_mac;
		
		
		
		
	-- eth_mac extacts the destination and source mac address, ethernet type_len
	-- first 6 bytes of the input are destination mac, next 6 bytes are source mac address
	-- next 2 bytes contains first (2 bytes of src header
	-- s2
	when eth_mac=>

			eth_dst_di<=unsigned(data_i(input_width-1 downto input_width-47-1));
			eth_src_di(47 downto 47-15)<=unsigned(data_i(input_width-1-48 downto 0));
			--dest_mac_addr(1)<=data_i(input_width-1 downto input_width-mac_addr_size-1);
			--src_mac_addr(1)<=data_i(input_width-mac_addr_size-2 downto input_width-mac_addr_Size-mac_addr_size-2);
			eth_byte_counter<=8;
			y<=eth_src_mac;
	

	--eth_src_mac 
	-- captures last 4 bytes of src header, 2 bytes of   eth_type 
	-- if eth_type is IP4 it contains first two bytes of IP header, which is IP header
	-- if eth_type is vlan , then it contains first two bytes of vlan tag
	-- s3
	when eth_src_mac=>
		eth_src_di(47-16 downto 0)<=unsigned(data_i(input_width-1 downto input_width-1-31));
		-- src_mac
			if data_i(32 downto 16)=eth_type_ip4  then  	-- IP4
				ip_v<=data_i(15 downto 12);
				ip_hlen<=data_i(11 downto 8);
				ip_tos<=data_i(7 downto 0);
				start_ind<=0;
				y<=ip_hdr_s1;
			elsif data_i(32 downto 16)=eth_type_arp  then -- ARP
				rst_o<='0';
				y<=start;
			elsif data_i(32 downto 16)=eth_type_ipx  then -- Internet Packet eXchange
				rst_o<='0';
				y<=start;
			elsif data_i(32 downto 16)=eth_type_ip6 then -- IPv6
				rst_o<='0';
				y<=start;
			elsif data_i(32 downto 16)=eth_type_vlan then -- IPv6
				rst_o<='0';
				y<=eth_vlan;
			else
				y<=drop_packet;
				rst_o<='1';
			end if;
	
	-- eth_type_vlan
	-- data_i contains last two bytes of the vlan tag, two byes of eth_type preceding vlan,
	-- first four bytes of IP header, IP verison(4 bits) and IP headerlength(4 bits),Service Type 1 bytes,Total Length 2 bytes
	when eth_vlan=>
			--index_lan<=1;
			if data_i(input_width-1-16 downto input_width-1-32 ) = eth_type_ip4 then
				y<=ip_hdr_s1;
--				ip_v<=data_i(31 downto 28);
--				ip_hlen<=data_i(27 downto 24);
--				ip_tos<=data_i(23 downto 16);
--				ip_len<=data_i(15 downto 0);
			else
				y<=drop_packet;
				rst_o<='1';
			end if;
			
		
		
	-- ip_hdr state starts reading the header for IP4
	-- check if IP verison is 4 if IP/=4 drop_packet
	-- 		if IPV=4 check what Header Length
	-- if header length=5 set ip_opt=1 else ip_opt
	--s4
	when ip_hdr_s1=>				
			ip_len<=data_i(63 downto 63-15);
			ip_id<=data_i(63-16 downto 63-16-15);
			ip_flag_frag_off<=data_i(63-32 downto 63-32-15);
			ip_ttl<=data_i(63-32-16 downto 63-32-16-7);
			ip_protocol<=data_i(7 downto 0);
			ip_byte_counter<=ip_byte_counter+4;
			y<=ip_hdr_s2;
			--if(index_vlan=1)
		
	--s5	
	when ip_hdr_s2=>
		ip_checksum<=data_i(63 downto 63-15);
		ip_src_addr<=data_i(63-16 downto 63-16-31);
		ip_dst_addr(31 downto 16)<=data_i(15 downto 0);
		y<=ip_hdr_opt;


	--s6
	when ip_hdr_opt=>
		ip_dst_addr(15 downto 0)<=data_i(63 downto 63-15);
		if(ip_hlen=5) then
			tcp_src_port<=data_i(63-16 downto 63-16-15);	
			tcp_dst_port<=data_i(63-32 downto 16);	
			tcp_seq(31 downto 16)<=data_i(15 downto 0);
			y<=tcp_hdr_s1;
		elsif(ip_hlen>5) then
			ip_options<=data_i(63-16 downto 63-16-31);
			tcp_src_port<=data_i(15 downto 0);
			y<=tcp_hdr_s1;
		else 
			y<=drop_packet; -- droping packet if Header Length Field is incorrect
		end if;
		
		y<=tcp_hdr_s1;
		

		
							
	--s7
	when tcp_hdr_s1=>	
		if(ip_hlen=5) then	
			tcp_seq(15 downto 0)<=data_i(63 downto 63-15);
			tcp_ack<=data_i(63-16 downto 63-16-31);
			tcp_dat_off_res<=data_i(63-32 downto 63-32-7);
			tcp_flags<=data_i(7 downto 0);
		elsif(ip_hlen>5) then
			tcp_seq<=data_i(63 downto 63-31);
			tcp_ack<=data_i(31 downto 0);
		end if;
			y<=tcp_hdr_s2;
	
	
	
	
	--s8
	when tcp_hdr_s2=>
	
		if(ip_hlen=5) then	
			tcp_window<=data_i(63 downto 63-15);
			tcp_checksum<=data_i(63-16 downto 63-16-15);
			tcp_urg<=data_i(63-16-16 downto 63-16-16-15);
			--if(tcp_dat_off_res(7 downto 4)=5) then
			--end if;
			
			
		elsif(ip_hlen>5) then
			tcp_dat_off_res<=data_i(63 downto 63-7);
			tcp_flags<=data_i(63-8 downto 63-8-7);
			tcp_window<=data_i(63-16 downto 63-16-15);
			tcp_checksum<=data_i(31 downto 16);
			tcp_urg<=data_i(15 downto 0);
		end if;
		
		y<=tcp_hdr_opt;
							
							
							
						
	when tcp_hdr_opt=>
		-- checksum 2
		-- urgent pointer 2 bytes
		-- tcp options if any 4 bytes	
		y<=preamble;
	when payload=>
		y<=done;
	when done=>
		if(end_packet='1') then
			y<=start;
		else
			y<=done;
		end if;
		
	
	when drop_packet=>
		y<=start;

	end case;
end if;	
end process;



process(y)	   --------------------------- STATE VARIABLE	
begin
	if y =start then
		s <= "000000";
	elsif y =preamble then
		s <= "000001";
	elsif y =eth_mac then
		s <= "000010";
	elsif y =eth_vlan then
		s <= "000011";
	elsif y =ip_hdr_s1 then
		s <= "000100";
	elsif y =ip_hdr_s2 then
		s <= "000101";
	elsif y =ip_hdr_opt then
		s <= "000110";
	elsif y =tcp_hdr_s1 then
		s <= "000111";
	elsif y =tcp_hdr_s2 then
		s <= "001000";
	elsif y =tcp_hdr_opt then
		s <= "001001";
	elsif y =payload then
		s <= "001010";
	elsif y =drop_packet then
		s <= "001011";
	end if;
end process;

end rtl_packetizer;




