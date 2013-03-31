library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.standard.string;
use std.textio.all;
use work.txt_util.all;
 
 
entity FILE_READ is
  generic (
           stim_file:       string  := "dat3.dat";
           input_bit :		integer:=8;
			  output_bit :		integer:=64
			 );
end FILE_READ;

 
-- I/O Dictionary
--
-- Inputs:
--
-- CLK:              new cell needed
-- RST:              reset signal, wait with reading till reset seq complete
--   
-- Outputs:
--
-- Y:                Output vector
-- EOG:              End Of Generation, all lines have been read from the file
--
   
   
architecture read_from_file of FILE_READ is

component dflipflop
	port(
		q             : out  std_logic;
		q1              : out  std_logic;
		d       : in std_logic;
		clk              : in std_logic
	);
end component; 
  
  



component packetizer
	generic(
		input_width: integer:=64
		
	);
	port(
		-- inputs
		data_i				:	in	std_logic_vector(input_width-1 downto 0);
		clk					: in std_logic; -- clock input
		start_packet		: in std_logic; -- indicates when packet start arriving
		end_packet			: in std_logic; -- indicates when packet stops receving
		EN					: in std_logic; -- EN

		-- outputs
		-- not required for design but useful to debug
		s							:	buffer std_logic_vector(5 downto 0)	
	 );
end component;
  
  

    file stimulus: TEXT open read_mode is stim_file;
signal sbuff			:	std_logic_vector(5 downto 0);
signal RST				:  std_logic;
signal CLK				:  std_logic := '0';
signal eog				:  std_logic;
signal Y				: std_logic_vector(input_bit-1 downto 0);
signal output			: std_logic_vector(output_bit-1 downto 0):=(others=>'0');
signal out_feed			: std_logic_vector(output_bit-1 downto 0):=(others=>'0');
signal shift_out_feed	: std_logic_vector(output_bit-1 downto 0);
signal dummy			: std_logic_vector(output_bit-1 downto 0);
signal start_msg		: std_logic:='0';
signal stop_msg			: std_logic:='0';
signal EN			: std_logic:='0';

signal counter			: std_logic_vector(2 downto 0):=(others=>'0');
signal byte_counter		: std_logic_vector(output_bit-1 downto 0):=(others=>'0');

signal d1				:std_logic;
signal d2				:std_logic;
signal d3				:std_logic;


signal q_o1				:std_logic;
signal q_o2				:std_logic;
signal q_o3				:std_logic;
type states is (start_packet,end_packet,reading);
signal ystate: states;

begin
RST <= '1', '0' after 10 ns;    
CLk <= not CLK after 10 ns;



flop1: dflipflop 
  port map(
q=>q_o1,
q1=>d1,
d=>d1,
clk=>CLK
      );
		
flop2: dflipflop 
  port map(
q=>q_o2,
q1=>d2,
d=>d2,
clk=>q_o1
      );

flop3: dflipflop 
  port map(
q=>q_o3,
q1=>d3,
d=>d3,
clk=>q_o2
      );



packetize: packetizer 
	port map(
		-- inputs
		data_i=>out_feed,	
		clk	=>q_o3,
		start_packet=>start_msg,
		end_packet=>stop_msg,
		EN=>EN,	

		-- outputs

		--rst_o					:	out std_logic; -- sends RST1 1 to all the other modules when indentifies an error in any of the fields i
	
		-- not required for design but useful to debug
		s=>sbuff
	 );







-- read data and control information from a file

receive_data: process

variable l: line;
--variable s: string(y'range);
variable s: string(1 to 8);
begin                                       

   EOG <= '0';
   
   -- wait for Reset to complete
   --wait until RST='1';
   wait until RST='0';
	EN<='1';

   
   while not endfile(stimulus) loop

     -- read digital data from input file
     readline(stimulus, l);
     read(l, s);
		
	  
     Y <= to_std_logic_vector(s);
	  if(Y(1)='Z') then
			print("starting packet");
			--ystate<=start_packet;
			start_msg<='1';
			counter<=(others=>'0');
	   elsif (Y(1)='X') then
			--ystate<=end_packet;
			stop_msg<='1';
			print("end of packet");
			counter<=(others=>'0');
			
		else
			ystate<=reading;
			if(counter=0) then
				stop_msg<='0';
				output(63 downto 56)<=Y;
			elsif(counter=1) then
				output(55 downto 48)<=Y;	
			elsif(counter=2) then
				output(47 downto 40 )<=Y;
			elsif(counter=3) then
				output(39 downto 32)<=Y;
			elsif(counter=4) then
				output(31 downto 24)<=Y;
			elsif(counter=5) then
				 output(23 downto 16)<=Y;
			elsif(counter=6) then
				output(15 downto 8)<=Y;	
			elsif(counter=7) then
				output(7 downto 0)<=Y;
				out_feed(63 downto 8)<=output(63 downto 8);
				out_feed(7 downto 0)<=Y;
				start_msg<='0';

			end if;
			 counter<=counter+1;
		 end if;
     wait until CLK = '1';

   end loop;

  
   
   print("I@FILE_READ: reached end of "& stim_file);
   EOG <= '1';
   
   wait;

 end process receive_data;

process(q_o3)
begin

if (q_o3'EVENT and q_o3 = '1') then
case ystate is 
 when start_packet=>
	--start_msg<='1';
 when end_packet=>
	--stop_msg<='1';
 when reading=>
	--start_msg<='0';
	--stop_msg<='0';
	end case;
end if;	
end process;

 
 


end read_from_file;
 
