LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

library ADMM_lib;
use ADMM_lib.ADMM_pkg.all;
 
ENTITY ADMM_TOP_tb IS
END ADMM_TOP_tb;
 
ARCHITECTURE behavior OF ADMM_TOP_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
component ADMM_TOP is
	Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		NumBRAM : in STD_LOGIC_VECTOR(31 downto 0);
		ADDRBRAM : in STD_LOGIC_VECTOR(31 downto 0);
		WRBRAM : in STD_LOGIC;
		MATData : in STD_LOGIC_VECTOR(31 downto 0);
		ConfigSTATE : in state_type;
--		START : in STD_LOGIC;--start computation signal, after BRAMInit state
		RHO : in STD_LOGIC_VECTOR(31 downto 0);
		ALPHA : in STD_LOGIC_VECTOR(31 downto 0);
		ONEMINUSALPHA : in STD_LOGIC_VECTOR(31 downto 0);
		U : out Mby32_type;
		STATE_RD : out STD_LOGIC;
		X : in STD_LOGIC_VECTOR(31 downto 0);--signal from sensor, serial input(x0,x1,...xN)
--below signal for simulation
		BOX : in STD_LOGIC_VECTOR(31 downto 0);
		BOX_REQUEST : out STD_LOGIC;
		QR : in STD_LOGIC_VECTOR(31 downto 0);
		NEW_QR_RDY : in STD_LOGIC
);
end component;

--Inputs
signal CLK : std_logic := '0';
signal RST : std_logic := '0';
signal NumBRAM : std_logic_vector(31 downto 0) := (others=>'0');
signal ADDRBRAM : std_logic_vector(31 downto 0) := (others=>'0');
signal WRBRAM : std_logic := '0';
signal MATData : std_logic_vector(31 downto 0) := (others=> '0');
signal ConfigSTATE : state_type := idle;
--signal START : std_logic := '0';
signal RHO : std_logic_vector(31 downto 0) := (others=>'0');
signal ALPHA : std_logic_vector(31 downto 0) := (others=>'0');
signal ONEMINUSALPHA : std_logic_vector(31 downto 0) := (others=>'0');
signal BOX : std_logic_vector(31 downto 0) := (others=>'0');
signal BOX_REQUEST : std_logic := '0';
signal QR : std_logic_vector(31 downto 0) := (others=>'0');
signal NEW_QR_RDY : std_logic := '0';
signal X : std_logic_vector(31 downto 0):=(others=>'0');
signal STATE_RD : std_logic:='0';

--Outputs
signal U : Mby32_type;

-- Clock period definitions
constant CLK_period : time := 10 ns;
 
BEGIN
 
-- Instantiate the Unit Under Test (UUT)
uut: ADMM_TOP PORT MAP (
	CLK =>CLK,
	RST =>RST,
	NumBRAM =>NumBRAM,
	ADDRBRAM =>ADDRBRAM,
	WRBRAM =>WRBRAM,
	MATData =>MATData,
	ConfigSTATE =>ConfigSTATE,
	RHO =>RHO,
	ALPHA =>ALPHA,
	ONEMINUSALPHA =>ONEMINUSALPHA,
	U =>U,
	STATE_RD => STATE_RD,
	X => X,
	--below signal for simulation
	BOX =>BOX,
	BOX_REQUEST =>BOX_REQUEST,
	QR =>QR,
	NEW_QR_RDY =>NEW_QR_RDY
	);

   -- Clock process definitions
CLK_process :process
begin
	CLK <= '0';
	wait for CLK_period/2;
	CLK <= '1';
	wait for CLK_period/2;
end process;

boxQR: process
begin		
	BOX <= x"425c0000";--55
	X <= x"3F800000";
	wait;
end process;

   -- Stimulus process
