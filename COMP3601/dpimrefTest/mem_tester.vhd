----------------------------------------------------------------------------------
-- Company: UNSW
-- Engineer: Sacha Beraud
-- 
-- Create Date:    20:22:50 08/27/2012 
-- Design Name: 
-- Module Name:    mem_tester - Behavioral 
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

entity mem_tester is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           data_to_mem : out  STD_LOGIC_VECTOR (15 downto 0);
           addr_to_mem : out  STD_LOGIC_VECTOR (22 downto 0);
           data_to_leds : out  STD_LOGIC_VECTOR (7 downto 0);
           data_from_mem : in  STD_LOGIC_VECTOR (15 downto 0);
			  mem_read_enable : out std_logic;
			  mem_write_enable : out std_logic;
           mem_busy : in  STD_LOGIC);
end mem_tester;

architecture Behavioral of mem_tester is

-- States of the FSM
	constant stReady : std_logic_vector(1 downto 0) := "00";
	constant stMemWrite : std_logic_vector(1 downto 0) := "01";
	constant stMemRead : std_logic_vector(1 downto 0) := "10";
	constant stFinished : std_logic_vector(1 downto 0) := "11";


-- signals
	-- State machine current and next state register
	signal	stCur		: std_logic_vector(1 downto 0) := stReady;
	signal	stNext	: std_logic_vector(1 downto 0);



--signal my_job_is_done_baby : std_logic := '0';
signal my_data : std_logic_vector(15 downto 0) := "00000000" & "10101010";
signal my_addr : std_logic_vector(22 downto 0) := "00000000000000000000100";
signal my_data_to_leds : std_logic_vector(15 downto 0) := "0000000000000000";

begin

-- Process gets the FSM from one state to the next every clock cycle
process (clk, reset)
begin
		if clk = '1' and clk'Event then
			if reset = '1' then
				stCur <= stReady;
			else
				stCur <= stNext;
			end if;
		end if;
end process;

process(stCur, stNext, mem_busy)
begin
	case stCur is 
		when stReady =>
			stNext <= stMemWrite;
		when stMemWrite =>
			if mem_busy = '1' then
				stNext <= stMemWrite;
			else
				stNext <= stMemRead;
			end if;
		when stMemRead =>
			if mem_busy = '1' then
				stNext <= stMemRead;
			else
				stNext <= stFinished;
			end if;
		when others =>
			stNext <= stReady;
	end case;
end process;

process(clk,reset)
begin

	if clk'event and clk ='1' then
		if reset = '1' then
			my_data_to_leds <= "0000000000000000";
		else
			if stCur = stMemWrite then
				data_to_mem <= my_data;
				addr_to_mem <= my_addr;
				mem_write_enable <= '1';
			elsif stCur = stMemRead then
				my_data_to_leds <= data_from_mem;
				addr_to_mem <= my_addr;
				mem_read_enable <= '1';				
			end if;	
		end if;
	end if;

end process;

data_to_leds <= my_data_to_leds(7 downto 0);

end Behavioral;

