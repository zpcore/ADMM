----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    21:48:12 08/31/2016 
-- Design Name: 
-- Module Name:    VVECTOR_CONTAINER - Behavioral 
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
 

library ADMM_lib;
use ADMM_lib.ADMM_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VVECTOR_CONTAINER is
	Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC; 
		LOOP_DONE : in STD_LOGIC;
		-------------------------------------------
		VFORSAT : out  STD_LOGIC_VECTOR (31 downto 0);
		VFORVUPDATE : out  STD_LOGIC_VECTOR (31 downto 0);
		NEWX_DONE : in STD_LOGIC;--DONE signal from RELAXATION
		START_ADD_ADDRESS : in STD_LOGIC;--addrb start adding, from relaxation
		-------------------------------------------
		VIN : in  STD_LOGIC_VECTOR (31 downto 0);
		VIN_RDY : in  STD_LOGIC;--connect to V_DONE from VUPDATE
		-----------------------------------
		VREQUEST : in STD_LOGIC);
end VVECTOR_CONTAINER;

architecture Behavioral of VVECTOR_CONTAINER is
COMPONENT VVECTOR IS
	Port ( 
		CLK : in  STD_LOGIC;
		ADDRA : in  STD_LOGIC_VECTOR (BOTBRAMADDR_WIDTH-1 downto 0);
		ADDRB : in  STD_LOGIC_VECTOR (BOTBRAMADDR_WIDTH-1 downto 0);
		WEA : in  STD_LOGIC;
		WEB : in  STD_LOGIC;
		DINA : in  STD_LOGIC_VECTOR (31 downto 0);
--		DINB : in  STD_LOGIC_VECTOR (31 downto 0);
--		DOUTA : out  STD_LOGIC_VECTOR (31 downto 0);
		DOUTB : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;


COMPONENT FIFO_V IS
	Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		WR : in  STD_LOGIC;
		RD : in  STD_LOGIC;
		DIN : in  STD_LOGIC_VECTOR (31 downto 0);
		DOUT : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;

signal addra : std_logic_vector(BOTBRAMADDR_WIDTH-1 downto 0);
signal addrb : std_logic_vector(BOTBRAMADDR_WIDTH-1 downto 0);
--signal VREQUEST_dly : std_logic;
signal doutb: std_logic_vector(31 downto 0);

begin

--V_Address : process(CLK, RST)
--begin
--	if(CLK='1' and CLK' event)then
--		if(RST='1')then
--			addra <= (others => '0');
--			addrb <= (others => '0');
--		else
--			if(START_ADD_ADDRESS='1')then
--				addrb <= std_logic_vector(unsigned(addrb)+1);
--				if(unsigned(addrb)=S1-1)then
--					addrb <= (others=>'0');
--				end if;
--			end if;
--			if(VIN_RDY='1')then
--				addra <= std_logic_vector(unsigned(addra)+1);
--				if(unsigned(addra)=S1-1)then
--					addra <= (others=>'0');
--				end if;
--			end if;
--		end if;
--	end if;
--end process;

--for simulation, modelsim bram 0 address bug. 
V_Address : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			addra <= std_logic_vector(to_unsigned(1,addra' length));
			addrb <= std_logic_vector(to_unsigned(1,addrb' length));
		else
			if(START_ADD_ADDRESS='1')then
				addrb <= std_logic_vector(unsigned(addrb)+1);
				if(unsigned(addrb)=S1)then
					addrb <= std_logic_vector(to_unsigned(1,addrb' length));
				end if;
			end if;
			if(VIN_RDY='1')then
				addra <= std_logic_vector(unsigned(addra)+1);
				if(unsigned(addra)=S1)then
					addra <= std_logic_vector(to_unsigned(1,addra' length));
				end if;
			end if;
		end if;
	end if;
end process;


VFORSAT <= doutb;

UVVECTOR : VVECTOR
	Port map( 
		CLK => CLK,
		ADDRA => addra,--write
		ADDRB => addrb,--read
		WEA => VIN_RDY,
		WEB => '0',
		DINA => VIN,
--		DINB => ,
--		DOUTA => ,
		DOUTB => doutb);

UFIFO_V : FIFO_V
	Port map( 
		CLK => CLK,
		RST => RST,
		WR => NEWX_DONE,
		RD => VREQUEST,
		DIN => doutb,
		DOUT => VFORVUPDATE);


end Behavioral;