stim_proc: process
begin		
	-- hold reset state for 100 ns.
	RST <= '1';
	wait for 105.1 ns;	
  	RST <= '0';
	ALPHA <= x"3FC00000";--1.5
	ONEMINUSALPHA <= x"BF000000";-- -0.5
	RHO <= x"3F666666";--0.9
	QR <= x"00000000";
	wait for CLK_period*10;
	ConfigSTATE <= BRAM_init;

	wait for CLK_period;
	WRBRAM <= '1';	
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"40df4100";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"40d5e815";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"40232522";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"40bc84ec";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"404611fd";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"40987416";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"40f1ed2e";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"402a178d";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"407a9e7b";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"409f8274";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"40e4d0c7";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"3ff2dfa4";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"410bf268";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"411f1464";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"3ffcceee";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"41113972";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"402be3b8";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"41180aa8";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"411af26f";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"408ce91c";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"3ff91347";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"40b1dd29";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"406a12c4";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40e08c1b";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40ffd7a1";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40ace62e";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40acc4ca";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40c6ccbf";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40c9901b";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40fe58a0";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"3fb0dc87";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40a1d855";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"4118babd";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"40fda35a";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"3f9684f9";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"4117b00b";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"3f972ee8";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"411a0545";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"411b98aa";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"40687c87";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"4074175f";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"4077b975";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"409d8a33";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"40b9cb4a";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"409b7665";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"409c29ae";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"40a2c590";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"40ec155e";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"410f2af7";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"4069db2d";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"41040c95";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"4095d775";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"408ba13b";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"41128670";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"3fd5ee91";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"410d45f2";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"404d94b2";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"3fccbe3f";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"40a2360c";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"3ff49b11";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"3fb159a7";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"40bebbdb";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"40d9ada1";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"3fafd027";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"3fcd8fbd";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"410f94ab";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(5,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"410bebb8";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"40c5943a";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"4022f48a";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"40af6872";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"405f4cd0";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"4088e4c6";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"40a0acf9";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"40d7e196";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"410aab3a";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"40ce8ac9";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"410acbf3";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(6,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"4014c8f2";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"408c02f8";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"40eb8e24";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"4114acb9";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"407c42c8";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"4081a36c";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"4006bae1";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"411ff8cc";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"40e29f85";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"40aa512e";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"40d44e18";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(7,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"3ff7f6aa";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"40db7cf6";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"40901094";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"40b67bb4";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"3fc6796e";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"40f68616";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"408bd841";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"40debf64";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"409ef758";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"40ceb79d";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"40b00908";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(8,ADDRBRAM'length));
	MATData <= x"00000000";





--------write vector
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
	
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(8, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(9, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(10, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(11, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(12, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(13, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(14, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(15, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2016,ADDRBRAM'length));
	MATData <= x"3f800000";
	
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2017,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2017,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2017,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2017,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2017,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2017,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2017,ADDRBRAM'length));
	MATData <= x"3f800000";
wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2017,ADDRBRAM'length));
	MATData <= x"3f800000";
-------write vector

	wait for CLK_period;
	WRBRAM <= '0';
	ConfigSTATE <= idle;	
	wait for CLK_period;
	ConfigSTATE <= QR_init;
	
	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fe5a535";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e3dc4b3";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fbb3879";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3eb15f94";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f9ddf62";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fd88f3b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ff85f2f";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f9bb481";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f0674e6";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f914c4d";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fa74e8b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e330255";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fafe9be";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3eaf6e5a";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f720fdb";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f91c419";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f8c8e54";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f1bbd49";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ff760bf";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ff4dce9";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f5c7a94";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ed44bbc";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3feb82cf";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e062a41";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fd105cb";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f11affe";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fe723f2";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e6dbc0b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ffe6f1a";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fb3d4c5";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f8d0444";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fd8ae1b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ebffd01";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f333b3c";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ff48728";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e0f67a3";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f59302e";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f2148fb";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e8498e2";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fa1ecd9";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fcf3c1b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f9d70f8";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fa299a0";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f56680d";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f9f4cd5";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3eeb9aaa";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ea93b6b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ed3394d";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f47eadf";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f710d43";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f99c982";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f56e543";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f427764";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fb39b85";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e39c14b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ff3cadc";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e678a30";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f0c5f9e";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e8a5377";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fd91f7e";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f248abd";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3dcda390";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fb53798";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f7373ed";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fd49592";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f9c3292";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fd4fd1a";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f8e086b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f4787b6";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f26420e";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3edb7fb8";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3efe9d54";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ebd090a";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e2daaf1";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fe3cdc3";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f37d48d";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f85d101";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fd85bf5";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fb8cddb";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f2a5ba1";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fc3a7da";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f71d3d8";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3e7a5b30";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fe9631b";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fc69ff0";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ee28e04";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f489cf1";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f7e694c";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3ef8b63f";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f396f17";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f8b49ab";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3dcfee84";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fc866dd";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3faa4ead";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fbb306a";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fee6cfd";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f18a172";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f783507";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3f71a3e3";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	wait for 2*CLK_period;
	NEW_QR_RDY <= '1';
	QR <= x"3fb63152";
	wait for CLK_period;
	NEW_QR_RDY <= '0';

	ConfigSTATE <= running;


	wait;
end process;



END;
