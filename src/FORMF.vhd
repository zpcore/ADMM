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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FORMF is
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
end FORMF;

architecture Behavioral of FORMF is

type f_type is (idle, QR_init,initA,initB,running);
signal result1 : std_logic_vector(31 downto 0);
signal result2 : std_logic_vector(31 downto 0);
signal ps_ctrl : f_type;
signal ns_ctrl : f_type;
signal traj_request : std_logic;
signal vecCount : std_logic_vector(31 downto 0);--11 should be enough
signal loopCount : std_logic_vector(31 downto 0);--11 should be enough
signal fifoB_input : std_logic_vector(31 downto 0);
signal FIFO_B_wr : std_logic;
signal FIFO_B_wr_reg : std_logic;
signal fifoB_dout : std_logic_vector(31 downto 0);
signal FIFO_A_wr : std_logic;
signal fifoA_dout : std_logic_vector(31 downto 0);
signal FIFO_A_rd : std_logic;
signal FIFO_A_rd_dly : std_logic;
signal wr_control : std_logic;
signal switchFIFO : std_logic;
signal QR_RDY_dly : std_logic;
signal storeCount : std_logic_vector(13 downto 0);
signal mergeZeroState : std_logic;
signal QR_merge0 : std_logic_vector(31 downto 0);
signal FIFO_B_RD : std_logic;
signal fectchFIFOACount : std_logic_vector(13 downto 0);
signal mergeZeroState_dly : std_logic;

begin

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

comb_state_update : process(rst, ps_ctrl, switchFIFO, ConfigSTATE)
begin
	if(RST='1')then
		ns_ctrl <= idle;
	else
		ns_ctrl <= ps_ctrl;
		case ps_ctrl is
-------------------initiate FIFOB------------------
			when idle =>
				if(ConfigSTATE=QR_init)then
					ns_ctrl <= initB;
				end if;
			when initB =>
				if(switchFIFO = '1')then
					ns_ctrl <= initA;
				end if;
			when initA =>
				if(ConfigSTATE=running)then
					ns_ctrl <= running;
				end if;			
			when others =>
		end case;
	end if;
end process;				


FIFO_control : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			vecCount <= (others => '0');
			loopCount <= (others => '0');
			FIFO_B_wr_reg <= '0';
			FIFO_A_rd <= '0';
			switchFIFO <= '0';
			storeCount <= (others=>'0');
			mergeZeroState <= '0';
			fectchFIFOACount <= (others=>'0');
			mergeZeroState_dly <= '0';
		else
			FIFO_B_wr_reg <= '0';
			mergeZeroState_dly <= mergeZeroState;
			if(ps_ctrl=initB)then
				if(switchFIFO='1')then
					switchFIFO <= '0';
					storeCount <= (others=>'0');
				else				
					if(wr_control='1')then
						storeCount <= std_logic_vector(unsigned(storeCount)+1);
					end if;
					if(unsigned(storeCount)=(Hp+1)*N-1 and wr_control='1')then--store (Hp+1)*N QR
						switchFIFO <= '1';
					end if;
				end if;
			elsif(ps_ctrl=running)then
				if(TRAJ_REQUEST='1')then
					vecCount <= std_logic_vector(unsigned(vecCount)+1);	
					if(unsigned(vecCount)>=N or unsigned(loopCount)/=FIXED_ITERATION-1)then--drop N points during the last iteration
						if(mergeZeroState='0')then
							FIFO_B_wr_reg <= '1';
						end if;
					end if;

					if(unsigned(vecCount)=(Hp+1)*N-1)then						
						mergeZeroState <= '1';
					end if;

					if(unsigned(vecCount)=(Hp+1)*N )then						
						FIFO_B_wr_reg <= '0';
					end if;

					if(unsigned(vecCount)=ROW-1)then						
						mergeZeroState <= '0';
						vecCount <= (others => '0');
						loopCount <= std_logic_vector(unsigned(loopCount)+1);
					end if;

					if(unsigned(loopCount)=FIXED_ITERATION-1)then
						if(unsigned(vecCount)=(Hp+1)*N-1)then						
							FIFO_A_rd <= '1';--read 
						end if;
						if(unsigned(vecCount)=ROW-1)then
							loopCount <= (others=>'0');						
						end if;
					end if;
				end if;

				if(FIFO_A_rd='1')then--last the read signal for N clock cycles
					FIFO_B_wr_reg <= '1';
					fectchFIFOACount <= std_logic_vector(unsigned(fectchFIFOACount)+1);
					if(unsigned(fectchFIFOACount)=N-1)then						
						FIFO_A_rd <= '0'; 
						fectchFIFOACount <= (others=>'0');
					end if;
				end if;

			end if;
		end if;
	end if;
end process;

WRF_Delay : signal_dly
	Generic map( LATENCY => 2*ADDER_LATENCY+MULTIPLIER_LATENCY)
	Port map(CLK,RST,V_DONE,F_RDY);	

QR_RDY_Delay : signal_dly
	Generic map( LATENCY => 1)
	Port map(CLK,RST,NEW_QR_RDY,QR_RDY_dly);	

FIFOA_RD_Delay : signal_dly
	Generic map( LATENCY => 1)
	Port map(CLK,RST,FIFO_A_rd,FIFO_A_rd_dly);	
		
--TRAJ_REQUEST_Delay : signal_dly
--	Generic map( LATENCY => ADDER_LATENCY+MULTIPLIER_LATENCY)--out0 ready at time0, start counting address, for design with BRAM
--	Port map(CLK,RST,V_DONE,TRAJ_REQUEST);	

TRAJ_REQUEST_Delay : signal_dly
	Generic map( LATENCY => ADDER_LATENCY+MULTIPLIER_LATENCY-1)--out0 ready at time1, for design with FIFO
	Port map(CLK,RST,V_DONE,TRAJ_REQUEST);	

wr_control <= (NEW_QR_RDY xor QR_RDY_dly) and NEW_QR_RDY;

FIFO_A_wr <= wr_control when (ps_ctrl=initA or ps_ctrl=running)else '0';

fifoB_input <= QR when ps_ctrl=initB else
	fifoB_dout when FIFO_A_rd_dly='0' else fifoA_dout;

FIFO_B_wr <= wr_control when ps_ctrl=initB else FIFO_B_wr_reg; 
	
QR_merge0 <= fifoB_dout when mergeZeroState_dly='0' else (others => '0');

FIFO_B_RD <= traj_request when mergeZeroState='0' else '0';

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
		b => QR_merge0,
		clk => CLK,
		isMinus => '1',
		result => F
  );	

UfifoB : fifo_vector--fifo for current trajectory
	PORT MAP (
		clk => CLK,
		srst => RST,
		din => fifoB_input,
		wr_en => FIFO_B_wr,
		rd_en => FIFO_B_RD,
		dout => fifoB_dout
--		full => full,
--		empty => empty
  );

UfifoA : fifo_vector--fifo for future trajectory
	PORT MAP (
		clk => CLK,
		srst => RST,
		din => QR,
		wr_en => FIFO_A_wr,
		rd_en => FIFO_A_rd,
		dout => fifoA_dout
--		full => full,
--		empty => empty
  );

end Behavioral;

