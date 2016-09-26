----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    20:42:57 06/22/2015 
-- Design Name: 
-- Module Name:    FIFO_2PORTs - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: ISE 14.6
-- Description: Combine 2 16x32bit FIFO using Distributed RAM
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

entity FIFO_2PORTs_Merge is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           wr_en : in  STD_LOGIC;
           rd_en : in  STD_LOGIC;
			     full : out STD_LOGIC;
           dina : in  STD_LOGIC_VECTOR (31 downto 0);
           dinb : in  STD_LOGIC_VECTOR (31 downto 0);
           douta : out  STD_LOGIC_VECTOR (31 downto 0);
           doutb : out  STD_LOGIC_VECTOR (31 downto 0));
end FIFO_2PORTs_Merge;

architecture Behavioral of FIFO_2PORTs_Merge is
--COMPONENT FIFO_Merge
--  PORT (
--    clk : IN STD_LOGIC;
--    srst : IN STD_LOGIC;
--    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--    wr_en : IN STD_LOGIC;
--    rd_en : IN STD_LOGIC;
--    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--    full : OUT STD_LOGIC;
--    empty : OUT STD_LOGIC
--  );
--END COMPONENT;

signal fulla : std_logic;
signal fullb : std_logic;


begin 

full <= fulla or fullb;

U_TOP : MVM_FIFO
  PORT MAP (
    clk => clk,
    srst => rst,
    din => dina,
    wr_en => wr_en,
    rd_en => rd_en,
    dout => douta,
    full => fulla
--  empty => empty
  );
  
U_BOT : MVM_FIFO
  PORT MAP (
    clk => clk,
    srst => rst,
    din => dinb,
    wr_en => wr_en,
    rd_en => rd_en,
    dout => doutb,
	 full => fullb
--    empty => empty
  );
end Behavioral;

