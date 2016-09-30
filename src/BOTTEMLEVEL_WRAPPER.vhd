----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    22:39:37 09/01/2016 
-- Design Name: 
-- Module Name:    BOTTEMLEVEL_WRAPPER - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

library ADMM_lib;
use ADMM_lib.ADMM_pkg.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BOTTEMLEVEL_WRAPPER is
    Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		ConfigSTATE : in state_type;
		MVM_DONE : in  STD_LOGIC;
		MVM_RD : out  STD_LOGIC;
		MVM_X : in  STD_LOGIC_VECTOR (31 downto 0);
		LOOP_DONE : in STD_LOGIC;--loop done only when f vector ready
		START : in STD_LOGIC;--start signal after configuration
		iterationCount : in STD_LOGIC_VECTOR(13 downto 0);
		RHO : in  STD_LOGIC_VECTOR (31 downto 0);
		ALPHA : in  STD_LOGIC_VECTOR (31 downto 0);
		ONEMINUSALPHA : in  STD_LOGIC_VECTOR (31 downto 0);
		BOX : in STD_LOGIC_VECTOR(31 downto 0);
		BOX_REQUEST : out STD_LOGIC;
		NEW_QR_RDY : in STD_LOGIC;--rises high means a new QR is rdy
		QR : in STD_LOGIC_VECTOR(31 downto 0);
		F : out  STD_LOGIC_VECTOR (31 downto 0);
		F_RDY : out STD_LOGIC;
		U : out Mby32_type);
end BOTTEMLEVEL_WRAPPER;

architecture Behavioral of BOTTEMLEVEL_WRAPPER is

COMPONENT RELAXATION IS
	Port ( 
		CLK : in  STD_LOGIC;
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
--		LOOP_DONE : in STD_LOGIC;--one iteration complete
		START_ADD_ADDRESS : out STD_LOGIC;--for VVECTOR_CONTAINER
		DONE : out  STD_LOGIC);
END COMPONENT;

COMPONENT SATURATION IS
    Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		RV : in  STD_LOGIC_VECTOR (31 downto 0);
		BOX : in  STD_LOGIC_VECTOR (31 downto 0);
		RV_RDY : in  STD_LOGIC;--DONE signal from RELAXATION
		BOX_REQUEST : out  STD_LOGIC;
		V_IN : in STD_LOGIC_VECTOR(31 downto 0);
		SAT_DONE : out  STD_LOGIC;
		NEWZ : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;

COMPONENT VUPDATE IS
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
END COMPONENT;

COMPONENT VVECTOR_CONTAINER IS
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
END COMPONENT;

COMPONENT ZVECTOR_CONTAINER IS
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
END COMPONENT;

