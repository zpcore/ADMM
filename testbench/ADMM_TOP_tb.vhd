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
		WEBRAM : in STD_LOGIC;
		MATData : in STD_LOGIC_VECTOR(31 downto 0);
		ConfigSTATE : in state_type;
		START : in STD_LOGIC;--start computation signal, after BRAMInit state
		RHO : in STD_LOGIC_VECTOR(31 downto 0);
		ALPHA : in STD_LOGIC_VECTOR(31 downto 0);
		ONEMINUSALPHA : in STD_LOGIC_VECTOR(31 downto 0);
		U : out Mby32_type;
		X : in STD_LOGIC_VECTOR(31 downto 0);--signal from sensor, serial input(x0,x1,...xN)
--below signal for simulation
		BOX : in STD_LOGIC_VECTOR(31 downto 0);
		BOX_REQUEST : out STD_LOGIC;
		QR : in STD_LOGIC_VECTOR(31 downto 0);
		TRAJ_REQUEST : out STD_LOGIC
);
end component;

--Inputs
signal CLK : std_logic := '0';
signal RST : std_logic := '0';
signal NumBRAM : std_logic_vector(31 downto 0) := (others=>'0');
signal ADDRBRAM : std_logic_vector(31 downto 0) := (others=>'0');
signal WEBRAM : std_logic := '0';
signal MATData : std_logic_vector(31 downto 0) := (others=> '0');
signal ConfigSTATE : state_type := idel;
signal START : std_logic := '0';
signal RHO : std_logic_vector(31 downto 0) := (others=>'0');
signal ALPHA : std_logic_vector(31 downto 0) := (others=>'0');
signal ONEMINUSALPHA : std_logic_vector(31 downto 0) := (others=>'0');
signal BOX : std_logic_vector(31 downto 0) := (others=>'0');
signal BOX_REQUEST : std_logic := '0';
signal QR : std_logic_vector(31 downto 0) := (others=>'0');
signal TRAJ_REQUEST : std_logic := '0';
signal X : std_logic_vector(31 downto 0);

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
	WEBRAM =>WEBRAM,
	MATData =>MATData,
	ConfigSTATE =>ConfigSTATE,
	START =>START,
	RHO =>RHO,
	ALPHA =>ALPHA,
	ONEMINUSALPHA =>ONEMINUSALPHA,
	U =>U,
	X => X,
	--below signal for simulation
	BOX =>BOX,
	BOX_REQUEST =>BOX_REQUEST,
	QR =>QR,
	TRAJ_REQUEST =>TRAJ_REQUEST
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
	QR <= x"3f800000";
	X <= x"3F800000";
	wait;
end process;

   -- Stimulus process
stim_proc: process
begin		
	-- hold reset state for 100 ns.
	RST <= '1';
	wait for 105 ns;	
  RST <= '0';
	ALPHA <= x"3FC00000";--1.5
	ONEMINUSALPHA <= x"3F000000";--0.5
	RHO <= x"3F666666";--0.9
	wait for CLK_period*10;
	ConfigSTATE <= BRAM_init;

	wait for CLK_period;
	WEBRAM <= '1';
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"40be69d4";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"4112da41";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"4008ec0b";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"4112c029";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"410fb7b7";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"408f309a";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"407ae069";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(0,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"4081d537";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"3fdacb27";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"40efc86d";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"40d89efc";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"41125959";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"403a58b1";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"409952f8";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(1,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"41063bf9";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"3fa8c3df";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40dbd4cd";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"4101b71e";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"40ca9f5c";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"403afa30";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"411ee1b4";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(2,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"408d0956";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"4106b3af";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"40527488";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"40be4643";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"3f970701";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"411cbe3b";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"411a9e6c";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(3,ADDRBRAM'length));
	MATData <= x"00000000";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(0, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"4102ce2c";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(1, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"409ef6e8";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(2, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"403a1f13";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(3, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"40965c18";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(4, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"40696a1c";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(5, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"4106629a";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(6, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
	MATData <= x"3fbbe00e";

	wait for CLK_period;
	NumBRAM <= std_logic_vector(to_unsigned(7, NumBRAM'length));
	ADDRBRAM <= std_logic_vector(to_unsigned(4,ADDRBRAM'length));
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
-------write vector




	wait for CLK_period;
	WEBRAM <= '0';
	ConfigSTATE <= idel;
	START <= '1';	
	wait for CLK_period;
	START <= '0';

	wait;
end process;



END;
