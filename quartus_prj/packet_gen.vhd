library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.global_constants.all;
use work.header_fields.all;

entity packet_gen is
port
(
clk : in std_logic;
rst : in std_logic; -- asynchronous reset
current_state : in tcp_state;
tcb_in	:in tcb_buffer; -- from tcp state machine
tcb_out	:out tcb_buffer;	-- update tcb buffer
packet : out std_logic_vector(63 downto 0);
session_info: in session_record;
start_packet : in std_logic;
end_packet : in std_logic;
send_flag: in logic_v8
);
end packet_gen;
	
architecture rtl_packetizer of packet_gen is
constant packet_size: integer:=1500; -- Maximum size of packet
type ram_type is array (0 to packet_size-1) of std_logic_vector(7 downto 0);
signal tx_data: ram_type;
signal offset: integer:=0; -- 
type packet_generation is (start_connection, send_ack,send_request,checksum_calc,checksum_append);
signal pkt_gen:tcp_states;
type tx_states is (start,eth_dst,eth_src,eth_vlan,ip_hdr1,ip_hdr2,ip_hdr3,tcp_hdr1,tcp_hdr2,tcp_hdr4,tcp_hdr5,payload,done);

signal csum:std_logic_vector(19 downto 0);
signal chksum: std_logic_vector(15 downto 0);
type sumarray is array(0 to 5) of std_logic_vector(19 downto 0);
signal sum: sumarray;
signal transmit : tx_states;
signal ip_id,ip_flag_off,src_port,dst_port,winsize,urg_p,ip_len :logic_v16;
signal ack,seq: logic_v32
signal tcp_opt_start is array (0 downto ) of std_logic_vector(7 downto 0):=(
x"02",-- Option kind 2 = maximum segment size
x"04",--This option kind is 4 bytes long
x"01", Set maximum segment size to 0x100 = 256
x"00",

  
  --Second TCP option - Timestamp option
x"8", -- Option kind 8 = Timestamp option (TSOPT)
x"A", --This option is 10 bytes long
x"02", -- Set the sender's timestamp (TSval) (4 bytes) (need SYN set to be valid)
x"03",
x"04",
x"05",
x"00",-- Set the echo timestamp (TSecr) (4 bytes) (need ACK set to be valid)
x"00",
x"00", 
x"00",
x"00",--Sack permitted true
x"04", 
x"02"); 



component swapbyte32 is
port(input : in std_logic_vector(31 downto 0);output : out std_logic_vector(31 downto 0););
end component;

component swapbyte16 is 
port(input : in std_logic_vector(15 downto 0);output : out std_logic_vector(15 downto 0););
end component;

begin
u_win: swapbyte16 port map(input=>tcp_window,output => winsize);
u_sport: swapbyte16 port map(input=>session_info.tcp_src_port ,output => src_port);
u_dport: swapbyte16 port map(input=> session_info.tcp_dst_port,output => dst_port);
u_ip_flag: swapbyte16 port map (input =>ip_flag_frag_off,output => ip_flag_off);
u_seq :swapbyte32 port map (input =>tcp_seq_sent,output => seq);
u_ack:swapbyte32 port map (input =>tcp_ack_sent,output => ack);



packet_create: process(clk,tcp_state)
if(rst=0) then


