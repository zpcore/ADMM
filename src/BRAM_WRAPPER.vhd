----------------------------------------------------------------------------------
-- Company: Iowa State University
-- Engineer: Pei Zhang
-- 
-- Create Date: 09/14/2016 08:13:46 PM
-- Design Name: 
-- Module Name: BRAM_WRAPPER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BRAM_WRAPPER is
	Port ( 
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		ConfigSTATE : in state_type;
		NumBRAM : in STD_LOGIC_VECTOR(31 downto 0);
		WEBRAM : in STD_LOGIC;
		MATData : in STD_LOGIC_VECTOR(31 downto 0);
		ADDR : in STD_LOGIC_VECTOR(TOPBRAMADDR_WIDTH-1 downto 0);
		V_IN : in STD_LOGIC_VECTOR (31 downto 0);		
		DATA_RDY : in STD_LOGIC;
		dataInput : out K2by32_type;
		dataOutputRdy : out STD_LOGIC;
		LOOP_DONE : out STD_LOGIC;
		iterationCount : in STD_LOGIC_VECTOR(13 downto 0);
		systemState_rd : out STD_LOGIC;
		START_NEW_LOOP : in STD_LOGIC;--start push matrix and vector to MVM binary tree
		START : in STD_LOGIC;--Finish storing matrix data into BRAM 
		REDUCE : out STD_LOGIC--Reduce signal to MVM binary tree 		
);
end BRAM_WRAPPER;

architecture Behavioral of BRAM_WRAPPER is

type ctrl_type is (idle,wt_start,running,start_output,BRAM_init,vector_wr,state_wr);
signal ps_ctrl : ctrl_type;
signal ns_ctrl : ctrl_type;
signal addrb_wr : std_logic_vector(TOPBRAMADDR_WIDTH-1 downto 0);
signal F_signal : std_logic_vector(31 downto 0);
signal vectorComplete : std_logic;
signal BRAMCount : std_logic_vector(31 downto 0);--11 should be enough
signal vecCount : std_logic_vector(31 downto 0);--11 should be enough
signal wea : Kby0_type;
signal web : Kby0_type;
signal addra : std_logic_vector(TOPBRAMADDR_WIDTH-1 downto 0);
signal addrb : std_logic_vector(TOPBRAMADDR_WIDTH-1 downto 0);
signal addra_output : std_logic_vector(TOPBRAMADDR_WIDTH-1 downto 0);
signal addrb_output : std_logic_vector(TOPBRAMADDR_WIDTH-1 downto 0);
signal output_loopCount : std_logic_vector(31 downto 0);--11 should be enough
signal dataOutput_st : std_logic;
signal systemState_rd_signal : std_logic;
signal systemState_rd_signal_dly : std_logic;
signal output_complete : std_logic;
signal empty : std_logic;
signal full : std_logic;
signal fifo_rd_dly : std_logic;
signal fifo_rd : std_logic;
signal fifo_out : std_logic_vector(31 downto 0);
signal stateWrComplete : std_logic;


--simulation signal
signal dataInput_sim0 : std_logic_vector(31 downto 0);
signal dataInput_sim1 : std_logic_vector(31 downto 0);
signal dataInput_sim2 : std_logic_vector(31 downto 0);
signal dataInput_sim3 : std_logic_vector(31 downto 0);
signal dataInput_sim4 : std_logic_vector(31 downto 0);
signal dataInput_sim5 : std_logic_vector(31 downto 0);
signal dataInput_sim6 : std_logic_vector(31 downto 0);
signal dataInput_sim7 : std_logic_vector(31 downto 0);
signal dataInput_sig : K2by32_type;



begin

dataInput_sim0 <= dataInput_sig(0,0);
dataInput_sim1 <= dataInput_sig(1,0);
dataInput_sim2 <= dataInput_sig(2,0);
dataInput_sim3 <= dataInput_sig(3,0);
dataInput_sim4 <= dataInput_sig(0,1);
dataInput_sim5 <= dataInput_sig(1,1);
dataInput_sim6 <= dataInput_sig(2,1);
dataInput_sim7 <= dataInput_sig(3,1);
dataInput <= dataInput_sig;



