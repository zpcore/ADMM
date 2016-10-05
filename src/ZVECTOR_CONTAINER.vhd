----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    12:55:35 08/30/2016 
-- Design Name: 
-- Module Name:    ZVECTOR_CONTAINER - Behavioral 
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

entity ZVECTOR_CONTAINER is
	Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		LOOP_DONE : in STD_LOGIC;
		-----------------------------------------
		SAT_DONE : in  STD_LOGIC;--done signal from saturation
		REDUCE_READ : in STD_LOGIC; --read signal from reduce circuit
		SAT_DIN : in  STD_LOGIC_VECTOR (31 downto 0);
		Z1_PUSHING : out STD_LOGIC;--one clk later start pushing Z1
		Z0 : out  STD_LOGIC_VECTOR (31 downto 0);
		Z1 : out  STD_LOGIC_VECTOR (31 downto 0);
		STARTFORMVECTOR : in STD_LOGIC;--one clk latet start pushing Z1_FORMVECTOR
		--connect with START_ZFIFO_RD in VUPDATE
		Z1_FORMVECTOR : out STD_LOGIC_VECTOR(31 downto 0));
end ZVECTOR_CONTAINER;

architecture Behavioral of ZVECTOR_CONTAINER is
component ZVECTOR is
    Port ( CLK : in  STD_LOGIC;
           ADDRA : in  STD_LOGIC_VECTOR (BOTBRAMADDR_WIDTH-1 downto 0);
           ADDRB : in  STD_LOGIC_VECTOR (BOTBRAMADDR_WIDTH-1 downto 0);
           WEA : in  STD_LOGIC;
           WEB : in  STD_LOGIC;
           DINA : in  STD_LOGIC_VECTOR (31 downto 0);
           DINB : in  STD_LOGIC_VECTOR (31 downto 0);
           DOUTA : out  STD_LOGIC_VECTOR (31 downto 0);
           DOUTB : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

COMPONENT FIFO_Z1 IS
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           WR : in  STD_LOGIC;
           RD : in  STD_LOGIC;
           DIN : in  STD_LOGIC_VECTOR (31 downto 0);
           DOUT : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;

signal addra : STD_LOGIC_VECTOR (BOTBRAMADDR_WIDTH-1 downto 0);
signal addrb : STD_LOGIC_VECTOR (BOTBRAMADDR_WIDTH-1 downto 0);
signal Z1_reg : STD_LOGIC_VECTOR (31 downto 0);

begin

--writeAddress : process(CLK, RST)
--begin
--	if(CLK='1' and CLK' event)then
--		if(RST='1')then
--			addra <= (others => '0');
--			addrb <= (others => '0');
--		else
--			if(REDUCE_READ = '1')then
--				addrb <= std_logic_vector(unsigned(addrb)+1);
--				if(unsigned(addrb)=ROW-1)then
--					addrb <= (others=>'0');
--				end if;
--			end if;
--			if(SAT_DONE = '1')then
--				addra <= std_logic_vector(unsigned(addra)+1);
--				if(unsigned(addra)=ROW-1)then
--					addra <= (others=>'0');
--				end if;
--			end if;
--		end if;
--	end if;
--end process;

--for simulation, modelsim bram 0 address bug. 
writeAddress : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			addra <= std_logic_vector(to_unsigned(1,addra' length));
			addrb <= std_logic_vector(to_unsigned(1,addrb' length));
		else
			if(REDUCE_READ = '1')then
				addrb <= std_logic_vector(unsigned(addrb)+1);
				if(unsigned(addrb)=ROW)then
					addrb <= std_logic_vector(to_unsigned(1,addrb' length));
				end if;
			end if;
			if(SAT_DONE = '1')then
				addra <= std_logic_vector(unsigned(addra)+1);
				if(unsigned(addra)=ROW)then
					addra <= std_logic_vector(to_unsigned(1,addra' length));
				end if;
			end if;
		end if;
	end if;
end process;


Z1Delay : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			Z1_reg <= (others => '0');
		else
			Z1_reg <= SAT_DIN;
		end if;
	end if;
end process;


Z1_PUSHING <= SAT_DONE;
Z1 <= Z1_reg;

U_zvector : ZVECTOR
	port map(
		CLK => CLK,
		ADDRA => addra,--write 
		ADDRB => addrb,--read
		WEA => SAT_DONE,
		WEB => '0',
		DINA => SAT_DIN,
		DINB => (others => '0'),
--		DOUTA => ,--useless
		DOUTB => Z0);

UFIFO_Z1 : FIFO_Z1
	Port map( 
		CLK => CLK,
		RST => RST,
		WR => SAT_DONE,
		RD => STARTFORMVECTOR,
		DIN => SAT_DIN,
		DOUT => Z1_FORMVECTOR);

end Behavioral;

