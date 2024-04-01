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
--| FILENAME      : thunderbird_fsm.vhd
--| AUTHOR(S)     : Capt Phillip Warner, Capt Dan Johnson
--| CREATED       : 03/2017 Last modified 06/25/2020
--| DESCRIPTION   : This file implements the ECE 281 Lab 2 Thunderbird tail lights
--|					FSM using enumerated types.  This was used to create the
--|					erroneous sim for GR1
--|
--|					Inputs:  i_clk 	 --> 100 MHz clock from FPGA
--|                          i_left  --> left turn signal
--|                          i_right --> right turn signal
--|                          i_reset --> FSM reset
--|
--|					Outputs:  o_lights_L (2:0) --> 3-bit left turn signal lights
--|					          o_lights_R (2:0) --> 3-bit right turn signal lights
--|
--|					Upon reset, the FSM by defaults has all lights off.
--|					Left ON - pattern of increasing lights to left
--|						(OFF, LA, LA/LB, LA/LB/LC, repeat)
--|					Right ON - pattern of increasing lights to right
--|						(OFF, RA, RA/RB, RA/RB/RC, repeat)
--|					L and R ON - hazard lights (OFF, ALL ON, repeat)
--|					A is LSB of lights output and C is MSB.
--|					Once a pattern starts, it finishes back at OFF before it 
--|					can be changed by the inputs
--|					
--|
--|                 BINARY State Encoding key
--|                 --------------------
--|                  State | ENCODING
--|                 --------------------
--|                  OFF   | 000
--|                  ON    | 111
--|                  R1    | 001
--|                  R2    | 010
--|                  R3    | 100
--|                  L1    | 110
--|                  L2    | 101
--|                  L3    | 011
--|                 --------------------
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : None
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
 
entity thunderbird_fsm is 
  port(
	   i_clk, i_reset  : in    std_logic;
       i_left, i_right : in    std_logic;
       o_lights_L      : out   std_logic_vector(2 downto 0);
       o_lights_R      : out   std_logic_vector(2 downto 0)
  );
end thunderbird_fsm;

architecture thunderbird_fsm_arch of thunderbird_fsm is 
-- CONSTANTS ------------------------------------------------------------------
   constant OFF   : std_logic_vector(2 downto 0) := "000";
   constant ON_STATE    : std_logic_vector(2 downto 0) := "111";
   constant R1    : std_logic_vector(2 downto 0) := "001";
   constant R2    : std_logic_vector(2 downto 0) := "010";
   constant R3    : std_logic_vector(2 downto 0) := "100";
   constant L1    : std_logic_vector(2 downto 0) := "110";
   constant L2    : std_logic_vector(2 downto 0) := "101";
   constant L3    : std_logic_vector(2 downto 0) := "011";
   
   type state_type is (OFF_ST, ON_ST, R1_ST, R2_ST, R3_ST, L1_ST, L2_ST, L3_ST);
   signal state, next_state : state_type;
      
   signal w_R_next : std_logic_vector(2 downto 0);
   signal w_L_next : std_logic_vector(2 downto 0);
begin

	-- CONCURRENT STATEMENTS --------------------------------------------------------	
	--Next State Logic:
	process(state, i_left, i_right)
        begin
            case state is
                when OFF_ST =>
                    -- Reset to OFF state
                    w_R_next <= OFF;
                    w_L_next <= OFF;
                    if i_left = '1' and i_right = '0' then
                        next_state <= L1_ST;
                    elsif i_left = '0' and i_right = '1' then
                        next_state <= R1_ST;
                    elsif i_left = '1' and i_right = '1' then
                        next_state <= ON_ST;
                    else
                        next_state <= OFF_ST;
                    end if;
                    
                when ON_ST =>
                    w_R_next <= ON_STATE; -- Changed constant name
                    w_L_next <= ON_STATE; -- Changed constant name
                    next_state <= OFF_ST;
                    
                when R1_ST =>
                    w_R_next <= R1;
                    w_L_next <= OFF;
                    next_state <= R2_ST;
                    
                when R2_ST =>
                    w_R_next <= R2;
                    w_L_next <= OFF;
                    next_state <= R3_ST;
                    
                when R3_ST =>
                    w_R_next <= R3;
                    w_L_next <= OFF;
                    next_state <= OFF_ST;
                    
                when L1_ST =>
                    w_R_next <= OFF;
                    w_L_next <= L1;
                    next_state <= L2_ST;
                    
                when L2_ST =>
                    w_R_next <= OFF;
                    w_L_next <= L2;
                    next_state <= L3_ST;
                    
                when L3_ST =>
                    w_R_next <= OFF;
                    w_L_next <= L3;
                    next_state <= OFF_ST;
                    
                when others =>
                    -- Default case
                    w_R_next <= OFF;
                    w_L_next <= OFF;
                    next_state <= OFF_ST;
            end case;
        end process;
        -- Output Logic
        o_lights_R <= w_R_next;
        o_lights_L <= w_L_next;
        
        -- PROCESSES ------------------------------------------
        register_proc : process(i_clk, i_reset)
        begin
            if i_reset = '1' then
                state <= OFF_ST;        -- Reset state to OFF
            elsif rising_edge(i_clk) then
                state <= next_state;    -- Next state becomes current state
            end if;
        end process register_proc;
        ------------------------------------------------------					   
				  
end thunderbird_fsm_arch;