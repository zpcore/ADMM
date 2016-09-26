library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity add is
  PORT(
    a : in std_logic_vector(31 downto 0);
    b : in std_logic_vector(31 downto 0);
    clk : in std_logic;
		isMinus : in std_logic;
    result : out std_logic_vector(31 downto 0)
  );
end add;

architecture Behavioral of add is
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
signal s_axis_operation_tdata: std_logic_vector(7 downto 0); 
signal m_axis_result_tvalid: std_logic;

begin

s_axis_operation_tdata <= (0=>isMinus, others=>'0');

uadd_fp : add_fp
  PORT MAP (
    aclk => clk,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => a,
    s_axis_b_tvalid => '1',
    s_axis_b_tdata => b,
    s_axis_operation_tvalid => '1',
    s_axis_operation_tdata => s_axis_operation_tdata,
    m_axis_result_tvalid => m_axis_result_tvalid,
    m_axis_result_tdata => result
  );

end Behavioral;