elsif(rising_edge(clk)) then
case pkt_gen
	when start=>
		pkt_gen<=current_state;
		tx_data(0)<=session_info.eth_dst(47 downto 40);
		tx_data(1)<=session_info.eth_dst(39 downto 32);
		tx_data(2)<=session_info.eth_dst(31 downto 24);
		tx_data(3)<=session_info.eth_dst(23 downto 16);
		tx_data(4)<=session_info.eth_dst(15 downto 8);
		tx_data(5)<=session_info.eth_dst(7 downto 0);
		tx_data(6)<=session_info.eth_src(47 downto 40);
		tx_data(7)<=session_info.eth_src(39 downto 32);
		tx_data(8)<=session_info.eth_src(31 downto 24);
		tx_data(9)<=session_info.eth_src(23 downto 16);
		tx_data(10)<=session_info.eth_src(15 downto 8);
		tx_data(11)<=session_info.eth_src(7 downto 0);
		tx_data(12)<=eth_type_ip4(15 downto 8);
		tx_data(13)<=eth_type_ip4(7 downto 0);
		tx_data(14)<=x"00";-- No VLAN
		tx_data(15)<=x"00";-- No VLAN
		tx_data(16)<=x"00";-- No VLAN
		tx_data(17)<=x"00";-- No VLAN
		tx_data(18)<=ip_v&ip_hlen;
		tx_data(19)<=ip_tos;
		--tx_data(20)<= -- len(15:8);
		--tx_data(21)< len(7:0)
		tx_data(22)<=x"00";
		tx_data(24)<=x"00";
		tx_data(25)<=ip_flag_frag_off;
		tx_data(26)<= ip_ttl;
		tx_data(27)<=ip_protocol;
		tx_data(28)<=x"00"; -- Initial Checksum
		tx_data(29)<=x"00"; -- Initial Checksum
		tx_data(30)<=session_info.ip_src_addr(31 downto 24);
		tx_data(31)<=session_info.ip_src_addr(23 downto 16);
		tx_data(32)<=session_info.ip_src_addr(15 downto 8);
		tx_data(33)<=session_info.ip_src_addr(7 downto 0);
		tx_data(34)<=session_info.ip_dst_addr(31 downto 24);
		tx_data(35)<=session_info.ip_dst_addr(23 downto 16);
		tx_data(36)<=session_info.ip_dst_addr(15 downto 8);
		tx_data(37)<=session_info.ip_dst_addr(7 downto 0);
		tx_data(38)<=x"00"; -- N0 ip Options
		tx_data(39)<=x"00";
		tx_data(40)<=x"00";
		tx_data(41)<=x"00";
		tx_data(42)<=src_port(15 downto 8);
		tx_data(43)<=src_port(7 downto 0);
		tx_data(44)<=dst_port(15 downto 8);
		tx_data(45)<=dst_port(7 downto 0);
		--tx_data(46)<=seq(31 downto 24);
		--tx_data(47)<=seq(23 downto 16);
		--tx_data(48)<=seq(15 downto 8);
		--tx_data(49)<=seq(7 downto 0);
		--tx_data(50)<=ack(31 downto 24);
		--tx_data(51)<=ack(23 downto 16);
		--tx_data(52)<=ack(15 downto 8);
		--tx_data(53)<=ack(7 downto 0);
		tx_data(54)<=x"00";-- data offset and rsvd
		tx_data(55)<=send_flag;
		tx_data(56)<=winsize;
		tx_data(57)<=x"00";-- TCP checksum Initialized it zero
		tx_data(58)<=x"00";-- TCP checksum 
		tx_data(59)<=urp(15 downto 8);
		tx_data(60)<=urp(7 downto 0);
	when start_connection=>	
		
		
	when SEND_ACK=>
		
		
	when SEND_DATA=>
		
	end case;	
end if;

end process;


process_checksum: process(clk)
if(rst=0) then


elsif(rising_edge(clk)) then
case chksum_offload

when ip_header_gen=>
		iphdr(0)<= "0000"&& tx_data(18) && tx_data(19);
	iphdr(1)<= "0000"&&tx_data(20) && tx_data(21);
	iphdr(2)<= "0000"&&tx_data(22) && tx_data(23);
	iphdr(3)<= "0000"&&tx_data(24) && tx_data(25);
	iphdr(4)<= "0000"&&tx_data(26) && tx_data(27);
	iphdr(5)<= "0000"&&tx_data(28) && tx_data(29);
	iphdr(6)<= "0000"&&tx_data(30) && tx_data(31);
	iphdr(7)<= "0000"&&tx_data(32) && tx_data(33);
	iphdr(8)<= "0000"&&tx_data(34) && tx_data(35);
	iphdr(9)<= "0000"&&tx_data(37) && tx_data(37);
	
			tcp_pseudo(0)<=session_info.ip_src_addr(31 downto 16);
		tcp_pseudo(1)<=session_info.ip_src_addr(15 downto 0);
		tcp_pseudo(2)<=session_info.ip_dst_addr(31 downto 16);
		tcp_pseudo(3)<=session_info.ip_dst_addr(15 downto 0);
		tcp_pseudo(4)<=x"0000";
		tcp_pseudo(5)<=tcp_len;
		
		
	when ip_chk_start=>
			sum(0)<=iphdr(0)+iphdr(1);
			sum(1)<=iphdr(2)+iphdr(3);
			sum(2)<=iphdr(4)+iphdr(5);
			sum(3)<=iphdr(6)+iphdr(7);
			sum(4)<=iphdr(8)+iphdr(9);	
	
	when ip_chk_step2=>
	csum<=sum(0)+sum(1)+sum(2)+sum(3)+sum(3);
	
	when ip_chk_step3=>
	chksum<=csum(15 downto 0) + (x"000" && csum(19 downto 16));
	
	when ip_chk_final=>
	-- append checksum to packet
	tx_data(25)=not(chksum);
	
	when tcp_checksum
		if(size>0)
			tcp_chksum=

end if;
end process; -- processchksum




packet_send: process(clk)
if(rst=0) then


elsif(rising_edge(clk)) then
case 


end if;
end process; -- packet_send

end packet_gen;
