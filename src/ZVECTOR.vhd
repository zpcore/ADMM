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

library ADMM_lib;
use ADMM_lib.ADMM_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ZVECTOR is
    Port ( 
		CLK : in  STD_LOGIC;
		ADDRA : in  STD_LOGIC_VECTOR (BOTBRAMADDR_WIDTH-1 downto 0);
		ADDRB : in  STD_LOGIC_VECTOR (BOTBRAMADDR_WIDTH-1 downto 0);
		WEA : in  STD_LOGIC;
		WEB : in  STD_LOGIC;
		DINA : in  STD_LOGIC_VECTOR (31 downto 0);
		DINB : in  STD_LOGIC_VECTOR (31 downto 0);
		DOUTA : out  STD_LOGIC_VECTOR (31 downto 0);
		DOUTB : out  STD_LOGIC_VECTOR (31 downto 0));
end ZVECTOR;

architecture Behavioral of ZVECTOR is

signal bitwea : std_logic_vector(0 downto 0);
signal bitweb : std_logic_vector(0 downto 0);

begin

bitwea <= "0" when WEA='0' else "1";
bitweb <= "0" when WEb='0' else "1";

UVECTOR_BRAM : BOTBRAM
	PORT MAP (
		clka => CLK,
		wea => bitwea,
		addra => ADDRA(BOTBRAMADDR_WIDTH-1 downto 0),
		dina => DINA,
		douta => DOUTA,
		clkb => CLK,
		web => bitweb,
		addrb => ADDRB(BOTBRAMADDR_WIDTH-1 downto 0),
		dinb => DINB,
		doutb => DOUTB
  );


end Behavioral;

