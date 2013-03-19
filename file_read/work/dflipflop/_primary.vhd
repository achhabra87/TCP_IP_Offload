library verilog;
use verilog.vl_types.all;
entity dflipflop is
    port(
        q               : out    vl_logic;
        q1              : out    vl_logic;
        d               : in     vl_logic;
        clk             : in     vl_logic
    );
end dflipflop;
