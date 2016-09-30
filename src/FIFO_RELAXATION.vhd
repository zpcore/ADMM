----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:41:14 08/31/2016 
-- Design Name: 
-- Module Name:    FIFO_RELAXATION - Behavioral 
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

entity FIFO_RELAXATION is
    Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		WR : in  STD_LOGIC;
		RD : in  STD_LOGIC;
		DIN : in  STD_LOGIC_VECTOR(31 downto 0);
		DOUT : out  STD_LOGIC_VECTOR(31 downto 0));
end FIFO_RELAXATION;

architecture Behavioral of FIFO_RELAXATION is

COMPONENT tiny_FIFO
	PORT (
		clk : IN STD_LOGIC;
		srst : IN STD_LOGIC;
		din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en : IN STD_LOGIC;
		rd_en : IN STD_LOGIC;
		dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		full : OUT STD_LOGIC;
		empty : OUT STD_LOGIC
	);
END COMPONENT;

begin

Utiny_FIFO : tiny_FIFO
	PORT map(
		clk => CLK,
		srst => RST,
		din => DIN,
		wr_en => WR,
		rd_en => RD,
		dout => DOUT
--		full => ,
--		empty => 
);

end Behavioral;

