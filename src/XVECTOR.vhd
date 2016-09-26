----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:01:26 08/29/2016 
-- Design Name: 
-- Module Name:    ZVECTOR - Behavioral 
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

entity XVECTOR is
    Port ( CLK : in  STD_LOGIC;
           ADDRA : in  STD_LOGIC_VECTOR (10 downto 0);
           ADDRB : in  STD_LOGIC_VECTOR (10 downto 0);
           WEA : in  STD_LOGIC;
           WEB : in  STD_LOGIC;
           DINA : out  STD_LOGIC_VECTOR (31 downto 0);
           DINB : out  STD_LOGIC_VECTOR (31 downto 0);
           DOUTA : out  STD_LOGIC_VECTOR (31 downto 0);
           DOUTB : out  STD_LOGIC_VECTOR (31 downto 0));
end XVECTOR;

architecture Behavioral of XVECTOR is

begin


end Behavioral;

