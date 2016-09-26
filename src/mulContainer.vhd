----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:05:05 06/22/2015 
-- Design Name: 
-- Module Name:    mulContainer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library ADMM_lib;
use ADMM_lib.ADMM_pkg.all;

entity mulContainer is
    Port ( clk : in  STD_LOGIC;
           a : in  STD_LOGIC_VECTOR (31 downto 0);
           b : in  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
end mulContainer;

architecture Behavioral of mulContainer is

begin

U : mul
  PORT MAP (
    a => a,
    b => b,
    clk => clk,
    result => result
  );
end Behavioral;