state_update : process(clk, rst)
begin
	if(clk = '1' and clk' event)then
		if(rst = '1')then
			ps_ctrl <= idle;
		else
			ps_ctrl <= ns_ctrl;
		end if;
	end if;
end process;

comb_state_update : process(rst, ps_ctrl, vectorComplete, ConfigSTATE, START_NEW_LOOP, START, output_complete, stateWrComplete)
begin
	if(rst= '1')then
		ns_ctrl <= idle;
	else
		ns_ctrl <= ps_ctrl;
		case ps_ctrl is
			when idle =>
				if(ConfigSTATE=BRAM_init)then
					ns_ctrl <= BRAM_init;
				end if;
			when BRAM_init =>
				if(ConfigSTATE=running)then
					ns_ctrl <= wt_start;
				end if;
			when wt_start=>
				if(START_NEW_LOOP='1')then
					ns_ctrl <= start_output;
				end if;
			when start_output =>
				ns_ctrl <= running;
			when running =>
				if(output_complete='1')then
					ns_ctrl <= vector_wr;
				end if;
			when vector_wr =>
				if(vectorComplete = '1')then
					ns_ctrl <= state_wr;
				end if;
			when state_wr =>
				if(stateWrComplete='1')then
					ns_ctrl <= wt_start;
				end if;
			when others =>
		end case;
	end if;
end process;

RemuForever : process(CLK, RST)--without this, programme will die
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			LOOP_DONE <= '0';
		else
			LOOP_DONE <= '0';
			if(stateWrComplete ='1')then
				LOOP_DONE <='1';
			end if;
		end if;
	end if;
end process;

vectoraddress_manage : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			addrb_wr <= (TOPBRAMADDR_WIDTH-1 downto ReserveBRAM4Vec => '1',others => '0');--store vector from this address
			vectorComplete <= '0';
			vecCount <= (others => '0');
			BRAMCount <= (others=>'0');
			systemState_rd_signal <= '0';
			stateWrComplete <= '0';
		else
			if(ps_ctrl=vector_wr)then			
				if(vectorComplete='1')then									
					vectorComplete <= '0';
				else
					if(fifo_rd_dly='1')then
						vecCount <= std_logic_vector(unsigned(vecCount)+1);
						if(unsigned(BRAMCount)=K-1)then
							BRAMCount <= (others=>'0');
							addrb_wr <= std_logic_vector(unsigned(addrb_wr)+1);
						else
							BRAMCount <= std_logic_vector(unsigned(BRAMCount)+1);
						end if;
					end if;
							
					if(unsigned(vecCount)=S2-N)then
						vectorComplete <= '1';
						vecCount <= (others => '0');	
					end if;
				end if;
			elsif(ps_ctrl=state_wr)then
				if(stateWrComplete='1')then
					addrb_wr <= (TOPBRAMADDR_WIDTH-1 downto ReserveBRAM4Vec => '1',others => '0');
					BRAMCount <= (others=>'0');
					stateWrComplete <= '0';
				else
					systemState_rd_signal <= '1';
					vecCount <= std_logic_vector(unsigned(vecCount)+1);
					if(systemState_rd_signal_dly = '1')then
						if(unsigned(BRAMCount)=K-1)then
							BRAMCount <= (others=>'0');
							addrb_wr <= std_logic_vector(unsigned(addrb_wr)+1);
						else
							BRAMCount <= std_logic_vector(unsigned(BRAMCount)+1);
						end if;
					end if;

					if(unsigned(vecCount)=N)then
						systemState_rd_signal <= '0';
						vecCount <= (others => '0');
						stateWrComplete <= '1';				
					end if;
				end if;
			end if;
		end if;
	end if;
end process;



output_manage : process(CLK, RST)
begin
	if(CLK='1' and CLK' event)then
		if(RST='1')then
			output_loopCount<=(others=>'0');
			addra_output <= (others=>'0');
			addrb_output <= (TOPBRAMADDR_WIDTH-1 downto ReserveBRAM4Vec => '1',others => '0');
			REDUCE <= '0';
			dataOutput_st <= '0';
			output_complete <= '0';
		else
			if(ps_ctrl=wt_start)then
				output_loopCount<=(others=>'0');
				addra_output <= (others=>'0');
				addrb_output <= (TOPBRAMADDR_WIDTH-1 downto ReserveBRAM4Vec => '1',others => '0');
				REDUCE <= '0';
			elsif(ps_ctrl=start_output)then
				dataOutput_st <= '1';				
			elsif(ps_ctrl=running)then
				if(output_complete = '1')then
					output_complete <= '0';
					output_loopCount<=(others=>'0');
				else				
					output_loopCount <= std_logic_vector(unsigned(output_loopCount)+1);
					if(unsigned(addra_output)=(S1*BRAMLOOP-1))then--complete output
						dataOutput_st <= '0';
						REDUCE <= '0';
						output_complete <= '1';
					else
						REDUCE <= '1';
						addra_output <= std_logic_vector(unsigned(addra_output)+1);
						addrb_output <= std_logic_vector(unsigned(addrb_output)+1);
						if(unsigned(output_loopCount)=BRAMLOOP-1)then
							addrb_output <= (TOPBRAMADDR_WIDTH-1 downto ReserveBRAM4Vec => '1',others => '0');
							REDUCE <= '0';
							output_loopCount<=(others=>'0');				
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

dataOutputRdy_Delay : signal_dly
    Generic map( LATENCY => 1)
		Port map(CLK,RST,dataOutput_st,dataOutputRdy);

Rdy_Delay : signal_dly
    Generic map( LATENCY => 1)
		Port map(CLK,RST,fifo_rd,fifo_rd_dly);

F_signal_dly : signal_dly
	Generic map( LATENCY => 1)
	Port map(clk,rst,systemState_rd_signal,systemState_rd_signal_dly);	

systemState_rd <= systemState_rd_signal when unsigned(iterationCount)= 0 else '0';

weaHold: for I in 0 to K-1 generate
	wea(I) <= "1" when (WEBRAM = '1' and unsigned(NumBRAM) = I and ConfigSTATE=BRAM_init) else "0";
end generate weaHold;


webHold: for I in 0 to K-1 generate
	web(I) <= "1" when ((fifo_rd_dly = '1' or (systemState_rd_signal_dly ='1' and unsigned(iterationCount)= 0)) and unsigned(BRAMCount) = I) else "0";
end generate webHold;

addra <= ADDR when (ps_ctrl=BRAM_init) else addra_output;
addrb <= addrb_wr when (ps_ctrl=vector_wr) else addrb_output;

fifo_rd <= '1' when (ps_ctrl=vector_wr and empty='0') else '0';
F_signal <= fifo_out when (ps_ctrl=vector_wr) else V_IN;

Gen_MVMBRAM:
for I in 0 to K-1 generate
	UBRAM : TOPBRAM
		PORT MAP (
			clka => CLK,
			wea => wea(I),
			addra => addra,
			dina => MATData,
			douta => dataInput_sig(I,0),
			clkb => CLK,
			web => web(I),
			addrb => addrb,
			dinb => F_signal,
			doutb => dataInput_sig(I,1)
		);
end generate Gen_MVMBRAM;

Ufifo_vector : fifo_vector
	PORT MAP (
		clk => CLK,
		srst => RST,
		din => V_IN,
		wr_en => DATA_RDY,
		rd_en => fifo_rd,
		dout => fifo_out,
		full => full,
		empty => empty
		);


end Behavioral;
