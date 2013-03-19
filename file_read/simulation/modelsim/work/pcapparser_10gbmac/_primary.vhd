library verilog;
use verilog.vl_types.all;
entity pcapparser_10gbmac is
    generic(
        pcap_filename   : string  := "none";
        ipg             : integer := 32
    );
    port(
        pause           : in     vl_logic;
        aso_out_data    : out    vl_logic_vector(63 downto 0);
        aso_out_ready   : in     vl_logic;
        aso_out_valid   : out    vl_logic;
        aso_out_sop     : out    vl_logic;
        aso_out_empty   : out    vl_logic_vector(2 downto 0);
        aso_out_eop     : out    vl_logic;
        aso_out_error   : out    vl_logic_vector(5 downto 0);
        clk_out         : in     vl_logic;
        newpkt          : out    vl_logic;
        pcapfinished    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of pcap_filename : constant is 1;
    attribute mti_svvh_generic_type of ipg : constant is 1;
end pcapparser_10gbmac;
