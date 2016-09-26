----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    14:48:09 08/29/2016 
-- Design Name: 
-- Module Name:    ADMM_TOP - Behavioral 
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

entity ADMM_TOP is
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
end ADMM_TOP;

architecture Behavioral of ADMM_TOP is

COMPONENT Parallel_Processing IS
	Port ( 	
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		merge : in STD_LOGIC;
		reduce : in STD_LOGIC;
		READY : in STD_LOGIC;
		dataInput : in  K2by32_type;
		resOut : out  STD_LOGIC_VECTOR (31 downto 0);
		RD_Out : in STD_LOGIC;
		DONE : out STD_LOGIC;
		exception : out exception_type);
END COMPONENT;

COMPONENT BOTTEMLEVEL_WRAPPER IS
	Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		MVM_DONE : in  STD_LOGIC;
		MVM_RD : out  STD_LOGIC;
		MVM_X : in  STD_LOGIC_VECTOR (31 downto 0);
		LOOP_DONE : in STD_LOGIC;--loop done only when f vector ready
		RHO : in  STD_LOGIC_VECTOR (31 downto 0);
		ALPHA : in  STD_LOGIC_VECTOR (31 downto 0);
		ONEMINUSALPHA : in  STD_LOGIC_VECTOR (31 downto 0);
		BOX : in STD_LOGIC_VECTOR(31 downto 0);
		BOX_REQUEST : out STD_LOGIC;
		QR : in  STD_LOGIC_VECTOR (31 downto 0);
		TRAJ_REQUEST : out  STD_LOGIC;
		F : out  STD_LOGIC_VECTOR (31 downto 0);
		F_RDY : out STD_LOGIC;
		U : out Mby32_type);
END COMPONENT;

COMPONENT BRAM_WRAPPER IS
	Port ( 
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		ConfigSTATE : in state_type;
		NumBRAM : in STD_LOGIC_VECTOR(31 downto 0);
		WEBRAM : in STD_LOGIC;
		MATData : in STD_LOGIC_VECTOR(31 downto 0);
		ADDR : in STD_LOGIC_VECTOR(TOPBRAMADDR_WIDTH-1 downto 0);
		V_IN : in STD_LOGIC_VECTOR (31 downto 0);		
		DATA_RDY : in STD_LOGIC;
		dataInput : out K2by32_type;
		dataOutputRdy : out STD_LOGIC;
		LOOP_DONE : out STD_LOGIC;
		systemState_rd : out STD_LOGIC;
		START_NEW_LOOP : in STD_LOGIC;
		START : in STD_LOGIC;--Finish storing matrix data into BRAM 
		REDUCE : out STD_LOGIC--Reduce signal to MVM binary tree 		
);
END COMPONENT;
		

signal F_signal : std_logic_vector(31 downto 0);
signal resOut_signal : std_logic_vector(31 downto 0);
signal MVM_RD_signal : std_logic;
signal MVM_DONE_signal : std_logic;
signal dataInput_signal : K2by32_type;
signal LOOP_DONE_signal : std_logic;
signal Reduce_signal : std_logic;
signal F_RDY_signal : std_logic;
signal iteration_start_signal : std_logic;
signal dataOutputRdy_signal : std_logic;
signal systemState_rd_signal : std_logic;
signal systemState_rd_signal_dly : std_logic;
signal F_signal_mux : std_logic_vector(31 downto 0);

begin

F_signal_mux <= X when systemState_rd_signal_dly='1' else F_signal;

F_signal_dly : signal_dly
	Generic map( LATENCY => 1)
	Port map(clk,rst,systemState_rd_signal,systemState_rd_signal_dly);	

iteration_control : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			iteration_start_signal <= '0';
		else
			iteration_start_signal <= '0';
			if(LOOP_DONE_signal = '1')then
				iteration_start_signal <= '1';
			end if;
		end if;
	end if;
end process;


UParallel_Processing : Parallel_Processing
	Port map(
		clk => CLK,
		rst => RST,
		merge => '0',
		reduce => Reduce_signal,
		READY => dataOutputRdy_signal,
		dataInput => dataInput_signal,
		resOut => resOut_signal,
		RD_Out => MVM_RD_signal,
		DONE => MVM_DONE_signal
--		exception : out exception_type
	);

UBOTTEMLEVEL_WRAPPER : BOTTEMLEVEL_WRAPPER
	Port map( 
		CLK => CLK,
		RST => RST,
		MVM_DONE => MVM_DONE_signal,
		MVM_RD => MVM_RD_signal,
		MVM_X => resOut_signal,
		LOOP_DONE => LOOP_DONE_signal,
		RHO => RHO,
		ALPHA => ALPHA,
		ONEMINUSALPHA => ONEMINUSALPHA, 
		BOX => BOX,--simulation
		BOX_REQUEST => BOX_REQUEST,--simulation
		QR => QR,--simulation
		TRAJ_REQUEST => TRAJ_REQUEST,--simulation
		F => F_signal,
		F_RDY => F_RDY_signal,
		U => U);

UBRAM_WRAPPER : BRAM_WRAPPER
	Port Map( 
		CLK => CLK,
		RST => RST,
		ConfigSTATE => ConfigSTATE,
		NumBRAM => NumBRAM,
		WEBRAM => WEBRAM,
		MATData => MATData,
		ADDR => ADDRBRAM(TOPBRAMADDR_WIDTH-1 downto 0),
		V_IN => F_signal_mux,
		DATA_RDY => F_RDY_signal,
		dataInput => dataInput_signal,
		dataOutputRdy => dataOutputRdy_signal,
		LOOP_DONE => LOOP_DONE_signal,
		systemState_rd => systemState_rd_signal,
		START_NEW_LOOP => iteration_start_signal,
		START => START,
		REDUCE => Reduce_signal
);


end Behavioral;

