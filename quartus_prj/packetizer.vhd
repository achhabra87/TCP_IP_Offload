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
		 writeReq:  out std_logic; 
		header_data : out eth_ip_tcp;
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

type states is (start,drop_packet,preamble,eth_mac,eth_src_mac,eth_vlan,ip_hdr_s1,ip_hdr_s2,ip_hdr_opt,tcp_hdr_s1,tcp_hdr_s2,tcp_hdr_opt,tcp_opt,payload,done);
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
signal writeenable  : std_logic:='0';             -- write enable
signal eth_dst_di  : std_logic_vector (bit_width48-1 downto 0);  -- data in

-- signal to ether_dst_header memory
signal eth_src_di  : std_logic_vector (bit_width48-1 downto 0);  -- data in
signal eth_type:logic_v16;
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
signal data_offset:logic_v4;
signal payload_len: logic_v16;
signal htons_ip_len:logic_v16;
--payload_len=htons_ip_len- (x"00","00",ip_hlen,"00")-(x"00","00",tcp_dat_off_res(7 downto 4),"00")


signal tcp_src_port:logic_v16;
signal tcp_dst_port:logic_v16;
signal tcp_seq:logic_v32;
signal tcp_ack:logic_v32;
signal tcp_dat_off_res:logic_v8;
signal tcp_flags:logic_v8;
signal tcp_window:logic_v16;
signal tcp_checksum:logic_v16;
signal tcp_urg:logic_v16;
type tcp_opt_array is array (0 to 10) of logic_v32;
signal tcp_options: tcp_opt_array;
signal tcp_opt_offset: integer :=0;

signal payload_dat:std_logic_vector(63 downto 0);
signal offset:integer:=0;
signal previous_dat0: std_logic_vector(63 downto 0);
signal previous_dat1: std_logic_vector(63 downto 0);
signal previous_dat2: std_logic_vector(63 downto 0);
signal data_aligned : std_logic_vector(63 downto 0);
begin -- begining of architecture


process(offset,data_i,previous_dat0,previous_dat1,previous_dat2)
begin
  if(offset=0) then
    data_aligned<=data_i;
elsif (offset=2) then
  data_aligned(63 downto 48) <= previous_dat0(15 downto 0);
   data_aligned(47 downto 0) <= data_i(63 downto 16);
 elsif (offset=4) then
    data_aligned(63 downto 32) <= previous_dat0(31 downto 0);
    data_aligned(31 downto 0) <= data_i(63 downto 32);
elsif(offset=6) then
    data_aligned(63 downto 16)<=previous_dat0(47 downto 0);
    data_aligned(15 downto 0)<=data_i(63 downto 48);
elsif (offset=10) then
      data_aligned(63 downto 48) <= previous_dat1(15 downto 0);
   data_aligned(47 downto 0) <= previous_dat0(63 downto 16);
elsif (offset=14) then
      data_aligned(63 downto 16) <= previous_dat1(47 downto 0);
   data_aligned(15 downto 0) <= previous_dat0(63 downto 48);
end if;
end process;



process(clk, EN)
begin
header_data.ethernet_data<=(eth_dst_di,eth_src_di,eth_type);
header_data.ip_data<=(ip_v,ip_hlen,ip_tos,ip_len,ip_id,ip_flag_frag_off,ip_ttl,ip_checksum,ip_protocol,ip_src_addr,ip_dst_addr,ip_options);
header_data.tcp_data<=(tcp_src_port,tcp_dst_port,tcp_seq,tcp_ack,tcp_dat_off_res,tcp_flags,tcp_window,tcp_checksum,tcp_urg,tcp_options(0));

if (EN = '0') then
	y <= start;
	rst_o<='0';
	writeReq<='0';
	--en_ip_chk<='0';
	--en_tcp_chk <='0';
	--en_tcp_state<='0';
	
