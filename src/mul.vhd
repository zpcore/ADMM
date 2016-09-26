library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mul is
  PORT(
    a : in std_logic_vector(31 downto 0);
    b : in std_logic_vector(31 downto 0);
    clk : in std_logic;
    result : out std_logic_vector(31 downto 0)
  );
end mul;

architecture Behavioral of mul is
COMPONENT mul_fp
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
signal m_axis_result_tvalid : std_logic;

begin

umul_fp : mul_fp
  PORT MAP (
    aclk => clk,
    s_axis_a_tvalid => '1',
    s_axis_a_tdata => a,
    s_axis_b_tvalid => '1',
    s_axis_b_tdata => b,
    m_axis_result_tvalid => m_axis_result_tvalid,
    m_axis_result_tdata => result
  );

end Behavioral;
