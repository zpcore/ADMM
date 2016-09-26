----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    22:42:57 06/22/2015 
-- Design Name: 
-- Module Name:    Mini_Reduction - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library ADMM_lib;
use ADMM_lib.ADMM_pkg.all;



entity Mini_Reduction is
	 Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           reduce_pre : in  STD_LOGIC;
           READY : in  STD_LOGIC;
           reduce_pos : out  STD_LOGIC;----connect to the reduce_pre port of next Mini_Reduction
           dataInput : in  STD_LOGIC_VECTOR (31 downto 0);
           dataOutput : out  STD_LOGIC_VECTOR (31 downto 0);
           DONE : out  STD_LOGIC;----connect to the READY port of next Mini_Reduction
			  FINISH : out STD_LOGIC----means the accumulation is complete, needn't to be used if we collect result from the last Mini_Reduction component sequentially
			  );
end Mini_Reduction;

architecture Behavioral of Mini_Reduction is
type MR_State_type is (wt_1st, wt_2nd, wt_tail);
signal MR_State : MR_State_type;
signal RResReg : twoby32_type;
signal pre_done : std_logic;
signal reduce : std_logic;
signal finishMerge : std_Logic;

begin


process(clk, rst)
begin
	if(clk' event and clk = '1')then
		if(rst = '1')then
			pre_done <= '0';
			reduce <= '0';
			RResReg(0) <= (others => '0');
			RResReg(1) <= (others => '0');
			MR_State <= wt_1st;
			finishMerge <= '0';
		else
			if(pre_done = '1')then
				pre_done <= '0';
			end if;
			if(reduce = '1')then
				reduce <= '0';
			end if;
			if(finishMerge = '1')then
				finishMerge <= '0';
			end if;
			
			if(READY = '1')then
				if(MR_State = wt_1st)then
					if(reduce_pre = '1')then
						RResReg(0) <= dataInput;
						MR_State <= wt_2nd;
					else
						RResReg(0) <= dataInput;
						RResReg(1) <= (others => '0');
						pre_done <= '1';
					end if;					
				elsif(MR_State = wt_2nd)then	
					pre_done <= '1';
					RResReg(1) <= dataInput;
					if(reduce_pre = '1')then
						MR_State <= wt_tail;
						reduce <= '1';
					else
						finishMerge <= '1';
						MR_State <= wt_1st;
					end if;
				elsif(MR_State = wt_tail)then
					RResReg(0) <= dataInput;
					RResReg(1) <= (others => '0');
					pre_done <= '1';
					if(reduce_pre = '0')then
						MR_State <= wt_1st;
					else
						reduce <= '1';
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

DONE_Delay : signal_dly
    Generic map( LATENCY =>ADDER_LATENCY)
	 Port map(clk,rst,pre_done,DONE);
reduce_Delay : signal_dly
    Generic map( LATENCY =>ADDER_LATENCY)
	 Port map(clk,rst,reduce,reduce_pos);
finishMerge_Delay : signal_dly
    Generic map( LATENCY =>ADDER_LATENCY)
	 Port map(clk,rst,finishMerge,FINISH);	 
	 
U : addContainer
  PORT MAP (
    a => RResReg(0),
    b => RResReg(1),
    clk => clk,
    result => dataOutput
  );
end Behavioral;

