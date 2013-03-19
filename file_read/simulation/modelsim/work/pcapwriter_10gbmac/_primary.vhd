library verilog;
use verilog.vl_types.all;
entity pcapwriter_10gbmac is
    generic(
        pcap_filename   : string  := "none";
        pcap_buffsz     : integer := 9000
    );
    port(
        aso_in_data     : in     vl_logic_vector(63 downto 0);
        aso_in_ready    : out    vl_logic;
        aso_in_valid    : in     vl_logic;
        aso_in_sop      : in     vl_logic;
        aso_in_empty    : in     vl_logic_vector(2 downto 0);
        aso_in_eop      : in     vl_logic;
        aso_in_error    : in     vl_logic_vector(5 downto 0);
        clk_in          : in     vl_logic;
        pktcount        : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of pcap_filename : constant is 1;
    attribute mti_svvh_generic_type of pcap_buffsz : constant is 1;
end pcapwriter_10gbmac;
