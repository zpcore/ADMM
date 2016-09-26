--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all; 

package ADMM_pkg is

function ceil(a,b : integer) return integer;
constant N : integer := 2;
constant M : integer := 1;
constant P : integer := 1;
constant Hu : integer := 1;
constant Hp : integer := 1;
constant ADDER_LATENCY : integer := 11;
constant MULTIPLIER_LATENCY : integer := 8;
constant COMPARATOR_LATENCY : integer := 2;
constant COMPLEVEL : integer := 3;
constant TOPBRAMADDR_WIDTH : integer := 11;
constant BOTBRAMADDR_WIDTH : integer := 11;
constant K : integer := 2**COMPLEVEL;--number of BRAMs for Binary tree architecture
constant S1: integer :=(Hp+1)*N+Hu*M;--number of M11 rows
constant S2: integer :=(Hp+1)*N+(2*Hu+1)*M;--number of M11 columns
constant MAX_MATRIX_COLUMN : integer := 7;----maximum columns of the matrix
constant REDUCTION_ADDER : integer := (MAX_MATRIX_COLUMN - 1) / 2**COMPLEVEL;
constant BRAMLOOP: integer :=ceil(S2,K);
constant BRAMEXTRAUSE: integer :=S2 rem K;
constant ReserveBRAM4Vec : integer := 5;--2**ReserveBRAM4Vec for vector store in each BRAM

type Nby32_type is array(0 to N -1) of std_logic_vector(31 downto 0);
type Mby32_type is array(0 to M -1) of std_logic_vector(31 downto 0);
type Kby32_type is array(0 to K -1) of std_logic_vector(31 downto 0);
type Kby0_type is array(0 to K -1) of std_logic_vector(0 downto 0);
type K2by32_type is array(0 to K -1,0 to 1) of std_logic_vector(31 downto 0);
type RouteSig is array (0 to 2**COMPLEVEL-1, 0 to COMPLEVEL) of std_logic_vector(31 downto 0);
type twoby32_type is array (0 to 1) of std_logic_vector(31 downto 0);
type state_type is (idel, BRAM_init, configBox, ConfigTraj);
type EXCEPTION_type is (MergeFIFO_full, ReduceFIFO_full, outPutFIFO_full, sequenceRecord_FIFO_full, LACK_ADDER, NONE);

COMPONENT TOPBRAM
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(TOPBRAMADDR_WIDTH-1 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(TOPBRAMADDR_WIDTH-1 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT BOTBRAM
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(BOTBRAMADDR_WIDTH-1 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(BOTBRAMADDR_WIDTH-1 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT ADD IS
  PORT (
    a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
		isMinus : IN STD_LOGIC;
    result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;

COMPONENT MUL IS
  PORT (
    a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;

COMPONENT CMP IS
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

COMPONENT signal_dly IS
   Generic( LATENCY : integer range 1 to 510);
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           signal_in : in  STD_LOGIC;
           signal_out : out  STD_LOGIC);
END COMPONENT;

COMPONENT mulContainer is
    Port ( clk : in  STD_LOGIC;
           a : in  STD_LOGIC_VECTOR (31 downto 0);
           b : in  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;

COMPONENT addContainer is
    Port ( clk : in  STD_LOGIC;
           a : in  STD_LOGIC_VECTOR (31 downto 0);
           b : in  STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;

COMPONENT FIFO_2PORTs_Merge is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           wr_en : in  STD_LOGIC;
           rd_en : in  STD_LOGIC;
			  full : out STD_LOGIC;
           dina : in  STD_LOGIC_VECTOR (31 downto 0);
           dinb : in  STD_LOGIC_VECTOR (31 downto 0);
           douta : out  STD_LOGIC_VECTOR (31 downto 0);
           doutb : out  STD_LOGIC_VECTOR (31 downto 0));
END COMPONENT;

COMPONENT MVM_FIFO
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT Reduction_Circuit is
	 PORT ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (31 downto 0);
           dout : out  STD_LOGIC_VECTOR (31 downto 0);
           reduce : in  STD_LOGIC;
           READY : in  STD_LOGIC;
           COMPLETE : out  STD_LOGIC;
			  EXCEPTION : out EXCEPTION_type);
END COMPONENT;

COMPONENT FIFO_ReductionOut_temp
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC);
END COMPONENT;

COMPONENT FIFO_finalOutput
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC);
END COMPONENT;

COMPONENT FIFO_sequenceShift
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC);
END COMPONENT;

COMPONENT outputArrangement
	 Port ( clk : in  STD_LOGIC;
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
END COMPONENT;

COMPONENT fifo_vector
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;


end ADMM_pkg;

package body ADMM_pkg is

function ceil(a,b : integer) return integer is
	variable intMod, intRem : integer;
	begin
		intMod:=a / b;
		intRem:=a rem b;
		if(intRem=0)then
			return intMod;
		else
			return intMod+1;
		end if;
end ceil;
---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end ADMM_pkg;
