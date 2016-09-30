----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    20:57:53 08/31/2016 
-- Design Name: 
-- Module Name:    VUPDATE - Behavioral 
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

entity VUPDATE is
	Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		START : in STD_LOGIC;--NEWX_FIFO_RDY, NEWX and Z1 ready
		RHO : in  STD_LOGIC_VECTOR (31 downto 0);
		Z1 : in  STD_LOGIC_VECTOR (31 downto 0);
		NEWX : in  STD_LOGIC_VECTOR (31 downto 0);--connect with relaxation fifo port
		VREQUEST : out STD_LOGIC;--request v data from VVECTOR_CONTAINER
		V : in  STD_LOGIC_VECTOR (31 downto 0);--old v from VVECTOR_CONTAINER
		NEWV : out  STD_LOGIC_VECTOR (31 downto 0);--to FORMULATEVECTOR & VVECTOR_CONTAINER
		V_DONE : out STD_LOGIC;--new v complete & Z1 ready, start signal for -f vector formulate
		START_ZFIFO_RD : out STD_LOGIC);--to ZVECTOR_CONTAINER fifo read
end VUPDATE;

architecture Behavioral of VUPDATE is

COMPONENT FIFO_V IS
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           WR : in  STD_LOGIC;
           RD : in  STD_LOGIC;
           DIN : in  STD_LOGIC_VECTOR (31 downto 0);
           DOUT : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;

signal result1 : std_logic_vector(31 downto 0);
signal result2 : std_logic_vector(31 downto 0);
signal vrequest_signal : std_logic;
signal START_ZFIFO_RD_signal : std_logic;

begin

VREQUEST <= vrequest_signal;
START_ZFIFO_RD <= START_ZFIFO_RD_signal;
Uadd1 : add
  PORT MAP (
    a => Z1,
    b => NEWX,
    clk => CLK,
    isMinus => '1',
    result => result1
  );
	
Uadd2 : add
  PORT MAP (
    a => result2,
    b => V,
    clk => CLK,
    isMinus => '0',
    result => NEWV
  );	
	
Umul : mul
  PORT MAP (
    a => RHO,
    b => result1,
    clk => CLK,
    result => result2
  );

Relaxation_Delay : signal_dly
    Generic map( LATENCY => ADDER_LATENCY)
		Port map(CLK,RST,vrequest_signal,START_ZFIFO_RD_signal);
		
Request_Delay : signal_dly
    Generic map( LATENCY => ADDER_LATENCY+MULTIPLIER_LATENCY-1)
		Port map(CLK,RST,START,vrequest_signal);			

FORMULATEVECTOR_Delay : signal_dly
    Generic map( LATENCY => 1)
		Port map(CLK,RST,START_ZFIFO_RD_signal,V_DONE);	
	
end Behavioral;

