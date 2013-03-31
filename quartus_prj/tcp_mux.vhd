library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.header_fields.all;

ENTITY tcp_mux IS
generic( number_connetion: integer:=2);
	PORT
	(
		-- inputs
		clock		: in STD_LOGIC ;
		session: in session_record;
		requestconn: in STD_LOGIC; -- From control module 
		-- outputs

		connection_status: out std_logic_vector(number_connetion downto 0)
	);
END tcp_mux;

