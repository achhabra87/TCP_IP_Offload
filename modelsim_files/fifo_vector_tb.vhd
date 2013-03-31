library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo_vector_tb is end fifo_vector_tb;
architecture fifo_tb of fifo_vector_tb is
component fifo_vector is
generic (RAMsize: integer );
port (  data_in: in std_logic_vector (7 downto 0);  
    clk,nrst: in std_logic;
    readReq: in std_logic;  
        writeReq: in std_logic; 
        data_out: out std_logic_vector(7 downto 0); 
        empty: out std_logic;  
        full: out std_logic;
    error: out std_logic);
end component;
signal data_in_t:  std_logic_vector (7 downto 0);  
signal clk_t,nrst_t: std_logic :='0';
signal readReq_t: std_logic;  
signal writeReq_t: std_logic; 
signal data_out_t: std_logic_vector(7 downto 0); 
signal empty_t: std_logic;  
signal full_t: std_logic;
signal error_t: std_logic;

begin
  u1: fifo_vector generic map (4) port map (data_in_t,clk_t,nrst_t,readReq_t,writeReq_t,data_out_t,empty_t,full_t,error_t);
  nrst_t <= '0' , '1' after 15 ns;
  clk_t <= not clk_t after 2 ns;
  readReq_t <= '1' after 21 ns , '0' after 23 ns, '1' after 41 ns, '0' after 45 ns , '0' after 53 ns,'0' after 55 ns;
  writeReq_t <= '1' after 28 ns, 
                '0' after 31 ns , 
                '1' after 33 ns , 
                '0' after 35 ns, 
                '1' after 37 ns, 
                '1' after 45 ns, 
                '0' after 47 ns , 
                '1' after 49 ns, 
                '0' after 51 ns,
                 '1' after 53 ns, 
                 '1' after 55 ns,
                 '1' after 57 ns;
  data_in_t <= "00000000" after 29 ns, 
               "11111111" after 33 ns , 
                "11111000" after 37 ns, 
                "00000000" after 45 ns, 
                "00000111" after 49 ns;

end fifo_tb;
