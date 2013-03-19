library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity TB_FILE_READ is
end TB_FILE_READ;

architecture test of TB_FILE_READ is


component intermediate_read

  port(
       clock              : in  std_logic;
       reset              : in  std_logic;
		data_o       : in std_logic_vector(7 downto 0);
       EOG              : out std_logic_vector(63 downto 0)
      );
end component;


signal rst:  std_logic;
signal clk:  std_logic := '0';
signal eog:  std_logic;
signal y:    std_logic_vector(63 downto 0);

begin

          
rst <= '0', '1' after 40 ns, '0' after 100 ns;    
clk <= not clk after 10 ns;


input_stim: FILE_READ 
  port map(
       CLK      => clk,
       RST      => rst,
       Y        => y,
       EOG      => eog
      );


end test;



