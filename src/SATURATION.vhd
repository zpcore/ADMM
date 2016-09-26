----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    12:44:12 09/01/2016 
-- Design Name: 
-- Module Name:    SATURATION - Behavioral 
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

entity SATURATION is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           RV : in  STD_LOGIC_VECTOR (31 downto 0);
           BOX : in  STD_LOGIC_VECTOR (31 downto 0);
           RV_RDY : in  STD_LOGIC;--DONE signal from RELAXATION
           BOX_REQUEST : out  STD_LOGIC;
					 V_IN : in STD_LOGIC_VECTOR(31 downto 0);
           SAT_DONE : out  STD_LOGIC;
           NEWZ : out  STD_LOGIC_VECTOR (31 downto 0));
end SATURATION;

architecture Behavioral of SATURATION is

signal result : std_logic_vector(31 downto 0);
signal NEWZ_reg : std_logic_vector(31 downto 0);--use register to enhance clk frequency
signal isBig : std_logic;
signal m_axis_result_tvalid : std_logic;
signal m_axis_result_tdata : std_logic_vector(7 downto 0);
type signal_dly_type is array (0 to COMPARATOR_LATENCY-1) of std_logic_vector(31 downto 0);
signal BOX_dly : signal_dly_type;
signal result_dly : signal_dly_type;

--signal debug : std_logic_vector(31 downto 0);--for debug box signal

begin

output_mux : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			NEWZ_reg <= (others=>'0');
		else
--			debug <= BOX;--debug
			if(isBig='1')then
				NEWZ_reg <= BOX_dly(COMPARATOR_LATENCY-1);
			else
				NEWZ_reg <= result_dly(COMPARATOR_LATENCY-1);
			end if;
		end if;
	end if;
end process;

fifoComparasion : process(CLK, RST)
begin
	if(CLK' event and CLK = '1')then
		if(RST = '1')then
			for i in 0 to COMPARATOR_LATENCY-1 loop
				BOX_dly(i) <= (others => '0');
				result_dly(i) <= (others => '0');
			end loop;
		else	
			BOX_dly(0) <= BOX;
			result_dly(0) <= result;
			for i in 0 to COMPARATOR_LATENCY-2 loop
				BOX_dly(i+1) <= BOX_dly(i);
				result_dly(i+1) <= result_dly(i);
			end loop;	
		end if;
	end if;
end process;

NEWZ <= NEWZ_reg;
isBig <= m_axis_result_tdata(0);

SatDone_signal : signal_dly
    Generic map( LATENCY => ADDER_LATENCY+COMPARATOR_LATENCY+1)
		Port map(CLK,RST,RV_RDY,SAT_DONE);	
		
BOXREQUEST_signal : signal_dly
    Generic map( LATENCY => ADDER_LATENCY)
		Port map(CLK,RST,RV_RDY,BOX_REQUEST);	--box constraint with out0 ready, address start counting after request		

Uadd : add--minus
  PORT MAP (
    a => RV,
    b => V_IN,
    clk => CLK,
    isMinus => '1',
    result => result
  );

--Ucmp : CMP
--  PORT MAP (
--    aclk => CLK,
--    s_axis_a_tvalid => '1',
--    s_axis_a_tdata => result,
--    s_axis_b_tvalid => '1',
--    s_axis_b_tdata => BOX,
--    m_axis_result_tvalid => m_axis_result_tvalid,
--    m_axis_result_tdata(0) => isBig
--  );

Ucmp : CMP
  PORT MAP (
    aclk => CLK,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => result,
    s_axis_b_tvalid => '1',
    s_axis_b_tdata => BOX,
    m_axis_result_tvalid => m_axis_result_tvalid,
    m_axis_result_tdata => m_axis_result_tdata
  );

	
end Behavioral;

