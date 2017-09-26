----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/29/2016 03:10:03 AM
-- Design Name: 
-- Module Name: monpro - Behavioral
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity monpro is
    generic(BUS_BIT_WIDTH    :   natural := 128);
    Port (
        -- Clock and reset
    clk              :   in  std_logic;
    reset_n          :   in  std_logic;
    -- Input interface
    monpro_start     :   in   std_logic;
    A_in             :   in  std_logic_vector(BUS_BIT_WIDTH-1 downto 0);  
    B_in             :   in  std_logic_vector(BUS_BIT_WIDTH-1 downto 0);  
    N_in             :   in  std_logic_vector(BUS_BIT_WIDTH-1 downto 0);  
    -- Output interface
    monpro_ready     :   out std_logic;
    monpro_out       :   out std_logic_vector(BUS_BIT_WIDTH-1 downto 0)
         );
end monpro;

architecture Behavioral of monpro is
signal  A_reg_sel         :   std_logic;
signal  B_reg_sel         :   std_logic;
signal  N_reg_sel         :   std_logic;
signal  B_shift_en        :   std_logic;
signal  start             :   std_logic; 
signal  monpro_ready_aux  :   std_logic;
signal  monpro_en         :   std_logic;
begin

    process(monpro_ready_aux) begin
        monpro_ready <= monpro_ready_aux;
    end process;

      -- Instantiate the datapath
    u_monpro_datapath   : entity work.monpro_datapath
      generic map (
        BUS_BIT_WIDTH => BUS_BIT_WIDTH)
      port map(
    clk => clk,
    reset_n => reset_n,
    
    monpro_en => monpro_en,
    A_reg_sel => A_reg_sel,
    B_reg_sel => B_reg_sel,
    N_reg_sel => N_reg_sel,
    B_shift_en => B_shift_en,
    start => start,
    A_in => A_in,
    B_in => B_in,
    N_in => N_in,
    monpro_ready => monpro_ready_aux,
    
    monpro_out => monpro_out );   
    
     -- Instantiate the controller
    u_monpro_controller  : entity work.monpro_controller
      generic map (
        BUS_BIT_WIDTH => BUS_BIT_WIDTH)
      port map(
   
   clk => clk,
   reset_n => reset_n,
   monpro_en => monpro_en,
   monpro_start => monpro_start,
   A_reg_sel => A_reg_sel,
   B_reg_sel => B_reg_sel,
   N_reg_sel => N_reg_sel,
   B_shift_en => B_shift_en,
   start => start,
   monpro_ready => monpro_ready_aux);
   
end Behavioral;

