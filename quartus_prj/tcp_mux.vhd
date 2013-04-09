library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.header_fields.all;

entity tcp_mux IS
generic( number_connetion: integer:=2);
	PORT
	(
		-- inputs
		clk,rst		: in STD_LOGIC ; -- clock
		session_i :in session_record;-- from session request fifo
		pkt_i: in eth_ip_tcp; -- from header fifo
		pkt_o : out eth_ip_tcp; -- packet to TCB
		session_o: out session_record; -- to  TCB
		
		-- outputs
		valid_signal : out std_logic_vector(1 downto 0);
		connection_status: out std_logic_vector(number_connetion downto 0); -- from TCB buffer 
		read_req_h:out std_logic;	-- read request from header fifo`
		error_h: in std_logic;	-- error signal from header fifo`
		error_p: in std_logic;	-- error signal from session request fifo
		read_req_p: out std_logic;-- read request to session request fifo from control module
		done: in std_logic --from packet generaiton
		
	);
end tcp_mux;

architecture behav of tcp_mux is


signal session_data:session_record;
signal header_data:eth_ip_tcp;
type control_states is (waiting, chk_pending_req1,chk_pending_req2, chk_header_fifo1, chk_header_fifo2);
signal arbitration,next_state: control_states;

begin

process(clk)
begin
if(rst='1') then
arbitration<=chk_pending_req1;
read_req_h<='0';
read_req_p<='0';
valid_signal<="00";
elsif(rising_edge(clk)) then
case arbitration is

	when chk_pending_req1=>
		read_req_p<='1';
		arbitration<=chk_pending_req2;
	when chk_pending_req2=>
	
		if(error_p='0') then
				valid_signal(0)<='1';
				session_data<=session_i;
				session_o<=session_i;
					arbitration<=waiting;
					next_state<=chk_header_fifo1;
		else
				arbitration<=chk_header_fifo1;
		end if;
		
	when chk_header_fifo1=>
			read_req_h<='1';
			arbitration<=chk_header_fifo2;
	when chk_header_fifo2=>
		if(error_h='0') then
				valid_signal(1)<='1';
				header_data<=pkt_i;
				pkt_o<=pkt_i;
					arbitration<=waiting;
					next_state<=chk_pending_req1;
		else
				arbitration<=chk_pending_req1;
		end if;
	when waiting =>
		if(done='1') then
				valid_signal<="00";
			arbitration<=next_state;
		else
			arbitration<=waiting;
		end if;
end case;		
end if;		
	
end process;
end behav;




