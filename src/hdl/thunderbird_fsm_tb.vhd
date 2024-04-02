--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is

    component thunderbird_fsm is 
        port(
            i_clk       : in  std_logic;
            i_reset     : in  std_logic;
            i_left      : in  std_logic;
            i_right     : in  std_logic;
            o_lights_L  : out std_logic_vector(2 downto 0);
            o_lights_R  : out std_logic_vector(2 downto 0)
        );
    end component thunderbird_fsm;

    -- Test I/O signals
    -- Inputs
    signal w_clk       : std_logic := '0';
    signal w_reset     : std_logic := '0';
    signal w_left      : std_logic := '0';
    signal w_right     : std_logic := '0';
    -- Outputs
    signal w_lights_L  : std_logic_vector(2 downto 0);
    signal w_lights_R  : std_logic_vector(2 downto 0);
    -- Constants
    constant k_clk_period : time := 10 ns;

begin

    uut: thunderbird_fsm port map (
        i_clk       => w_clk,
        i_reset     => w_reset,
        i_left      => w_left,
        i_right     => w_right,
        o_lights_L  => w_lights_L,
        o_lights_R  => w_lights_R
    );

    -- Clock process
    clk_proc : process
    begin
        w_clk <= '0';
        wait for k_clk_period/2;
        w_clk <= '1';
        wait for k_clk_period/2;
    end process clk_proc;
    
    -- Test Plan Process
    test_proc: process
    begin
        -- Test I/O signals
        -- Constants
        
        -- Reset
        w_reset <= '1';
        wait for k_clk_period;
        w_reset <= '0';
        wait for k_clk_period;
        
        -----------------------------------------------------
        -- Test cases
        
        -- OFF state, no turn signals
        w_left  <= '0';
        w_right <= '0';
        wait for k_clk_period;
        assert w_lights_L = "000" report "Test 1 failed" severity failure;
        assert w_lights_R = "000" report "Test 2 failed" severity failure;
        
        -- Left turn signal
        w_left  <= '1';
        w_right <= '0';
        wait for k_clk_period * 4;  -- Wait for four clock periods to ensure stability
        assert w_lights_L = "110" report "Test 3 failed" severity failure;
        assert w_lights_R = "000" report "Test 4 failed" severity failure;
        
        -- Right turn signal
        w_left  <= '0';
        w_right <= '1';
        wait for k_clk_period * 4;  -- Wait for four clock periods to ensure stability
        assert w_lights_L = "000" report "Test 5 failed" severity failure;
        assert w_lights_R = "001" report "Test 6 failed" severity failure;
        
        -- Hazard lights
        w_right <= '1';
        w_left  <= '1';
        wait for k_clk_period * 4;  -- Wait for four clock periods to ensure stability
        assert w_lights_L = "111" report "Test 7 failed" severity failure;
        assert w_lights_R = "111" report "Test 8 failed" severity failure;
        
        -------------------------------------------------------------------------------
        
        -- Reset again
        w_reset <= '1';
        wait for k_clk_period;
        w_reset <= '0';
        wait for k_clk_period;
        
        -- Another test case
        -- Add more test cases as needed
        
        wait;
    end process test_proc;
    
    -----------------------------------------------------
    
end test_bench;
