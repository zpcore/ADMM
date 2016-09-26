----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    22:05:41 06/22/2015 
-- Design Name: 
-- Module Name:    Reduction_Circuit - Behavioral 
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

entity Reduction_Circuit is
	Port (
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		din : in  STD_LOGIC_VECTOR (31 downto 0);
		dout : out  STD_LOGIC_VECTOR (31 downto 0);
		reduce : in  STD_LOGIC;
		READY : in  STD_LOGIC;
		COMPLETE : out  STD_LOGIC;
		EXCEPTION : out EXCEPTION_type);
end Reduction_Circuit;

architecture Behavioral of Reduction_Circuit is

COMPONENT Mini_Reduction is
	Port ( 
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		reduce_pre : in  STD_LOGIC;
		READY : in  STD_LOGIC;
		reduce_pos : out  STD_LOGIC;----connect to the reduce_pre port of next Mini_Reduction
		dataInput : in  STD_LOGIC_VECTOR (31 downto 0);
		dataOutput : out  STD_LOGIC_VECTOR (31 downto 0);
		DONE : out  STD_LOGIC;----connect to the READY port of next Mini_Reduction
		FINISH : out STD_LOGIC----means the accumulation is complete, needn't to use if we collect result in the last Mini_Reduction component
		);
END COMPONENT;

type RAdd_type is array(0 to 1, 0 to REDUCTION_ADDER)of std_logic_vector(31 downto 0);
signal RAdd : RAdd_type;
type Rec_Recduction_type is array(0 to REDUCTION_ADDER)of std_logic;
signal DONE : Rec_Recduction_type;
signal reduce_pre : Rec_Recduction_type;
type RRes_type is array(0 to REDUCTION_ADDER)of std_logic_vector(31 downto 0);
signal RRes : RRes_type;

begin

exceptionHandle : process(clk, rst)
begin
	if(clk' event and clk = '1')then
		if(rst = '1')then
			EXCEPTION <= NONE;
		else
			if(reduce_pre(REDUCTION_ADDER) = '1')then
				EXCEPTION <= LACK_ADDER;
			end if;
		end if;
	end if;
end process;



DONE(0) <= READY;
COMPLETE <= DONE(REDUCTION_ADDER);
RRes(0) <= din;
dout <= RRes(REDUCTION_ADDER);
reduce_pre(0) <= reduce;

--EXCEPTION <= LACK_ADDER when reduce_pre(REDUCTION_ADDER) = '1' else NONE;

Gen_Mini_Reduction:
for I in 0 to REDUCTION_ADDER-1 generate	
Mini_Reduction_Model : Mini_Reduction
	Port map( 
					clk			=> clk, 
					rst 			=> rst,	
					reduce_pre  =>	reduce_pre(I),
					READY     	=>	DONE(I),
					reduce_pos 	=>	reduce_pre(I+1),
					dataInput 	=> RRes(I),
					dataOutput 	=> RRes(I+1),
					DONE     	=> DONE(I+1)
			  );
end generate Gen_Mini_Reduction;

end Behavioral;

