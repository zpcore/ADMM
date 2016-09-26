----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    22:05:51 09/01/2016 
-- Design Name: 
-- Module Name:    FORMF - Behavioral 
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

entity FORMF is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           RHO : in  STD_LOGIC_VECTOR (31 downto 0);
           Z1 : in  STD_LOGIC_VECTOR (31 downto 0);
           NEWV : in  STD_LOGIC_VECTOR (31 downto 0);
					 V_DONE : in STD_LOGIC;--V_DONE from VUPDATE
					 TRAJ_REQUEST : out STD_LOGIC;
           QR : in  STD_LOGIC_VECTOR (31 downto 0);
					 F_RDY : out STD_LOGIC;--write -F
           F : out  STD_LOGIC_VECTOR (31 downto 0));
end FORMF;

architecture Behavioral of FORMF is

signal result1 : std_logic_vector(31 downto 0);
signal result2 : std_logic_vector(31 downto 0);

begin

WRF_Delay : signal_dly
  Generic map( LATENCY => 2*ADDER_LATENCY+MULTIPLIER_LATENCY)
	Port map(CLK,RST,V_DONE,F_RDY);	
		
TRAJ_REQUEST_Delay : signal_dly
	Generic map( LATENCY => ADDER_LATENCY+MULTIPLIER_LATENCY)--out0 ready at time0, start counting address
	Port map(CLK,RST,V_DONE,TRAJ_REQUEST);	

Uadd1 : add
  PORT MAP (
    a => Z1,
    b => NEWV,
    clk => CLK,
    isMinus => '0',
    result => result1
  );	
	
Umul : mul
  PORT MAP (
    a => RHO,
    b => result1,
    clk => CLK,
    result => result2
  );
	
Uadd2 : add
  PORT MAP (
    a => result2,
    b => QR,
    clk => CLK,
    isMinus => '0',
    result => F
  );	

end Behavioral;

