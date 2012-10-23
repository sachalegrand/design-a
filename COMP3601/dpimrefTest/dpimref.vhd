----------------------------------------------------------------------------
--	DPIMREF.VHD -- Digilent Parallel Interface Module Reference Design
----------------------------------------------------------------------------
-- Author:  Gene Apperson
--          Copyright 2004 Digilent, Inc.
----------------------------------------------------------------------------
-- IMPORTANT NOTE ABOUT BUILDING THIS LOGIC IN ISE
--
-- Before building the Dpimref logic in ISE:
-- 	1.  	In Project Navigator, right-click on "Synthesize-XST"
--		(in the Process View Tab) and select "Properties"
--	2.	Click the "HDL Options" tab
--	3. 	Set the "FSM Encoding Algorithm" to "None"
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This module contains an example implementation of Digilent Parallel
--	Interface Module logic. This interface is used in conjunction with the
--	DPCUTIL DLL and a Digilent Communications Module (USB, EtherNet, Serial)
--	to exchange data with an application running on a host PC and the logic
--	implemented in a gate array.
--
--	See the Digilent document, Digilent Parallel Interface Model Reference
--	Manual (doc # 560-000) for a description of the interface.
--
--	This design uses a state machine implementation to respond to transfer
--	cycles. It implements an address register, 8 internal data registers
--	that merely hold a value written, and interface registers to communicate
--	with a Digilent DIO4 board. There is an LED output register whose value 
--	drives the 8 discrete leds on the DIO4. There are two input registers.
--	One reads the switches on the DIO4 and the other reads the buttons.
--
--	Interface signals used in top level entity port:
--		mclk		- master clock, generally 50Mhz osc on system board
--		pdb			- port data bus
--		astb		- address strobe
--		dstb		- data strobe
--		pwr			- data direction (described in reference manual as WRITE)
--		pwait		- transfer synchronization (described in reference manual
--						as WAIT)
--		rgSwt		- switch inputs from the DIO4

----------------------------------------------------------------------------
-- Revision History:
--  06/09/2004(GeneA): created
--	08/10/2004(GeneA): initial public release
--	04/25/2006(JoshP): comment addition  
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dpimref is
    Port (
			mclk 	: in std_logic;
			pdb		: inout std_logic_vector(7 downto 0);
			astb 	: in std_logic;
			dstb 	: in std_logic;
			pwr 	: in std_logic;
			pwait 	: out std_logic;
			data_from_mem : in std_logic_vector(15 downto 0);
			addr_to_mem : out std_logic_vector(22 downto 0);
			mem_read_enable : out std_logic;
			mem_done_read : in std_logic;
			stream_mode : out std_logic;
			snap_mode : out std_logic;
			alarm_setup : out std_logic;
			alarm_temp_min_data : out std_logic_vector(15 downto 0);
			alarm_temp_max_data : out std_logic_vector(15 downto 0);
			alarm_hum_min_data : out std_logic_vector(15 downto 0);
			alarm_hum_max_data : out std_logic_vector(15 downto 0);
			--testing signals
			mem_write_enable : in std_logic; 
			mem_fill_counter : in std_logic_vector (7 downto 0);
			rgSwt	: in std_logic_vector(7 downto 0);
			rgLeds : out std_logic_vector(7 downto 0)
			);
end dpimref;

architecture Behavioral of dpimref is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Local Type Declarations
------------------------------------------------------------------------

------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------

	-- The following constants define state codes for the EPP port interface
	-- state machine. The high order bits of the state number give a unique
	-- state identifier. The low order bits are the state machine outputs for
	-- that state. This type of state machine implementation uses no
	-- combination logic to generate outputs which should produce glitch
	-- free outputs.
	constant	stEppReady	: std_logic_vector(7 downto 0) := "0000" & "0000";
	constant	stEppAwrA	: std_logic_vector(7 downto 0) := "0001" & "0100";
	constant	stEppAwrB	: std_logic_vector(7 downto 0) := "0010" & "0001";
	constant	stEppArdA	: std_logic_vector(7 downto 0) := "0011" & "0010";
	constant	stEppArdB	: std_logic_vector(7 downto 0) := "0100" & "0011";
	constant	stEppDwrA	: std_logic_vector(7 downto 0) := "0101" & "1000";
	constant	stEppDwrB	: std_logic_vector(7 downto 0) := "0110" & "0001";
	constant	stEppDrdA	: std_logic_vector(7 downto 0) := "0111" & "0010";
	constant	stEppDrdB	: std_logic_vector(7 downto 0) := "1000" & "0011";


------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------

	-- State machine current state register
	signal	stEppCur	: std_logic_vector(7 downto 0) := stEppReady;

	signal	stEppNext	: std_logic_vector(7 downto 0);

	signal	clkMain		: std_logic;

	-- Internal control signales
	signal	ctlEppWait	: std_logic;
	signal	ctlEppAstb	: std_logic;
	signal	ctlEppDstb	: std_logic;
	signal	ctlEppDir	: std_logic;
	signal	ctlEppWr	: std_logic;
	signal	ctlEppAwr	: std_logic;
	signal	ctlEppDwr	: std_logic;
	signal	busEppOut	: std_logic_vector(7 downto 0);
	signal	busEppIn	: std_logic_vector(7 downto 0);
	signal	busEppData	: std_logic_vector(7 downto 0);

	-- Registers
	signal	regEppAdr	: std_logic_vector(3 downto 0);
	signal	regData0	: std_logic_vector(7 downto 0);
	signal	regData1	: std_logic_vector(7 downto 0);
   signal  	regData2	: std_logic_vector(7 downto 0);
   signal  	regData3	: std_logic_vector(7 downto 0);
   signal  	regData4	: std_logic_vector(7 downto 0);
	signal	regData5	: std_logic_vector(7 downto 0);
	signal	regData6	: std_logic_vector(7 downto 0);
	signal	regData7	: std_logic_vector(7 downto 0);
	
	signal	regDataFromComp0	: std_logic_vector(7 downto 0) := "00000000";
	signal	regDataFromComp1	: std_logic_vector(7 downto 0) := "00000000";
   signal  	regDataFromComp2	: std_logic_vector(7 downto 0) := "00000000";
   signal  	regDataFromComp3	: std_logic_vector(7 downto 0) := "00000000";
   signal  	regDataFromComp4	: std_logic_vector(7 downto 0) := "00000000";
	signal	regDataFromComp5	: std_logic_vector(7 downto 0) := "00000000";
	signal	regDataFromComp6	: std_logic_vector(7 downto 0) := "00000000";
	signal	regDataFromComp7	: std_logic_vector(7 downto 0) := "00000000";

	signal	regDataFromBoard0	: std_logic_vector(7 downto 0) := "00000000";
	signal	regDataFromBoard1	: std_logic_vector(7 downto 0) := "00000000";
   signal  	regDataFromBoard2	: std_logic_vector(7 downto 0) := "00000000";
   signal  	regDataFromBoard3	: std_logic_vector(7 downto 0) := "00000000";
   signal  	regDataFromBoard4	: std_logic_vector(7 downto 0) := "00000000";
	signal	regDataFromBoard5	: std_logic_vector(7 downto 0) := "00000000";
	signal	regDataFromBoard6	: std_logic_vector(7 downto 0) := "00000000";
	signal	regDataFromBoard7	: std_logic_vector(7 downto 0) := "00000000";	

	-- USB protocol various flags
	signal isSnapRequest : std_logic;
	signal isStreamRequest : std_logic;
	signal isAlarmRequest : std_logic;
	signal isCompMaster : std_logic; -- Writing busy flags	
	signal isCompWaitingData : std_logic; -- the computer sets this flag to announce it has received what it wanted

--	signal sig_alarm_temp_min : std_logic_vector(15 downto 0) := "0000000000000000";
--	signal sig_alarm_temp_max : std_logic_vector(15 downto 0) := "0000000000000000";
--	signal sig_alarm_hum_min : std_logic_vector(15 downto 0) := "0000000000000000";
--	signal sig_alarm_hum_max : std_logic_vector(15 downto 0) := "0000000000000000";

--test
	signal sig_alarm_temp_min : std_logic_vector(15 downto 0) := "00010000"&"00000001";
	signal sig_alarm_temp_max : std_logic_vector(15 downto 0) := "00001000"&"00010000";
	signal sig_alarm_hum_min : std_logic_vector(15 downto 0) := "00100000"&"00001000";
	signal sig_alarm_hum_max : std_logic_vector(15 downto 0) := "00010000"&"00010000";
	
	signal isAlStopRequest : std_logic;
	signal isAlSuppRequest : std_logic;
	signal isAlTempMin : std_logic;
	signal isAlTempMax : std_logic;
	signal isAlHumMin : std_logic;
	signal isAlHumMax : std_logic;


	
	-- States of the Memory Reading FSM
	constant stReady : std_logic :='0';
	constant stMemRead : std_logic := '1';

	signal	stCur		: std_logic := stReady;
	signal	stNext	: std_logic;

	-- States of the Alarm Information Receiving Informations
--	constant stAlReady : std_logic_vector(2 downto 0) := "000";
--	constant stAlTempMin : std_logic_vector(2 downto 0) := "001";
--	constant stAlTempMax : std_logic_vector(2 downto 0) := "010";	
--	constant stAlHumMin : std_logic_vector(2 downto 0) := "011";
--	constant stAlHumMax : std_logic_vector(2 downto 0) := "100";	
--	
--	signal	stAlCur		: std_logic_vector(2 downto 0) := stAlReady;
--	signal	stAlNext	: std_logic_vector(2 downto 0);

	signal sig_data_from_mem : std_logic_vector(15 downto 0);
	
	signal sig_mem_read_enable : std_logic;
	
	signal my_addr :std_logic_vector (22 downto 0);
	signal last_mem_addr : std_logic_vector(15 downto 0) := conv_std_logic_vector(65535, 16);
------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin
	
    ------------------------------------------------------------------------
	-- Map basic status and control signals
    ------------------------------------------------------------------------

	clkMain <= mclk;

	ctlEppAstb <= astb;
	ctlEppDstb <= dstb;
	ctlEppWr   <= pwr;
	pwait      <= ctlEppWait;	-- drive WAIT from state machine output


	-- Data bus direction control. The internal input data bus always
	-- gets the port data bus. The port data bus drives the internal
	-- output data bus onto the pins when the interface says we are doing
	-- a read cycle and we are in one of the read cycles states in the
	-- state machine.
	busEppIn <= pdb;
	pdb <= busEppOut when ctlEppWr = '1' and ctlEppDir = '1' else "ZZZZZZZZ";

	-- Select either address or data onto the internal output data bus.
	busEppOut <= "0000" & regEppAdr when ctlEppAstb = '0' else busEppData;

	-- comp or board busy flag
	isCompMaster <= regDataFromComp0(7);
	isCompWaitingData <= regDataFromComp0(5);
	
	isAlarmRequest <= regDataFromComp0(2);
	isAlTempMin <= regDataFromComp1(7);
	isAlTempMax <= regDataFromComp1(6);
	isAlHumMin <= regDataFromComp1(5);
	isAlHumMax <= regDataFromComp1(4);
	
	isStreamRequest <= regDataFromComp0(1);
	isSnapRequest <= regDataFromComp0(0);

	-- Assign regData registers according to comp or board writing to them
	regData0 <= regDataFromComp0 when isCompWaitingData = '0' else
					regDataFromBoard0;
	regData1 <= regDataFromComp1 when isCompWaitingData = '0' else
					regDataFromBoard1;
	regData2 <= regDataFromComp2 when isCompWaitingData = '0' else
					regDataFromBoard2;
	regData3 <= regDataFromComp3 when isCompWaitingData = '0' else
					regDataFromBoard3;
	regData4 <= regDataFromComp4 when isCompWaitingData = '1' else
					regDataFromBoard4;	
	regData5 <= regDataFromComp5 when isCompWaitingData = '1' else
					regDataFromBoard5;
	regData6 <= regDataFromComp6 when isCompWaitingData = '0' else
					regDataFromBoard6;
	regData7 <= regDataFromComp7 when isCompWaitingData = '0' else
					regDataFromBoard7;
					
	-- Decode the address register and select the appropriate data register
	busEppData <=	regData0 when regEppAdr = "0000" else
					regData1 when regEppAdr = "0001" else
					regData2 when regEppAdr = "0010" else
					regData3 when regEppAdr = "0011" else
					regData4 when regEppAdr = "0100" else
					regData5 when regEppAdr = "0101" else
					regData6 when regEppAdr = "0110" else
					regData7 when regEppAdr = "0111" else
					rgSwt    when regEppAdr = "1000" else
					"00000000";

process (clkMain)
begin
		if clkMain = '1' and clkMain'Event then
				stCur <= stNext;
		end if;
end process;


process(stCur, stNext, mem_done_read)
begin
	case stCur is 
		when stReady =>
			stNext <= stMemRead;
		when stMemRead =>
			if mem_done_read = '1' then
				stNext <= stReady;
			else
				stNext <= stMemRead;
			end if;
		when others =>
			stNext <= stReady;
	end case;
end process;


	my_addr <= conv_std_logic_vector(0, 7) & regDataFromComp4 & regDataFromComp5;	
	regDataFromBoard4 <= last_mem_addr(15 downto 8);
	regDataFromBoard5 <= last_mem_addr(7 downto 0);
	sig_data_from_mem <= data_from_mem;


process(clkMain)
begin

	if clkMain'event and clkMain ='1' then
		if stCur = stMemRead then	
--			regDataFromBoard2 <= sig_data_from_mem(15 downto 8);
--			regDataFromBoard3 <= sig_data_from_mem(7 downto 0);
			addr_to_mem <= my_addr;
			sig_mem_read_enable <= '1';
		else 
			sig_mem_read_enable <= '0';
			
		end if;
	end if;

end process;

   ------------------------------------------------------------------------
	-- USB Protocol Implementation Processes
   ------------------------------------------------------------------------
	process (isCompMaster, isCompWaitingData, isAlarmRequest, isAlTempMin, isAlTempMax, isAlHumMin, isAlHumMax)
	begin
		if isCompMaster = '1' then
			if isCompWaitingData = '1' then
				if isAlTempMin = '1' then
					regDataFromBoard2 <= sig_alarm_temp_min(15 downto 8);
					regDataFromBoard3 <= sig_alarm_temp_min(7 downto 0);
				elsif isAlTempMax = '1' then
					regDataFromBoard2 <= sig_alarm_temp_max(15 downto 8);
					regDataFromBoard3 <= sig_alarm_temp_max(7 downto 0);
				elsif isAlHumMin = '1' then
					regDataFromBoard2 <= sig_alarm_hum_min(15 downto 8);
					regDataFromBoard3 <= sig_alarm_hum_min(7 downto 0);
				elsif isAlHumMax = '1' then
					regDataFromBoard2 <= sig_alarm_hum_max(15 downto 8);
					regDataFromBoard3 <= sig_alarm_hum_max(7 downto 0);
				else 
					regDataFromBoard2 <= sig_data_from_mem(15 downto 8);
					regDataFromBoard3 <= sig_data_from_mem(7 downto 0);
				end if;
			else 
				if isAlarmRequest = '1' then
					if isAlTempMin = '1' then
						sig_alarm_temp_min <= regDataFromComp2 & regDataFromComp3;
					elsif isAlTempMax = '1' then
						sig_alarm_temp_max <= regDataFromComp2 & regDataFromComp3;
					elsif isAlHumMin = '1' then
						sig_alarm_hum_min <= regDataFromComp2 & regDataFromComp3;
					elsif isAlHumMax = '1' then
						sig_alarm_hum_max <= regDataFromComp2 & regDataFromComp3;
					end if;
				end if;
			end if;
			isAlStopRequest <= regDataFromComp1(0);
			isAlSuppRequest <= regDataFromComp1(1);
		else
			--sig alarm comes from board alarm
			
			
			
		end if;
	end process;


   ------------------------------------------------------------------------
	-- EPP Interface Control State Machine
   ------------------------------------------------------------------------

	-- Map control signals from the current state
	ctlEppWait <= stEppCur(0);
	ctlEppDir  <= stEppCur(1);
	ctlEppAwr  <= stEppCur(2);
	ctlEppDwr  <= stEppCur(3);

	-- This process moves the state machine to the next state
	-- on each clock cycle
	process (clkMain)
		begin
			if clkMain = '1' and clkMain'Event then
				stEppCur <= stEppNext;
			end if;
		end process;

	-- This process determines the next state machine state based
	-- on the current state and the state machine inputs.
	process (stEppCur, stEppNext, ctlEppAstb, ctlEppDstb, ctlEppWr)
		begin
			case stEppCur is
				-- Idle state waiting for the beginning of an EPP cycle
				when stEppReady =>
					if ctlEppAstb = '0' then
						-- Address read or write cycle
						if ctlEppWr = '0' then
							stEppNext <= stEppAwrA;
						else
							stEppNext <= stEppArdA;
						end if;

					elsif ctlEppDstb = '0' then
						-- Data read or write cycle
						if ctlEppWr = '0' then
							stEppNext <= stEppDwrA;
						else
							stEppNext <= stEppDrdA;
						end if;

					else
						-- Remain in ready state
						stEppNext <= stEppReady;
					end if;											

				-- Write address register
				when stEppAwrA =>
					stEppNext <= stEppAwrB;

				when stEppAwrB =>
					if ctlEppAstb = '0' then
						stEppNext <= stEppAwrB;
					else
						stEppNext <= stEppReady;
					end if;		

				-- Read address register
				when stEppArdA =>
					stEppNext <= stEppArdB;

				when stEppArdB =>
					if ctlEppAstb = '0' then
						stEppNext <= stEppArdB;
					else
						stEppNext <= stEppReady;
					end if;

				-- Write data register
				when stEppDwrA =>
					stEppNext <= stEppDwrB;

				when stEppDwrB =>
					if ctlEppDstb = '0' then
						stEppNext <= stEppDwrB;
					else
 						stEppNext <= stEppReady;
					end if;

				-- Read data register
				when stEppDrdA =>
					stEppNext <= stEppDrdB;
										
				when stEppDrdB =>
					if ctlEppDstb = '0' then
						stEppNext <= stEppDrdB;
					else
				  		stEppNext <= stEppReady;
					end if;

				-- Some unknown state				
				when others =>
					stEppNext <= stEppReady;

			end case;
		end process;
		
    ------------------------------------------------------------------------
	-- EPP Address register
    ------------------------------------------------------------------------

	process (clkMain, ctlEppAwr)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppAwr = '1' then
					regEppAdr <= busEppIn(3 downto 0);
				end if;
			end if;
		end process;

    ------------------------------------------------------------------------
	-- EPP Data registers
    ------------------------------------------------------------------------
 	-- The following processes implement the interface registers. These
	-- registers just hold the value written so that it can be read back.
	-- In a real design, the contents of these registers would drive additional
	-- logic.
	-- The ctlEppDwr signal is an output from the state machine that says
	-- we are in a 'write data register' state. This is combined with the
	-- address in the address register to determine which register to write.

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0000" then
					regDataFromComp0 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0001" then
					regDataFromComp1 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0010" then
					regDataFromComp2 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0011" then
					regDataFromComp3 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0100" then
					regDataFromComp4 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0101" then
					regDataFromComp5 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0110" then
					regDataFromComp6 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0111" then
					regDataFromComp7 <= busEppIn;
				end if;
			end if;
		end process;
	
	-- led testing
	process 
	begin
	case rgSwt is
		when "00000001" => rgLeds <= regData0;
		when "00000010" => rgLeds <= regData1;
		when "00000100" => rgLeds <= regData2;
		when "00001000" => rgLeds <= regData3;
		when "00010000" => rgLeds <= regData4;
		when "00100000" => rgLeds <= regData5;
		when "01000000" => rgLeds <= regData6;
		when "10000000" => rgLeds <= regData7;
		when "11000000" => rgLeds <= sig_alarm_temp_min(15 downto 8);
		when "01100000" => rgLeds <= sig_alarm_temp_min(7 downto 0);
		when "00011000" => rgLeds <= sig_alarm_temp_max(15 downto 8);
		when "00001100" => rgLeds <= sig_alarm_temp_max(7 downto 0);
		when "00000110" => rgLeds <= sig_alarm_hum_min(15 downto 8);
		when "00000011" => rgLeds <= sig_alarm_hum_min(7 downto 0);
		when "10000001" => rgLeds <= sig_alarm_hum_max(15 downto 8);
		when "10000010" => rgLeds <= sig_alarm_hum_max(7 downto 0);
		when others => rgLeds <= sig_mem_read_enable & isCompWaitingData & "000000";
	end case;
	end process;

--rgLeds <= mem_write_enable & sig_data_from_mem (6 downto 0);
--rgLeds <= mem_write_enable & mem_fill_counter (6 downto 0);
--rgLeds <=regDataFromBoard2 ;
--rgLeds <= sig_data_from_mem(7 downto 0);
	mem_read_enable  <= 	sig_mem_read_enable;
	stream_mode <= isStreamRequest;
	snap_mode <= isSnapRequest;
	alarm_setup <= isAlarmRequest;
	alarm_temp_min_data <= sig_alarm_temp_min;
	alarm_temp_max_data <= sig_alarm_temp_max;
	alarm_hum_min_data <= sig_alarm_hum_min;
	alarm_hum_max_data <= sig_alarm_hum_max;

end Behavioral;
