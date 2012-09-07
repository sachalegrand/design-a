----------------------------------------------------------------------------------
-- Company: UNSW	
-- Engineer: Sacha Beraud
-- 
-- Create Date:    13:17:28 08/20/2012 
-- Design Name: Weather Station
-- Module Name:    memory - Behavioral 
-- Project Name: COMP3601 - Design Project A
-- Target Devices: Digilient FPGA Nexys Board
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
-- 			Ports
--				address 	
--				data		data bus
--				oe			output enable - to read stuff
--				we			write enable - to write stuff
--				mt_adv	: in std_logic; - keep low
--				mt_clk	: in std_logic; - keep low
--				mt_ub		upper byte - keep low to do stuff
--				mt_lb		lower byte - keep low to do stuff
--				mt_cf		chip enable - keep low to do stuff == CE omg
--				mt_cre	: in std_logic;		-- 
--				mt_wait	: in std_logic			-- keep LOW_Z			



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory is
		Port (
				clk 		: in std_logic;
				reset 	: in std_logic;
				address	: in std_logic_vector (22 downto 0);
				read_enable : in std_logic;
				write_enable : in std_logic;
				data_in			: in std_logic_vector(7 downto 0);
				data_out 		: out std_logic_vector(7 downto 0);
				mem_address 	: out std_logic_vector(22 downto 0);
				mem_data		: inout std_logic_vector (15 downto 0);
				mem_oe			: out std_logic;
				mem_we			: out std_logic;
				mem_adv	: out std_logic;
				mem_clk	: out std_logic;
				mem_ub		: out std_logic;
				mem_lb		: out std_logic;
				mem_ce		: out std_logic;
				mem_cre	: out std_logic;
				mem_wait	: out std_logic						
		);
end memory;

architecture Behavioral of memory is


--	constants

	-- States of the FSM
	constant stMemReady : std_logic_vector(2 downto 0) := "000";
	constant stMemReadA : std_logic_vector(2 downto 0) := "010";
	constant stMemReadB : std_logic_vector(2 downto 0) := "011";
	constant stMemWriteA : std_logic_vector(2 downto 0) := "101";
	constant stMemWriteB : std_logic_vector(2 downto 0) := "100";


-- signals
	-- State machine current and next state register
	signal	stMemCur		: std_logic_vector(2 downto 0) := stMemReady;
	signal	stMemNext	: std_logic_vector(2 downto 0);
	
	-- ram related signals
	signal sram_addr     : std_logic_vector(22 downto 0) := "00000000000000000000000";
	signal sram_data_read  : std_logic_vector(15 downto 0) := "0000000000000000";
	signal sram_data_write : std_logic_vector(15 downto 0) := "0000000000000000";
	signal sram_oe       : std_logic :='1';
	signal sram_we       : std_logic :='1';
	signal sram_adv      : std_logic :='0';
	signal sram_clk      : std_logic :='0';
	signal sram_ub      	: std_logic :='-';
	signal sram_lb      	: std_logic :='-';
	signal sram_ce      	: std_logic :='1';
	signal sram_cre      : std_logic :='0';
	signal sram_wait     : std_logic :='L';

	-- state machine control signals
	signal ctl_read      : std_logic;	--are we in stMemRead?
	signal ctl_write		: std_logic;	--are we in stMemWrite?
	signal ctl_ab			: std_logic;	--are we in stage a or b ? 
	
begin

ctl_read <= stMemCur(1);
ctl_write <= stMemCur(2);
ctl_ab <= stMemCur(0);

process (clk, reset)
begin
	if clk = '1' and clk'event then
		if reset = '1' then
				sram_addr <= "000000000000000000000000";
				sram_data_read <= "0000000000000000";
				sram_data_write <= "0000000000000000";
				sram_oe <= '1';
				sram_we <= '1';
				sram_adv <='0';
				sram_clk <='0';
				sram_ub <='-';
				sram_lb <='-';
				sram_ce <='1';
				sram_cre <='0';
				sram_wait <='L';
				stMemCur <= stMemReady;
		end if;
	end if;
end process;


-- Process gets the FSM from one state to the next every clock cycle
process (clk)
begin
		if clk = '1' and clk'Event then
			stMemCur <= stMemNext;
		end if;
end process;


-- Finite State Machine for reading and writing into memory
--process(stMemCurr, stMemNext, address, read_enable, write_enable, data_in, data_out)
process(stMemCurr, stMemNext, read_enable, write_enable)
begin
	case stMemCurr is 
		when stMemReady =>
			if read_enable = '1' then
				stMemNext <= stMemReadA;
			elsif write_enable = '1' then
				stMemNext <= stMemWriteA;
			else
				stMemNext <= stMemReady;
			end if;
		when stMemReadA =>
			stMemNext <= stMemReadB;
		when stMemReadB =>
			stMemNext <= stMemReady;
		when stMemWriteA =>
			stMemNext <= stMemWriteB;
		when stMemWriteB =>
			stMemNext <= stMemReady;
	end case;
end process;

-- sets the signals back to memory noop values
-- when we're not writing or reading
process(clk, ctl_read, ctl_write)
begin
	if clk'event and clk = '1' then
		if ctl_read = '0' and ctl_write = '0' then
			sram_addr <= "000000000000000000000000";
			sram_data_read <= "0000000000000000";
			sram_data_write <= "0000000000000000";
			sram_oe <= '1';
			sram_we <= '1';
			sram_adv <='0';
			sram_clk <='0';
			sram_ub <='-';
			sram_lb <='-';
			sram_ce <='1';
			sram_cre <='0';
			sram_wait <='L';
		end if;
	end if;
end process;

-- sets the signal for memory read in stages A and B (2 clock cycles required)
process(clk, ctl_read)--, ctl_ab)
begin
	if clk'event and clk = '1' then
		if ctl_read = '1' then
--			if ctl_ab = '0' then
--				
--				
--			elsif ctl_ab = '1' then
--
--						
--			end if;
			sram_addr <= address;
			sram_data_read <= mem_data;
			sram_oe <= '0';
			sram_we <= '1';
			sram_ub <='0';
			sram_lb <='0';
			sram_ce <='0';
		end if;		
	end if;

end process;

-- sets the signal for memory write in stages A and B (2 clock cycles required)
process(clk, ctl_write)--, ctl_ab)
begin
	if clk'event and clk = '1' then
		if ctl_write = '1' then
--			if ctl_ab = '0' then
--				
--				
--			elsif ctl_ab = '1' then
--
--						
--			end if;
			sram_addr <= address;
			mem_data <= sram_data_write;
			sram_oe <= '-';
			sram_we <= '0';
			sram_ub <='0';
			sram_lb <='0';
			sram_ce <='0';
		end if;		
	end if;

end process;
-- signals to input/ouput ports connections


	sram_addr <= mem_address;
	sram_data_read <= data_out;
	sram_data_write <= data_in;
	sram_oe <= mem_oe;
	sram_we <= mem_we;
	sram_adv <= mem_adv;
	sram_clk <= mem_clk;
	sram_ub <= mem_ub;
	sram_lb <= mem_lb;
	sram_ce <= mem_ce;
	sram_cre <= mem_cre;
	sram_wait <= mem_wait;



end Behavioral;













