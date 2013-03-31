library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.header_fields.all;
use work.global_constants.all;

ENTITY control_module IS
generic( number_connetion: integer:=2;data_width: integer:=8);
	PORT
	(
		-- inputs
		clock		: in std_logic;
		session_num: in std_logic_vector(number_connetion-1 downto 0);
		read_data: in std_logic;	-- from application layer when to start reading message from 
		data_in : in std_logic_vector(data_width-1 downto 0); -- data from session layer to be sent to output buffer 
		valid	: in std_logic; -- session layer indication to 
		-- outputs
		write_data: out std_LOGIC;	-- tell session layer that data is ready to be read
		connection_status: out std_logic_vector(number_connetion downto 0)
	);
END control_module;


architecture rtl_ctrl of control_module is
	type array_type3 is array (0 to 1) of session_record;
	signal sessionTable : array_type3;

	signal session	: session_record:=((others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'));
	signal requestconn: std_LOGIC:='0';

	component tcp_mux IS
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
END component;

	
	
begin
u1: tcp_mux
	PORT map
	(
		clock	=>clock,
		session=>session,
		requestconn=>requestconn, -- From control module 
		connection_status=>connection_status
	);	


process(clock)
begin
sessionTable(0)<=(host_mac1,dest_mac1,host_ip1,ip_dest1,sport_1,dport_1);
sessionTable(1)<=(host_mac1,dest_mac1,host_ip1,ip_dest2,sport_2,dport_1);
if( rising_edge(clock)) then
	if( valid = '1' ) then
		session<=sessionTable(conv_integer(session_num));
		requestconn<='1';
	else
		requestconn<='0';
	end if;
end if;
end process;

end rtl_ctrl ;

