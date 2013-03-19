library verilog;
use verilog.vl_types.all;
entity addsub is
    port(
        dataa           : in     vl_logic_vector(7 downto 0);
        datab           : in     vl_logic_vector(7 downto 0);
        add_sub         : in     vl_logic;
        clk             : in     vl_logic;
        result          : out    vl_logic_vector(8 downto 0)
    );
end addsub;
