----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    15:38:54 06/22/2015 
-- Design Name: 
-- Module Name:    Parallel_Processing - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: ISE 14.6
-- Description: 
--  					Design for single precision floating point
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library ADMM_lib;
use ADMM_lib.ADMM_pkg.all;

entity Parallel_Processing is
  Port ( clk : in  STD_LOGIC;
         rst : in  STD_LOGIC;
         merge : in STD_LOGIC;
         reduce : in STD_LOGIC;
         READY : in STD_LOGIC;
         dataInput : in  K2by32_type;
         resOut : out  STD_LOGIC_VECTOR (31 downto 0);
         RD_Out : in STD_LOGIC;
         DONE : out STD_LOGIC;
         exception : out exception_type);
end Parallel_Processing;

architecture Behavioral of Parallel_Processing is

signal mulRes : Kby32_type;
signal RS : RouteSig;
signal mulIn : K2by32_type;

signal rd_en : std_logic;
signal wr_en : std_logic;
signal Merge_FIFO_full : std_logic;
signal reductionOut : std_logic_vector(31 downto 0);
signal pre_finishReduce : std_logic;
signal FULL : std_logic;
signal EMPTY : std_logic;
signal ReduceIn_EN : std_logic;
signal exception_DataStorage : EXCEPTION_type;
signal exception_Reduction_Circuit : EXCEPTION_type;
signal merge_READY : std_logic;
signal reduce_READY : std_logic;
signal nr_READY : std_logic;
signal Final_Adder_Ready : std_logic;
signal merge_delay : std_logic;
signal MergeOutput_delay : std_logic;

begin

inputHold : for I in 0 to K-1 generate
	mulIn(I,0) <= dataInput(I,0) when READY = '1' else (others => '0');
	mulIn(I,1) <= dataInput(I,1) when READY = '1' else (others => '0');
end generate inputHold;

merge_READY <= READY when merge = '1' else '0';
reduce_READY <= READY when reduce = '1' else '0';
nr_READY <= READY when (merge = '0')else '0';


wr_en <= '0' when rst = '1' else
			'1' when merge_delay = '1' else '0';
rd_en <= '0' when rst = '1' else
			'1' when MergeOutput_delay = '1' else '0';

DONE <= not EMPTY;

exception <=  	exception_DataStorage when (exception_Reduction_Circuit = NONE)else
					exception_Reduction_Circuit;

Gen_mulModel:
for I in 0 to K-1 generate
	mulModel : mulContainer
	port map(
		clk 			=> clk,
		a				=> mulIn(I,0),
		b				=> mulIn(I,1),
		result      => RS(I,0)--mulRes(I)		
	);
end generate Gen_mulModel;

Gen_addModel:
for I in 0 to COMPLEVEL-1 generate	
	inner_level:
	for II in 0 to 2**(COMPLEVEL-I-1)-1 generate
		addModel : addContainer
		port map(
			clk 			=> clk,
			a				=> RS(2*II,I),
			b				=> RS(2*II+1,I),
			result      => RS(II,I+1)		
		);	
	end generate inner_level;
end generate Gen_addModel;

	 
MergeSig_Delay : signal_dly
    Generic map( LATENCY => MULTIPLIER_LATENCY+(COMPLEVEL-1)*ADDER_LATENCY)
	 Port map(clk,rst,merge_READY,merge_delay);

Adder_Delay : signal_dly
    Generic map( LATENCY => ADDER_LATENCY-1)
	 Port map(clk,rst,merge_delay,MergeOutput_delay);
	 
Reduce_Delay : signal_dly
    Generic map( LATENCY => MULTIPLIER_LATENCY+COMPLEVEL*ADDER_LATENCY)
	 Port map(clk,rst,reduce_READY,pre_finishReduce);
	 
--Final_Adder_Ready_Output : signal_dly
--    Generic map( LATENCY => MULTIPLIER_LATENCY+COMPLEVEL*ADDER_LATENCY +1)
--	 Port map(clk,rst,READY,Final_Adder_Ready);	 

Final_Adder_Ready_Output : signal_dly
    Generic map( LATENCY => MULTIPLIER_LATENCY+COMPLEVEL*ADDER_LATENCY)
	 Port map(clk,rst,nr_READY,Final_Adder_Ready);	


Arrangement_model : outputArrangement
	 Port Map( clk 				=>	clk,
           rst 					=>	rst,
           mergeIn_TOP			=>	RS(0,COMPLEVEL-1),
           mergeIn_BOT 			=>	RS(1,COMPLEVEL-1),
           MergeIn_EN 			=> wr_en,
           reduceIn				=>	reductionOut,
           ReduceIn_EN 			=>	ReduceIn_EN,
					 FULL					=>	FULL,
           EMPTY 					=>	EMPTY,
           RD_EN		 			=>	RD_Out,
           dataOut 				=>	resOut,
					 exception 			=> exception_DataStorage);
		  			  
Reduction_Circuit_Model : Reduction_Circuit
	Port Map(
				clk 					=> clk,
				rst 					=> rst,
				din 					=> RS(0,COMPLEVEL),
				dout 					=>	reductionOut,
				reduce 				=> pre_finishReduce,
				READY 				=> Final_Adder_Ready,
				COMPLETE 			=> ReduceIn_EN,
				EXCEPTION 			=> exception_Reduction_Circuit
				);
		  
end Behavioral;

