library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dflipflop is
	port(
		q             : out  std_logic;
		q1              : out  std_logic;
		d       : in std_logic;
		clk              : in std_logic
	);
end dflipflop;

architecture rtl_dflipflop of dflipflop is

signal q_1:std_logic:='0';
signal q_0:std_logic:='1';
begin


process(clk,d)
begin
if(clk='1' and clk'event) then
	q_0<=d;
	q_1<=not d;
end if;

end process;
q<=q_0;
q1<=q_1;
end rtl_dflipflop;