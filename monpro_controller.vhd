----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vitor Roriz
-- 
-- Create Date: 10/27/2016 11:21:29 PM
-- Design Name: 
-- Module Name: monpro_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity monpro_controller is
  generic( BUS_BIT_WIDTH : natural := 128);
  Port ( 
          -- Clock and reset
          clk              :   in  std_logic;
          reset_n          :   in  std_logic;
          
          -- Inputs
          monpro_start     :   in   std_logic;
          
          -- Outputs
          A_reg_sel        :   out  std_logic;
          B_reg_sel        :   out  std_logic;
          N_reg_sel        :   out  std_logic;
          start            :   out  std_logic; 
          monpro_en        :   out   std_logic;
          
          B_shift_en       :   out std_logic;
          monpro_ready     :   out std_logic
            
        );
end monpro_controller;

architecture Behavioral of monpro_controller is
type state_type is (IDLE, WAITING, READY, RESTART);

signal  monpro_en_internal     :   std_logic := '0';
signal  shift_counter          :   unsigned(16 downto 0);
signal  monpro_ready_internal  :   std_logic := '0';
signal  current_state          :   state_type := IDLE ;
--signal  next_state             :   state_type;



begin

-- Connecting output monpro_en with internal monpro_en signal (monpro_en_signal)
process(monpro_en_internal) begin
    monpro_en <= monpro_en_internal;
end process;


  -- ***************************************************************************
  -- shift counter register
  -- ***************************************************************************
process (clk, reset_n) begin
  if(reset_n = '0') then
    shift_counter <= (others => '0');
  elsif(clk'event and clk='1') then
    if(monpro_en_internal ='1') then
      shift_counter <= shift_counter +1; 
    else
      shift_counter <= (others => '0');  
    end if;
  end if;
end process;

  -- ***************************************************************************
  -- shift counter monitor
  -- ***************************************************************************
process (clk, reset_n) begin
  if(reset_n = '0') then
    monpro_ready <= '0';
    monpro_ready_internal <= '0';
  elsif(clk'event and clk='1') then
  
      case (to_integer(shift_counter)) is
      when (0) =>
          A_reg_sel <= '1';
          B_reg_sel <= '1';
          N_reg_sel <= '1';
          B_shift_en <= '0';
          monpro_ready <= '0'; 
          monpro_ready_internal <= '0';
          start <= '0';
      when (1) =>
          A_reg_sel <= '0';
          B_reg_sel <= '0';
          N_reg_sel <= '0';
          B_shift_en <= '1';
          monpro_ready <= '0';  
          monpro_ready_internal <= '0';
          start <= '1';
       
      when 2 to (BUS_BIT_WIDTH) =>   
          A_reg_sel <= '0';
          B_reg_sel <= '0';
          N_reg_sel <= '0';
          B_shift_en <= '1';
          monpro_ready <= '0';  
          monpro_ready_internal <= '0';  
          start <= '1';         
      when others => 
         if(monpro_en_internal = '1') then
          A_reg_sel <= '0';
          B_reg_sel <= '0';
          N_reg_sel <= '0';
          B_shift_en <= '1';
          monpro_ready <= '1'; 
          monpro_ready_internal <= '1';
          start <= '0';
         else
          A_reg_sel <= '1';
          B_reg_sel <= '1';
          B_reg_sel <= '1';
          B_shift_en <= '0';
          monpro_ready <= '0';
          monpro_ready_internal <= '0';
          start <= '0';
         end if;
    end case;
  end if;
end process;

  -- ***************************************************************************
  -- FSM for controlling the Start of the operation
  -- ***************************************************************************
  
  
-- Updating next state
process(clk, reset_n) begin
    if(reset_n = '0') then
     current_state <= IDLE;
    elsif(clk'event and clk = '1') then
        case current_state is
            when IDLE =>
                if(monpro_start = '0' and monpro_ready_internal = '0') then
                    current_state   <= IDLE;
                elsif(monpro_start = '1' and monpro_ready_internal = '0') then
                    current_state <= WAITING;
                end if;
            when WAITING =>
                if(monpro_ready_internal = '0') then
                    current_state <= WAITING;
                 elsif(monpro_ready_internal = '1') then
                    current_state <= READY;
                end if;
            when READY =>
                if(monpro_start = '0') then
                    current_state <= READY;
                elsif(monpro_start = '1') then
                    current_state <= RESTART;
                end if;
            when RESTART =>
                current_state <= WAITING;
        end case;
    end if;
end process;

-- Updating current state
--process(clk, reset_n) begin 
--    if(reset_n = '0') then
--        current_state <= IDLE;
--    elsif(clk'event and clk='1') then
--        current_state <= next_state;
--    end if;
--end process;

-- Combinational cloud for the FSM -> setting outputs based on current state (Moore Machine format)

process(current_state) begin
    if(current_state = IDLE) then
        monpro_en_internal <= '0';
    elsif(current_state = WAITING) then
        monpro_en_internal <= '1';
    elsif(current_state = READY) then
        monpro_en_internal <= '1';
    else -- (current_state = RESTART)
        monpro_en_internal <= '0';
    end if;
end process;


 
end Behavioral;
