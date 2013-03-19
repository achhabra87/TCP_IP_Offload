library verilog;
use verilog.vl_types.all;
entity intermediate_read is
    generic(
        out_bit         : integer := 64;
        in_bit          : integer := 8
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        data_i          : in     vl_logic_vector(7 downto 0);
        data_y          : out    vl_logic_vector(63 downto 0);
        data_o          : out    vl_logic_vector(63 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of out_bit : constant is 1;
    attribute mti_svvh_generic_type of in_bit : constant is 1;
end intermediate_read;
