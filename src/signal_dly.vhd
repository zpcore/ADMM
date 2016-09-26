----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    13:08:27 06/21/2015 
-- Design Name: 
-- Module Name:    signal_dly - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Delay the signal_in for 'LATENCY' clock cycles to signal_out
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

entity signal_dly is
   Generic( LATENCY : integer range 1 to 510);
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           signal_in : in  STD_LOGIC;
           signal_out : out  STD_LOGIC);
end signal_dly;

architecture Behavioral of signal_dly is

type signal_dly_type is array (0 to LATENCY-1) of std_logic;
signal signal_dly : signal_dly_type;

begin

process(clk, reset)
begin
	if(clk' event and clk = '1')then
		if(reset = '1')then
			for i in 0 to LATENCY-1 loop
				signal_dly(i) <= '0';
			end loop;
		else	
			signal_dly(0) <= signal_in;	
			for i in 0 to LATENCY-2 loop
				signal_dly(i+1) <= signal_dly(i);
			end loop;	
		end if;
	end if;
end process;
		
signal_out <= signal_dly(LATENCY-1);

end Behavioral;

