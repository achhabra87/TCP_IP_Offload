library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.global_constants.all;
--use work.header_field.all;

entity memory_dual_port is
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
		--en_ip_ck			: out std_logic; -- if packet contains IP header - Activates IP checksum module;
		--en_tcp_ck			: out std_logic;-- if packet contains TCP header - Activates TCP checksum module
		--en_tcp_state		: out std_logic;
		rst_o					:	out std_logic; -- sends RST1 1 to all the other modules when indentifies an error in any of the fields i
		--reg_o 				: out	std_logic_vector(input_width-1 downto 0); -- send an intermediate value to TCP and/or IP checksum module. 
		--index 				: out integer;
		
		
		-- not required for design but useful to debug
		s							:	buffer std_logic_vector(5 downto 0)	
	 );
end memory_dual_port;





architecture rtl_memory_dual_port of memory_dual_port is





end rtl_memory_dual_port;
