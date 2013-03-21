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
begin

process(clk)
begin
if(rising_edge(clk)) then
	q<=d;
	q1<=not(d);
end if;

end process;

end rtl_dflipflop;