library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
use std.textio.all;
use work.spwpkg.all;

entity spwstream_tb is
end spwstream_tb;

architecture spwstream_tb_arch of spwstream_tb is
    constant clk_freq: real := 20.0e6;
    constant clk_period: time := 50 ns;
    constant bit_period: time := 100 ns;

    component spwstream is
        generic(
            sysfreq:            real;
            txclkfreq:          real := 0.0;
            rximpl:             spw_implementation_type := impl_generic;
            rxchunk:            integer range 1 to 4 := 1;
            tximpl:             spw_implementation_type := impl_generic;
            rxfifosize_bits:    integer range 6 to 14 := 11;
            txfifosize_bits:    integer range 2 to 14 := 11 
        );
        port(
            clk:         in std_logic;
            rxclk:       in std_logic;
            txclk:       in std_logic;
            rst:         in std_logic;
            autostart:   in std_logic;
            linkstart:   in std_logic;
            linkdis:     in std_logic;
            txdivcnt:    in std_logic_vector(7 downto 0);
            tick_in:     in std_logic;
            ctrl_in:     in std_logic_vector(1 downto 0);
            time_in:     in std_logic_vector(5 downto 0);
            txwrite:     in std_logic;
            txflag:      in std_logic;
            txdata:      in std_logic_vector(7 downto 0);
            txrdy:       out std_logic;
            txhalff:     out std_logic;
            tick_out:    out std_logic;
            ctrl_out:    out std_logic_vector(1 downto 0);
            time_out:    out std_logic_vector(5 downto 0);
            rxvalid:     out std_logic;
            rxhalff:     out std_logic;
            rxflag:      out std_logic;
            rxdata:      out std_logic_vector(7 downto 0);
            rxread:      in std_logic;
            started:     out std_logic;
            connecting:  out std_logic;
            running:     out std_logic;
            errdisc:     out std_logic;
            errpar:      out std_logic;
            erresc:      out std_logic;
            errcred:     out std_logic;
            spw_di:      in std_logic;
            spw_si:      in std_logic;
            spw_do:      out std_logic;
            spw_so:      out std_logic
        );
    end component;
    
    signal clk:         std_logic;
    signal rxclk:       std_logic;
    signal txclk:       std_logic;
    signal rst:         std_logic;
    signal autostart:   std_logic;
    signal linkstart:   std_logic;
    signal linkdis:     std_logic;
    signal txdivcnt:    std_logic_vector(7 downto 0);
    signal tick_in:     std_logic;
    signal ctrl_in:     std_logic_vector(1 downto 0);
    signal time_in:     std_logic_vector(5 downto 0);
    signal txwrite:     std_logic;
    signal txflag:      std_logic;
    signal txdata:      std_logic_vector(7 downto 0);
    signal txrdy:       std_logic;
    signal txhalff:     std_logic;
    signal tick_out:    std_logic;
    signal ctrl_out:    std_logic_vector(1 downto 0);
    signal time_out:    std_logic_vector(5 downto 0);
    signal rxvalid:     std_logic;
    signal rxhalff:     std_logic;
    signal rxflag:      std_logic;
    signal rxdata:      std_logic_vector(7 downto 0);
    signal rxread:      std_logic;
    signal started:     std_logic;
    signal connecting:  std_logic;
    signal running:     std_logic;
    signal errdisc:     std_logic;
    signal errpar:      std_logic;
    signal erresc:      std_logic;
    signal errcred:     std_logic;
    signal spw_di:      std_logic;
    signal spw_si:      std_logic;
    signal spw_do:      std_logic;
    signal spw_so:      std_logic;

    signal xor_o:       std_logic;
    signal xor_i:       std_logic;

    signal clk_enable: boolean := false;

begin
    
spwstream_inst: spwstream
    generic map(
        sysfreq         => clk_freq,
        txclkfreq       => clk_freq,
        rximpl          => impl_generic,
        rxchunk         => 1,
        tximpl          => impl_generic,
        rxfifosize_bits => 9,
        txfifosize_bits => 8
    )
    port map(
        clk         => clk,
        rxclk       => rxclk,
        txclk       => txclk,
        rst         => rst,
        autostart   => autostart,
        linkstart   => linkstart,
        linkdis     => linkdis,
        txdivcnt    => txdivcnt,
        tick_in     => tick_in,
        ctrl_in     => ctrl_in,
        time_in     => time_in,
        txwrite     => txwrite,
        txflag      => txflag,
        txdata      => txdata,
        txrdy       => txrdy,
        txhalff     => txhalff,
        tick_out    => tick_out,
        ctrl_out    => ctrl_out,
        time_out    => time_out,
        rxvalid     => rxvalid,
        rxhalff     => rxhalff,
        rxflag      => rxflag,
        rxdata      => rxdata,
        rxread      => rxread,
        started     => started,
        connecting  => connecting,
        running     => running,
        errdisc     => errdisc,
        errpar      => errpar,
        erresc      => erresc,
        errcred     => errcred,
        spw_di      => spw_di,
        spw_si      => spw_si,
        spw_do      => spw_do,
        spw_so      => spw_so
    );

    clk <= not clk after clk_period/2 when clk_enable else '0';
    txclk <= clk;
    rxclk <= clk;

    xor_i <= spw_si xor spw_di;
    xor_o <= spw_so xor spw_do;
    
    p_stimuli: process is
        procedure gen_bit(b: std_logic) is
        begin
            spw_si <= not (spw_si xor spw_di xor b);
            spw_di <= b;
            wait for bit_period;
        end procedure;
        procedure gen_fct is
        begin
            gen_bit('0');
            gen_bit('1');
            gen_bit('0');
            gen_bit('0');
        end procedure;
        procedure gen_esc is
        begin
            gen_bit('0');
            gen_bit('1');
            gen_bit('1');
            gen_bit('1');
        end procedure;
        procedure gen_null is
        begin
            gen_esc;
            gen_fct;
        end procedure; 
        procedure gen_eop is
        begin
            gen_bit('1');
            gen_bit('0');
            gen_bit('1');
            gen_bit('0');
        end procedure;
        procedure gen_data(p: std_logic; data: std_logic_vector(7 downto 0)) is
        begin
            gen_bit(p);
            gen_bit('0');
            gen_bit(data(0));
            gen_bit(data(1));
            gen_bit(data(2));
            gen_bit(data(3));
            gen_bit(data(4));
            gen_bit(data(5));
            gen_bit(data(6));
            gen_bit(data(7));
        end procedure gen_data;
    begin
        rst <= '0';
        linkdis <= '0';
        spw_di <= '0';
        spw_si <= '0';
        wait for clk_period;
        clk_enable <= true;
        wait for clk_period;
        wait for clk_period;
        wait for 6.4 us;
        wait for 12.8 us;
        wait for 10 us;
        linkstart <= '1';
        wait for bit_period * 8;
        gen_null;
        gen_null;
        wait for bit_period;
        gen_fct;
        gen_fct;
        wait for bit_period * 2;
        gen_data('1', "11110000");
        gen_eop;
        gen_data('0', "11100000");
        gen_eop;
        wait for 10 us;
        wait;
    end process;
        
end architecture spwstream_tb_arch;