----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vitor Roriz
-- 
-- Create Date: 10/23/2016 05:27:48 PM
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

entity monpro_datapath is
    generic(
        BUS_BIT_WIDTH :  natural := 128);
    port (
        -- Clock and reset
        clk     :   in  std_logic;
        reset_n :   in  std_logic;
        -- Input interface
        monpro_en        :   in  std_logic;
        A_reg_sel        :   in  std_logic;
        B_reg_sel        :   in  std_logic;
        N_reg_sel        :   in  std_logic;   
        B_shift_en       :   in  std_logic;
        start            :   in  std_logic; 
        
        A_in             :   in  std_logic_vector(BUS_BIT_WIDTH-1 downto 0);  
        B_in             :   in  std_logic_vector(BUS_BIT_WIDTH-1 downto 0);  
        N_in             :   in  std_logic_vector(BUS_BIT_WIDTH-1 downto 0);
        
        monpro_ready     : in std_logic;  
        -- Output interface
        monpro_out       :   out std_logic_vector(BUS_BIT_WIDTH-1 downto 0));
end monpro_datapath;

architecture Behavioral of monpro_datapath is
    signal S_reg       :    std_logic_vector(BUS_BIT_WIDTH downto 0); 
    signal S_aux       :    std_logic_vector(BUS_BIT_WIDTH+1 downto 0);
    signal A_reg       :    std_logic_vector(BUS_BIT_WIDTH-1 downto 0);
    signal B_reg       :    std_logic_vector(BUS_BIT_WIDTH-1 downto 0);
    signal B_shift     :    std_logic_vector(BUS_BIT_WIDTH-1 downto 0);
    signal N_reg       :    std_logic_vector(BUS_BIT_WIDTH-1 downto 0);
    signal mux1_sel    :    std_logic;
    signal mux1_out    :    unsigned(BUS_BIT_WIDTH-1 downto 0);
    signal mux2_sel    :    std_logic;
    signal mux2_out    :    unsigned(BUS_BIT_WIDTH-1 downto 0);
    signal D           :    unsigned(BUS_BIT_WIDTH downto 0);
    signal output_aux  :    std_logic_vector(BUS_BIT_WIDTH downto 0);
    
begin

  -- ***************************************************************************
  -- Register A_reg
  -- ***************************************************************************
process (clk, reset_n) begin
  if(reset_n = '0') then
    A_reg <= (others => '0');
  elsif(clk'event and clk='1') then
    if(monpro_en = '0') then
        A_reg <= (others=> '0');
    else
        if(A_reg_sel ='1') then
          A_reg <= A_in; 
        elsif(A_reg_sel = '0') then
          A_reg <= A_reg;
     end if;    
    end if;
  end if;
end process;
  
  
   -- ***************************************************************************
   -- Register B_reg
   -- ***************************************************************************
process (clk, reset_n) begin
   if(reset_n = '0') then
     B_reg <= (others => '0');
   elsif(clk'event and clk='1') then
     if(monpro_en = '0') then
        B_reg <= (others => '0');
     else
        if(B_reg_sel ='1') then
           B_reg <= B_in;
        elsif(B_reg_sel ='0') then
           B_reg <= B_reg;     
         end if;
     end if;
   end if;
 end process;
    
 -- ***************************************************************************
 -- Register B_shift
 -- ***************************************************************************
process (clk, reset_n) begin
 if(reset_n = '0') then
   B_shift <= (others => '0');
 elsif(clk'event and clk='1') then
   if(monpro_en = '0') then
     B_shift <= (others=> '0');
   else
       if(B_shift_en ='1') then
         B_shift <= "0" & B_shift(BUS_BIT_WIDTH-1 downto 1);
       elsif(B_shift_en ='0') then
         B_shift <= B_reg;    
       end if;
   end if;
 end if;
end process;

   -- ***************************************************************************
 -- Register N_reg
 -- ***************************************************************************
process (clk, reset_n) begin
 if(reset_n = '0') then
   N_reg <= (others => '0');
 elsif(clk'event and clk='1') then
   if(monpro_en = '0') then
    N_reg <= (others=>'0');
   else
       if(N_reg_sel ='1') then
         N_reg <= N_in; 
       elsif(N_reg_sel = '0') then
         N_reg <= N_reg;    
       end if;
    end if;
 end if;
end process;
 

   -- ***************************************************************************
   -- Register S_reg
   -- ***************************************************************************
process (clk, reset_n) begin
    if(reset_n = '0') then
       S_reg <= (others => '0');
    elsif(clk'event and clk='1') then
     if(monpro_en = '0') then
        S_reg <= (others => '0');
     else
       if(monpro_ready = '0') then
        S_reg <= S_aux(BUS_BIT_WIDTH downto 0);
       elsif(monpro_ready = '1') then
        S_reg <= S_reg;
       end if;
     end if;
    end if;
end process;
   -- ***************************************************************************
   -- Combinational Cloud
   -- ***************************************************************************   
   
process (A_reg, B_shift, N_Reg, S_reg, mux1_sel, mux1_out, D, mux2_sel, mux2_out, S_aux, output_aux, start)

 begin
  ------------ mux1_out = A*B(i) ---------------------------------
    mux1_sel <= B_shift(0);
    if(mux1_sel='0') then
        mux1_out <= (others => '0');
    elsif(mux1_sel = '1') then
        mux1_out <= unsigned(A_reg);        
    end if;
   ------------ D = S_reg + A*B(i) -------------------------------
    if(start = '1') then
        D <= ('0' & mux1_out) + unsigned(S_reg); -- D has to be 129 bits
    else
        D <= (others => '0');
    end if;
   ------------ mux2_out = (D(0))*N ----------------------------------  
    mux2_sel <= D(0);
    if(mux2_sel='1') then
        mux2_out <= unsigned(N_reg);
    elsif(mux2_sel='0') then
        mux2_out <= (others => '0');
     end if;
    ---------- S_aux = (D + (D(0))*N )/2  ------------------------
    if(start = '1') then
        S_aux   <= std_logic_vector((('0'&D) + ("00"& mux2_out))/2); -- S_aux has to be 130 bits
    else
    S_aux <= (others => '0');
    end if;
 end process;
 
     ----------- OUTPUT and final verification ----------------------
process(S_reg, output_aux, N_reg) begin
    if(unsigned(S_reg) >= unsigned(N_reg)) then
        output_aux <= std_logic_vector(unsigned(S_reg) - unsigned('0'&N_reg)); 
    else
        output_aux <= std_logic_vector(unsigned(S_reg));
    end if;
    monpro_out <= output_aux(BUS_BIT_WIDTH-1 downto 0);
end process;

end Behavioral;