elsif (clk'EVENT and clk = '1') then
  previous_dat0<=data_i;
  previous_dat1<=previous_dat0;
  previous_dat2<=previous_dat1;
case y is 
	when start=>
			if (EN = '1') then 
				if(start_packet='1') then
					
					eth_byte_counter<=0;
					ip_byte_counter<=0;
					tcp_byte_counter<=0;
					payload_byte_counter<=0;
					y <= preamble;
					offset<=0;
					data_offset<="0000";
					tcp_opt_offset<=0;
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
		writeReq<='0';
		y<=eth_mac;
		
		
		
		
	-- eth_mac extacts the destination and source mac address, ethernet type_len
	-- first 6 bytes of the input are destination mac, next 6 bytes are source mac address
	-- next 2 bytes contains first (2 bytes of src header
	-- s2
	when eth_mac=>

			eth_dst_di<=data_i(input_width-1 downto input_width-47-1);
			eth_src_di(47 downto 47-15)<=data_i(input_width-1-48 downto 0);
			--dest_mac_addr(1)<=data_i(input_width-1 downto input_width-mac_addr_size-1);
			--src_mac_addr(1)<=data_i(input_width-mac_addr_size-2 downto input_width-mac_addr_Size-mac_addr_size-2);
			eth_byte_counter<=8;
			y<=eth_src_mac;
	

	--eth_src_mac 
    -- ethernet src mac and ethernet type
	when eth_src_mac=>
		eth_src_di(47-16 downto 0)<=data_i(input_width-1 downto input_width-1-31);
		eth_type<=data_i(31 downto 16);
		-- src_mac
			if data_i(32 downto 16)=eth_type_ip4  then  	-- IP4
	     offset<=2;
				--ip_v<=data_i(15 downto 12);
				--ip_hlen<=data_i(11 downto 8);
				--ip_tos<=data_i(7 downto 0);
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
	    		ip_v<=data_aligned(63 downto 60 );
				ip_hlen<=data_aligned(59 downto 56);
				ip_tos<=data_aligned(55 downto 48); 
			 ip_len<=data_aligned(47 downto 32);
			 ip_id<=data_aligned(31 downto 16);
			 ip_flag_frag_off<=data_aligned(15 downto 0);
			 
			 ip_ttl<=data_aligned(63-32-16 downto 63-32-16-7);
			ip_protocol<=data_i(7 downto 0);
			ip_byte_counter<=ip_byte_counter+4;
			y<=ip_hdr_s2;
			--if(index_vlan=1)
		
	--s5	
	when ip_hdr_s2=>
	  ip_ttl<=data_aligned(63 downto 56);
		ip_protocol<=data_aligned(55 downto 48);
		ip_checksum<=data_aligned(47 downto 32);
		ip_src_addr<=data_aligned(31 downto 0);
		y<=ip_hdr_opt;


	--s6
	when ip_hdr_opt=>
	  ip_dst_addr<=data_aligned(63 downto 32);
		if(ip_hlen=5) then
      offset<=offset+4; -- carry 4 bytes to next cyles
			y<=tcp_hdr_s1;
		elsif(ip_hlen>5) then
			ip_options<=data_aligned(31 downto 0);
			y<=tcp_hdr_s1;
		else 
			y<=drop_packet; -- droping packet if Header Length Field is incorrect
		end if;

							
	--s7
	when tcp_hdr_s1=>	
		  tcp_src_port<=data_aligned(63 downto 48);	
			tcp_dst_port<=data_aligned(47 downto 32);	
		  tcp_seq<=data_aligned(31 downto 0);
			y<=tcp_hdr_s2;

	
	--s8
	when tcp_hdr_s2=>
			tcp_ack<=data_aligned(63 downto 32);
			tcp_dat_off_res<=data_aligned(31 downto 24);
			tcp_flags<=data_aligned(23 downto 16);
		  tcp_window<=data_aligned(15 downto 0);
	     y<=tcp_hdr_opt;
	     payload_len<=htons_ip_len - (x"00" & "00" & ip_hlen & "00")-(x"00" & "00" & data_aligned(31 downto 28) & "00");
	     --payload_len<=htons_ip_len - (x"00" & "00" & ip_hlen & "00")-(x"00" & "00" & tcp_dat_off_res(7 downto 4) & "00");
		  data_offset<=data_aligned(31 downto 28);
	when tcp_hdr_opt=>
	
	   tcp_checksum<=data_aligned(63 downto 48);
		 tcp_urg<=data_aligned(47 downto 32);
		 if(data_offset>5 and data_offset<=6) then -- checking if there are any tcp options if data offset is 5 then there are no options. It it is 6 or above, then options exist
		   tcp_options(tcp_opt_offset)<=data_aligned(31 downto 0);
		   tcp_opt_offset<=tcp_opt_offset+1;
		   	     if(payload_len>=1) then
	             y<=payload;
	             offset<=offset+4;
	           else
	              y<=done;
	           end if;
		   --data_offset<=data_offset+4;
		   ---y<=tcp_opt;
		  elsif(data_offset>6 ) then
		  	   tcp_options(tcp_opt_offset)<=data_aligned(31 downto 0);
		  	   data_offset<=data_offset-6;
		    y<=tcp_opt;
		   else
		   	     if(payload_len>=1) then
	             y<=payload;
	             offset<=offset+4;
	           else
	              y<=done;
	           end if;
      end if;
		   
		 
		-- checksum 2
		-- urgent pointer 2 bytes
		-- tcp options if any 4 bytes	
		y<=preamble;
		writeReq<='1';
		
	when tcp_opt=>
	  
	      if(data_offset>2) then
	       tcp_options(tcp_opt_offset)<=data_aligned(63 downto 32);
	       tcp_options(tcp_opt_offset+1)<=data_aligned(31 downto 0);
	       tcp_opt_offset<=tcp_opt_offset+2;
	       data_offset<=data_offset-2;
	       y<=tcp_opt;
	      elsif (data_offset=2) then
	      	  tcp_options(tcp_opt_offset)<=data_aligned(63 downto 32);
	         tcp_options(tcp_opt_offset+1)<=data_aligned(31 downto 0);
	         tcp_opt_offset<=tcp_opt_offset+2;
	         data_offset<=data_offset-2;
	         	  if(payload_len>=1) then
	             y<=payload;
	           else
	              y<=done;
	           end if;
	       else
	           tcp_options(tcp_opt_offset)<=data_aligned(63 downto 32);
	           if(payload_len>=1) then
	             y<=payload;
	             offset<=offset+4;
	           else
	              y<=done;
	           end if;
	        end if;
	          
	       
	when payload=>
	      if(payload_len>4) then
	             y<=payload;
	             payload_len<=payload_len-4;
	               payload_dat<=data_aligned;
	      else
	               payload_dat<=data_aligned;
	              y<=done;   
	      end if;
	 
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




