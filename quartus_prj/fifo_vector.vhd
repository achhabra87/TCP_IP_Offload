library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo_vector is
generic (RAMsize: integer :=7);
port (  data_in: in std_logic_vector (7 downto 0);  
    clk,nrst: in std_logic;
    readReq: in std_logic;  
        writeReq: in std_logic; 
        data_out: out std_logic_vector(7 downto 0); 
        empty: out std_logic;  
        full: out std_logic;
    error: out std_logic);
	 
	 
end fifo_vector;

architecture Behavioral of fifo_vector is
constant size:integer:=7;
type memory_type is array (0 to size ) of std_logic_vector(7 downto 0);
signal memory : memory_type :=(others => (others => '0')); 
signal tag: memory_type :=(others => (others => '0'));  
type state is (readwrite,updatetag);
signal y:state;
signal tagexist:std_logic:='0';
signal tag_current: std_logic_vector(7 downto 0):=(others => '0');
signal write_addr: std_logic_vector(7 downto 0):=(others => '0');

begin
  process(clk,nrst)
  variable read_ptr, write_ptr : std_logic_vector(7 downto 0) :="00000000";  -- read and write pointers
  variable isempty , isfull : std_logic :='0';
  begin
  if nrst='0' then
    memory <= (others => (others => '0'));
    empty <='1';
    full <='0';
    data_out <= "00000000";
    read_ptr := "00000000";
    write_ptr := "00000000";
    isempty :='1';
    isfull :='0';
    error <='0';
	 y<=readwrite;
  elsif clk'event and clk='1' then
  case y is
  when readwrite=>
    if readReq='0' and writeReq='0' then
      error <='0';
		y<=readwrite;
    end if;
    if readReq='1' then
		y<=readwrite;
      if isempty='1' then
        error <= '1';
      else
        data_out <= memory(conv_integer(read_ptr));
        isfull :='0';
        full <='0';
        error <='0';
        if read_ptr=conv_std_logic_vector(size-1,8) then
          read_ptr := "00000000";
        else
          read_ptr := read_ptr + '1';
        end if;
        if read_ptr=write_ptr then
          isempty:='1';
          empty <='1';
        end if;
      end if;
    end if;
    if writeReq='1' then
      if isfull='1' then
			y<=readwrite;
        error <='1';
      else
			y<=updatetag;
        memory(conv_integer(write_ptr)) <= data_in;
		  write_addr<=write_ptr;
        for addr in 0 to 7 loop             --   Check for data
				if ( data_in = memory(conv_integer (addr))) then
				--Found Match
					tagexist<='1';
					tag(conv_integer (write_ptr)) <= tag(conv_integer (addr));
				end if;
			end loop;

        error <='0';
        isempty :='0';
        empty <='0';
        if write_ptr=conv_std_logic_vector(size-1,8) then
          write_ptr := "00000000";
        else
          write_ptr := write_ptr + '1';
        end if;
        if write_ptr=read_ptr then
          isfull :='1';
          full <='1';
        end if;
      end if;
    end if; 
	 when updatetag=>
        if(tagexist='0') then
          tag(conv_integer (write_addr)) <=tag_current+1;
          tag_current<=tag_current+1;
        end if;
        tagexist<='0';
		    y<=readwrite;
  end case;
  end if;
  end process;

end Behavioral;







