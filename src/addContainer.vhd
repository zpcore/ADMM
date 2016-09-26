----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date:    16:17:08 06/22/2015 
-- Design Name: 
-- Module Name:    addContainer - Behavioral 
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

entity addContainer is
    Port ( clk : in  STD_LOGIC;
           a : in  STD_LOGIC_VECTOR (31 downto 0);
           b : in  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
end addContainer;

architecture Behavioral of addContainer is
COMPONENT add_fp
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_operation_tvalid : IN STD_LOGIC;
    s_axis_operation_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT; 
signal m_axis_result_tvalid: std_logic;

begin

uadd_fp : add_fp
  PORT MAP (
    aclk => clk,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => a,
    s_axis_b_tvalid => '1',
    s_axis_b_tdata => b,
    s_axis_operation_tvalid => '1',
    s_axis_operation_tdata => "00000000",
    m_axis_result_tvalid => m_axis_result_tvalid,
    m_axis_result_tdata => result
  );

end Behavioral;

