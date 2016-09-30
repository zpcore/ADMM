----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    16:36:37 06/23/2015 
-- Design Name: 
-- Module Name:    outputArrangement - Behavioral 
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

entity outputArrangement is
	 Port ( 
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;		  
		mergeIn_TOP : in  STD_LOGIC_VECTOR (31 downto 0);
		mergeIn_BOT : in  STD_LOGIC_VECTOR (31 downto 0);
		MergeIn_EN : in  STD_LOGIC;----signal that Merge result is ready in the port			  
		reduceIn : in  STD_LOGIC_VECTOR (31 downto 0);
		ReduceIn_EN : in  STD_LOGIC;----signal that Reduction result is ready in the port		  
		FULL : out	STD_LOGIC;
		EMPTY : out  STD_LOGIC; 
		RD_EN : in  STD_LOGIC;
		dataOut : out  STD_LOGIC_VECTOR (31 downto 0);		  
		exception : out EXCEPTION_type);
			  
end outputArrangement;

architecture Behavioral of outputArrangement is
signal Merge_FIFO_out : twoby32_type;
signal exception_occur : std_logic;
signal ss_rd_reg : std_logic;
signal rd_Rt_reg : std_logic;
signal rd_M0_reg : std_logic;
signal rd_M1_reg : std_logic;
signal seq : std_logic_vector(0 downto 0);
signal ss_wr_en : std_logic;
signal ss_rd_en : std_logic;
signal rd_en_Rt : std_logic;
signal rd_en_M : std_logic;
signal wr_en_fo : std_logic;
signal din_fo : std_logic_vector(31 downto 0);
signal dout_ss : std_logic_vector(0 downto 0);
signal full_ss : std_logic;
signal empty_ss : std_logic;
signal full_Rt : std_logic;
signal Merge_FIFO_full : std_logic;
signal dout_Rt : std_logic_vector(31 downto 0);
signal full_fo : std_logic;
signal empty_Rt : std_logic;
signal MergeIn_EN_adjust : std_logic;
begin

sequenceMark : process(clk, rst)
begin
	if(clk' event and clk = '1')then
		if(rst = '1')then
			ss_rd_reg <= '0';
			rd_Rt_reg <= '0';
			rd_M0_reg <= '0';
			rd_M1_reg <= '0';
			exception <= NONE;
		else
			ss_rd_reg <= ss_rd_en;
			rd_Rt_reg <= rd_en_Rt;
			rd_M0_reg <= rd_en_M;
			rd_M1_reg <= rd_M0_reg;			
			if(exception_occur = '1')then
				if(full_ss = '1')then
					exception <= sequenceRecord_FIFO_full;
				elsif(full_Rt = '1')then
					exception <= ReduceFIFO_full;
				elsif(Merge_FIFO_full = '1')then
					exception <= MergeFIFO_full;	
				elsif(full_fo = '1')then
					exception <= outPutFIFO_full;	
				end if;
			end if;
		end if;
	end if;
end process;



seq <= "1" when MergeIn_EN_adjust = '1' else "0"; 
ss_wr_en <= (MergeIn_EN_adjust or ReduceIn_EN);

ss_rd_en <= '0' when (ss_rd_reg = '1' and dout_ss = "1") else
				'1' when (empty_ss = '0')else '0';
						

rd_en_Rt <= '1' when (dout_ss = "0" and ss_rd_reg = '1') else '0';
rd_en_M <= '1' when (dout_ss = "1" and ss_rd_reg = '1') else '0';

wr_en_fo <= '1' when (rd_Rt_reg = '1' or rd_M0_reg = '1' or rd_M1_reg = '1') else '0';
din_fo <= dout_Rt when rd_Rt_reg = '1' else 
          Merge_FIFO_out(0) when rd_M0_reg = '1' else
			 Merge_FIFO_out(1) when rd_M1_reg = '1' else
			 (others => '0');
			 
exception_occur <= '1' when (full_ss = '1' or full_Rt = '1' or Merge_FIFO_full = '1' or full_fo = '1') else '0';
FULL <= full_fo;

Final_Adder_Ready_Output: signal_dly
   Generic map( LATENCY => (ADDER_LATENCY+1)*(REDUCTION_ADDER+1)-1)
	 Port map(clk,rst,MergeIn_EN,MergeIn_EN_adjust);
			 
sequenceShift_model: FIFO_sequenceShift----Distributed RAM FIFO used to record the output sequence in bit format
  PORT MAP (
    clk => clk,
    srst => rst,
    din => seq,
    wr_en => ss_wr_en,
    rd_en => ss_rd_en,
    dout => dout_ss,
    full => full_ss,
    empty => empty_ss
  );

FIFO_ReductionOut_temp_model: MVM_FIFO
  PORT MAP (
    clk => clk,
    srst => rst,
    din => reduceIn,
    wr_en => ReduceIn_EN,
    rd_en => rd_en_Rt,
    dout => dout_Rt,
    full => full_Rt,
    empty => empty_Rt
  );

Merge_FIFO_model: FIFO_2PORTs_Merge 
  Port map( 
    clk  => clk,
    rst => rst,
    wr_en => MergeIn_EN,
    rd_en => rd_en_M,
    full => Merge_FIFO_full,
    dina => mergeIn_TOP,
    dinb => mergeIn_BOT,
    douta => Merge_FIFO_out(0),
    doutb => Merge_FIFO_out(1));
			  
FIFO_finalOutput_model: MVM_FIFO
  PORT MAP (
    clk => clk,
    srst => rst,
    din => din_fo,
    wr_en => wr_en_fo,
    rd_en => RD_EN,
    dout => dataOut,
    full => full_fo,
    empty => EMPTY
  );			  
			  
end Behavioral;

