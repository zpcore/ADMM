----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    16:21:25 08/29/2016 
-- Design Name: 
-- Module Name:    RELAXATION - Behavioral 
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

entity RELAXATION is
		Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           ALPHA : in  STD_LOGIC_VECTOR (31 downto 0);
					 ONEMINUSALPHA : in  STD_LOGIC_VECTOR (31 downto 0);
           Z0 : in  STD_LOGIC_VECTOR (31 downto 0);
           X : in  STD_LOGIC_VECTOR (31 downto 0);
           NEWX : out  STD_LOGIC_VECTOR (31 downto 0);--for computing z vector
					 NEWX_FIFO : out  STD_LOGIC_VECTOR (31 downto 0);--for updating v vector
					 Z1_PUSHING : in STD_LOGIC;--connect with Z1_PUSHING in ZVECTOR_CONTAINER
					 NEWX_FIFO_RDY : out STD_LOGIC;
           REDUCE_READ : in  STD_LOGIC;--next clk X & Z0 data will be ready
					 START_ADD_ADDRESS : out STD_LOGIC;--for VVECTOR_CONTAINER
           DONE : out  STD_LOGIC);
end RELAXATION;

architecture Behavioral of RELAXATION is

COMPONENT FIFO_RELAXATION IS
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           WR : in  STD_LOGIC;
           RD : in  STD_LOGIC;
           DIN : in  STD_LOGIC_VECTOR(31 downto 0);
           DOUT : out  STD_LOGIC_VECTOR(31 downto 0));
END COMPONENT;

signal adda : std_logic_vector(31 downto 0);
signal addb : std_logic_vector(31 downto 0);
signal NEWX_reg : std_logic_vector(31 downto 0);
signal complete : std_logic;
signal result : std_logic_vector(31 downto 0);

begin
storeResult:process(CLK,RST)
begin
	if(CLK' event and CLK = '1')then
		DONE <= '0';
		if(RST='1')then
			NEWX_reg <= (others => '0');
		else
			if(complete = '1')then
				NEWX_reg <= result;
				DONE <= '1';
			end if;
		end if;
	end if;
end process;

NEWX <= NEWX_reg;
START_ADD_ADDRESS <= complete;

Umul1 : mul
  PORT MAP (
    a => ALPHA,
    b => X,
    clk => CLK,
    result => addb
  );

Umul2 : mul
  PORT MAP (
    a => ONEMINUSALPHA,
    b => Z0,
    clk => CLK,
    result => adda
  );

Uadd : add
  PORT MAP (
    a => adda,
    b => addb,
    clk => CLK,
    isMinus => '0',
    result => result
  );

NEWX_Delay : signal_dly
    Generic map( LATENCY => ADDER_LATENCY+MULTIPLIER_LATENCY+1)
		Port map(CLK,RST,REDUCE_READ,complete);

NEWX_FIFO_Delay : signal_dly
    Generic map(LATENCY => 1)--revised 2->1
		Port map(CLK,RST,Z1_PUSHING,NEWX_FIFO_RDY);
		
UFIFO: FIFO_RELAXATION 
	Port map( 
		CLK => CLK,
    RST => RST,--active high
    WR => complete,
    RD => Z1_PUSHING,
    DIN => result,
    DOUT => NEWX_FIFO);


end Behavioral;