COMPONENT FORMF IS
    Port ( 
		CLK : in  STD_LOGIC;
		RST : in  STD_LOGIC;
		RHO : in  STD_LOGIC_VECTOR (31 downto 0);
		Z1 : in  STD_LOGIC_VECTOR (31 downto 0);
		NEWV : in  STD_LOGIC_VECTOR (31 downto 0);
		V_DONE : in STD_LOGIC;--V_DONE from VUPDATE
		ConfigSTATE : in state_type;
		NEW_QR_RDY : in STD_LOGIC;--rises high means a new QR is rdy to store into FIFO
		QR : in STD_LOGIC_VECTOR(31 downto 0);
		F_RDY : out STD_LOGIC;--write -F
		F : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;

signal z1_formvector : std_logic_vector(31 downto 0);
signal sat_din : std_logic_vector(31 downto 0);
signal sat_done : std_logic;
signal start_zfifo_rd : std_logic;
signal z0 : std_logic_vector(31 downto 0);
signal z1 : std_logic_vector(31 downto 0);
signal z1_pushing : std_logic;
signal newx : std_logic_vector(31 downto 0);
signal newx_fifo : std_logic_vector(31 downto 0);
signal newx_fifo_rdy : std_logic;
signal relaxation_done : std_logic;
signal vforupdate : std_logic_vector(31 downto 0);
signal vforsat : std_logic_vector(31 downto 0);
signal vrequest : std_logic;
signal newv : std_logic_vector(31 downto 0);
signal v_done : std_logic;
signal loop_done_signal : std_logic;
signal start_add_address_signal : std_logic;
signal mvm_rd_signal : std_logic;
signal mvm_done_signal : std_logic;
type ctrl_type is (idle,wt_start,running);
signal ps_ctrl : ctrl_type;
signal ns_ctrl : ctrl_type;
signal vecCount : std_logic_vector(31 downto 0);

begin
mvm_done_signal <= MVM_DONE;
MVM_RD <= mvm_rd_signal;
loop_done_signal <= LOOP_DONE;

state_update : process(CLK, RST)
begin
	if(CLK = '1' and CLK' event)then
		if(RST = '1')then
			ps_ctrl <= idle;
		else
			ps_ctrl <= ns_ctrl;
		end if;
	end if;
end process;

comb_state_update : process(RST, ps_ctrl, loop_done_signal, mvm_done_signal, START)
begin
	if(RST= '1')then
		ns_ctrl <= idle;
	else
		ns_ctrl <= ps_ctrl;
		case ps_ctrl is
			when idle =>
				if(START='1')then
					ns_ctrl <= wt_start;
				end if;
			when wt_start =>
				if(mvm_done_signal = '1')then
					ns_ctrl <= running;
				end if;
			when running =>
				if(loop_done_signal = '1')then
					ns_ctrl <= wt_start;
				end if;			
			when others =>
		end case;
	end if;
end process;


mvm_rd_signal <= '1' when (ps_ctrl=running and mvm_done_signal='1') else '0';--replace the startSignal process


subtractU : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then	
		if(RST='1')then
			vecCount <= (others=>'0');
			for I in 0 to M-1 loop
				U(I)<=(others=>'0');
			end loop;
		else
			if(loop_done_signal='1')then
				vecCount <= (others=>'0');
			elsif(mvm_rd_signal='1')then	
				vecCount <= std_logic_vector(unsigned(vecCount)+1);--11 should be enough				
			end if;
			if(unsigned(iterationCount)=FIXED_ITERATION-1)then--update input signal value. Designer should decide when to send the signal to actuator.
				for I in 0 to M-1 loop
					if(unsigned(vecCount) = N*(Hp+1)+I+1)then
						U(I)<=MVM_X;
					end if;
				end loop;
			end if;
		end if;
	end if;
end process;


URELAXATION : RELAXATION
	Port map( 
		CLK => CLK,
		RST => RST,
		ALPHA => ALPHA,
		ONEMINUSALPHA => ONEMINUSALPHA,
		Z0 => z0,
		X => MVM_X,
		NEWX => newx,
		NEWX_FIFO => newx_fifo,--for updating v vector
		Z1_PUSHING => z1_pushing,--connect with Z1_PUSHING in ZVECTOR_CONTAINER
		NEWX_FIFO_RDY => newx_fifo_rdy,
		REDUCE_READ => mvm_rd_signal,--next clk X & Z0 data will be ready
--		LOOP_DONE => LOOP_DONE,--one iteration complete
		START_ADD_ADDRESS => start_add_address_signal,--for VVECTOR_CONTAINER
		DONE => relaxation_done);

USATURATION : SATURATION
  Port map( 
		CLK => CLK,
		RST => RST,
		RV => newx,
		BOX => BOX,
		RV_RDY => relaxation_done,
		BOX_REQUEST => BOX_REQUEST,
		V_IN => vforsat,
		SAT_DONE => sat_done,
		NEWZ => sat_din);

UVVECTOR_CONTAINER : VVECTOR_CONTAINER
  Port map( 
		CLK => CLK,
		RST => RST, 
		LOOP_DONE => loop_done_signal,
		-------------------------------------------
		VFORSAT => vforsat,
		VFORVUPDATE => vforupdate,
		NEWX_DONE => relaxation_done,
		START_ADD_ADDRESS => start_add_address_signal,
		-------------------------------------------
		VIN => newv,
		VIN_RDY => v_done,
		-----------------------------------
		VREQUEST => vrequest);

UVUPDATE : VUPDATE
  Port map( 
		CLK => CLK,
		RST => RST,
		START => newx_fifo_rdy,--NEWX_FIFO_RDY, NEWX and Z1 ready
		RHO => RHO,
		Z1 => z1,
		NEWX => newx_fifo,--connect with relaxation fifo port
		VREQUEST => vrequest,--request v data from VVECTOR_CONTAINER
		V => vforupdate,--old v from VVECTOR_CONTAINER
		NEWV => newv,--to FORMULATEVECTOR & VVECTOR_CONTAINER
		V_DONE => v_done,--new v complete & Z1 ready, start signal for -f vector formulate
		START_ZFIFO_RD => start_zfifo_rd);--to ZVECTOR_CONTAINER fifo read

UZVECTOR_CONTAINER : ZVECTOR_CONTAINER
	Port map( 
		CLK => CLK,
		RST => RST,
		LOOP_DONE => loop_done_signal,
		SAT_DONE => sat_done,--done signal from saturation
		REDUCE_READ => mvm_rd_signal,--read signal from reduce circuit
		SAT_DIN => sat_din,
		Z1_PUSHING => z1_pushing,
		Z0 => z0,
		Z1 => z1,
		STARTFORMVECTOR =>start_zfifo_rd,
		--connect with START_ZFIFO_RD in VUPDATE
		Z1_FORMVECTOR => z1_formvector);

UFORMF : FORMF
  Port map( 
		CLK => CLK,
		RST => RST,
		RHO => RHO,
		Z1 => z1_formvector,
		NEWV => newv,
		V_DONE => v_done,
		ConfigSTATE => ConfigSTATE,
		NEW_QR_RDY => NEW_QR_RDY,
		QR => QR,
		F_RDY => F_RDY,--write -F
		F => F);

end Behavioral;

