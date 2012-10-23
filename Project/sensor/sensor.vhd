library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use integer_divider_package.all;
use display_package.all;
use pulse_decoder_package.all;

entity sensor is
	port (clock : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			selectByte : in std_logic;
			selectVar : in std_logic_vector(3 downto 0);
			owdata : inout std_logic;
			humidity : out integer;
			temperature : out integer;
			leds : out std_logic_vector(7 downto 0);
			an : inout std_logic_vector(3 downto 0);
			ca : out std_logic_vector(0 to 7));
end sensor;

architecture Behavioral of sensor is
	
	-- Constants
	constant STANDBY_STATE : integer := 0;
	constant SENDING_STATE : integer := 1;
	constant WAITING_STATE : integer := 2;
	constant PRESENCE_STATE : integer := 3;
	constant PREPARATION_STATE : integer := 4;
	constant PRE_DATA : integer := 5;
	constant DATA_STATE : integer := 6;
	constant POST_DATA : integer := 7;
	constant DONE_STATE : integer := 8;
	
	-- Types
	type stateType is (Standby, Sending, Waiting, Presence, Preparation, PreData, DataState, PostData, Done);
	type integerArray is array (0 to 39) of integer;
	
	-- Signals
	signal currentState, nextState : stateType := Standby;
	signal enableState : integer := STANDBY_STATE;
	signal sendingLength, waitingLength, presenceLength, preparationLength : integer := 0;
	signal dataPulseLengths : integerArray := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	signal dataPulseLengthsValid : std_logic_vector(0 to 39) := "0000000000000000000000000000000000000000";
	signal dataIndex : integer := 0;
	signal humidityBinary : std_logic_vector(15 downto 0) := "0000000000000000";
	signal temperatureBinary : std_logic_vector(15 downto 0) := "0000000000000000";
	signal checksumBinary : std_logic_vector(7 downto 0) := "00000000";
	signal humidityUncaliberated, temperatureUncaliberated, humidityCaliberated, temperatureCaliberated : integer := 0;
	signal dataValid : integer := 0;
	signal actualChecksum, calculatedChecksum, displayValue : integer := 0;
	signal r1, r2 : integer := 0;
	
	begin
	
		humidityUncaliberated <= conv_integer(signed(humidityBinary));
		temperatureUncaliberated <= conv_integer(signed(temperatureBinary));
		
		caliberateHumidity: integer_divider port map (clock, humidityUncaliberated, 10, humidityCaliberated, r1);
		caliberateTemperature: integer_divider port map (clock, temperatureUncaliberated, 10, temperatureCaliberated, r2);	
		
		actualChecksum <= conv_integer(unsigned(checksumBinary));
		calculatedChecksum <= (conv_integer(unsigned(humidityBinary(15 downto 8)))) + 
									 (conv_integer(unsigned(humidityBinary(7 downto 0)))) + 
									 (conv_integer(unsigned(temperatureBinary(15 downto 8)))) + 
									 (conv_integer(unsigned(temperatureBinary(7 downto 0))));
		
		with selectByte select
			displayValue <= humidityCaliberated when '0',
								 temperatureCaliberated when '1',
								 0 when others;
								 
		displayStuff: display port map (clock, displayValue, an, ca);
		
		leds <= "00000000";
		
		humBin15: pulse_decoder port map (dataPulseLengths(0), humidityBinary(15), dataPulseLengthsValid(0));
		humBin14: pulse_decoder port map (dataPulseLengths(1), humidityBinary(14), dataPulseLengthsValid(1));
		humBin13: pulse_decoder port map (dataPulseLengths(2), humidityBinary(13), dataPulseLengthsValid(2));
		humBin12: pulse_decoder port map (dataPulseLengths(3), humidityBinary(12), dataPulseLengthsValid(3));
		humBin11: pulse_decoder port map (dataPulseLengths(4), humidityBinary(11), dataPulseLengthsValid(4));
		humBin10: pulse_decoder port map (dataPulseLengths(5), humidityBinary(10), dataPulseLengthsValid(5));
		humBin09: pulse_decoder port map (dataPulseLengths(6), humidityBinary(9), dataPulseLengthsValid(6));
		humBin08: pulse_decoder port map (dataPulseLengths(7), humidityBinary(8), dataPulseLengthsValid(7));
		humBin07: pulse_decoder port map (dataPulseLengths(8), humidityBinary(7), dataPulseLengthsValid(8));
		humBin06: pulse_decoder port map (dataPulseLengths(9), humidityBinary(6), dataPulseLengthsValid(9));
		humBin05: pulse_decoder port map (dataPulseLengths(10), humidityBinary(5), dataPulseLengthsValid(10));
		humBin04: pulse_decoder port map (dataPulseLengths(11), humidityBinary(4), dataPulseLengthsValid(11));
		humBin03: pulse_decoder port map (dataPulseLengths(12), humidityBinary(3), dataPulseLengthsValid(12));
		humBin02: pulse_decoder port map (dataPulseLengths(13), humidityBinary(2), dataPulseLengthsValid(13));
		humBin01: pulse_decoder port map (dataPulseLengths(14), humidityBinary(1), dataPulseLengthsValid(14));
		humBin00: pulse_decoder port map (dataPulseLengths(15), humidityBinary(0), dataPulseLengthsValid(15));
		
		temBin15: pulse_decoder port map (dataPulseLengths(16), temperatureBinary(15), dataPulseLengthsValid(16));
		temBin14: pulse_decoder port map (dataPulseLengths(17), temperatureBinary(14), dataPulseLengthsValid(17));
		temBin13: pulse_decoder port map (dataPulseLengths(18), temperatureBinary(13), dataPulseLengthsValid(18));
		temBin12: pulse_decoder port map (dataPulseLengths(19), temperatureBinary(12), dataPulseLengthsValid(19));
		temBin11: pulse_decoder port map (dataPulseLengths(20), temperatureBinary(11), dataPulseLengthsValid(20));
		temBin10: pulse_decoder port map (dataPulseLengths(21), temperatureBinary(10), dataPulseLengthsValid(21));
		temBin09: pulse_decoder port map (dataPulseLengths(22), temperatureBinary(9), dataPulseLengthsValid(22));
		temBin08: pulse_decoder port map (dataPulseLengths(23), temperatureBinary(8), dataPulseLengthsValid(23));
		temBin07: pulse_decoder port map (dataPulseLengths(24), temperatureBinary(7), dataPulseLengthsValid(24));
		temBin06: pulse_decoder port map (dataPulseLengths(25), temperatureBinary(6), dataPulseLengthsValid(25));
		temBin05: pulse_decoder port map (dataPulseLengths(26), temperatureBinary(5), dataPulseLengthsValid(26));
		temBin04: pulse_decoder port map (dataPulseLengths(27), temperatureBinary(4), dataPulseLengthsValid(27));
		temBin03: pulse_decoder port map (dataPulseLengths(28), temperatureBinary(3), dataPulseLengthsValid(28));
		temBin02: pulse_decoder port map (dataPulseLengths(29), temperatureBinary(2), dataPulseLengthsValid(29));
		temBin01: pulse_decoder port map (dataPulseLengths(30), temperatureBinary(1), dataPulseLengthsValid(30));
		temBin00: pulse_decoder port map (dataPulseLengths(31), temperatureBinary(0), dataPulseLengthsValid(31));
		
		chkBin7: pulse_decoder port map (dataPulseLengths(32), checksumBinary(7), dataPulseLengthsValid(32));
		chkBin6: pulse_decoder port map (dataPulseLengths(33), checksumBinary(6), dataPulseLengthsValid(33));
		chkBin5: pulse_decoder port map (dataPulseLengths(34), checksumBinary(5), dataPulseLengthsValid(34));
		chkBin4: pulse_decoder port map (dataPulseLengths(35), checksumBinary(4), dataPulseLengthsValid(35));
		chkBin3: pulse_decoder port map (dataPulseLengths(36), checksumBinary(3), dataPulseLengthsValid(36));
		chkBin2: pulse_decoder port map (dataPulseLengths(37), checksumBinary(2), dataPulseLengthsValid(37));
		chkBin1: pulse_decoder port map (dataPulseLengths(38), checksumBinary(1), dataPulseLengthsValid(38));
		chkBin0: pulse_decoder port map (dataPulseLengths(39), checksumBinary(0), dataPulseLengthsValid(39));
		
		process (clock, reset) begin
			if (reset = '1') then
				currentState <= Standby;
				sendingLength <= 0;
				waitingLength <= 0;
				presenceLength <= 0;
				preparationLength <= 0;
				dataPulseLengths <= (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
				dataIndex <= 0;
			elsif (clock'event and clock = '1') then
				currentState <= nextState;
				if (enableState = STANDBY_STATE) then
					--
				elsif (enableState = SENDING_STATE) then
					sendingLength <= sendingLength + 1;
				elsif (enableState = WAITING_STATE) then
					waitingLength <= waitingLength + 1;
				elsif (enableState = PRESENCE_STATE) then
					presenceLength <= presenceLength + 1;
				elsif (enableState = PREPARATION_STATE) then
					preparationLength <= preparationLength + 1;
				elsif (enableState = PRE_DATA) then
					--
				elsif (enableState = DATA_STATE) then
					dataPulseLengths(dataIndex) <= dataPulseLengths(dataIndex) + 1;
				elsif (enableState = POST_DATA) then
					dataIndex <= dataIndex + 1;
				elsif (enableState = DONE_STATE) then
					--
				else
					--
				end if;
			end if;
		end process;
		
		process (owdata, start, sendingLength, dataIndex) begin
			case currentState is
				when Standby =>
					if (start = '1') then nextState <= Sending;
					else nextState <= Standby; end if;
				when Sending =>
					if (sendingLength = 400000) then nextState <= Waiting;
					else nextState <= Sending; end if;
				when Waiting =>
					if (owdata = '0') then nextState <= Presence;
					else nextState <= Waiting; end if;
				when Presence =>
					if (owdata = '1') then nextState <= Preparation;
					else nextState <= Presence; end if;
				when Preparation =>
					if (owdata = '0') then nextState <= PreData;
					else nextState <= Preparation; end if;
				when PreData =>
					if (owdata = '1') then nextState <= DataState;
					else nextState <= PreData; end if;
				when DataState =>
					if (dataIndex > 39) then nextState <= Done;
					else if (owdata = '0') then nextState <= PostData;
						  else nextState <= DataState; end if; end if;
				when PostData =>
					nextState <= PreData;
				when Done =>
					nextState <= Done;
			end case;
		end process;
		
		process (currentState) begin
			if (currentState = Standby) then
				owdata <= 'Z';
				enableState <= STANDBY_STATE;
			elsif (currentState = Sending) then
				owdata <= '0';
				enableState <= SENDING_STATE;
			elsif (currentState = Waiting) then
				owdata <= 'Z';
				enableState <= WAITING_STATE;
			elsif (currentState = Presence) then
				owdata <= 'Z';
				enableState <= PRESENCE_STATE;
			elsif (currentState = Preparation) then
				owdata <= 'Z';
				enableState <= PREPARATION_STATE;
			elsif (currentState = PreData) then
				owdata <= 'Z';
				enableState <= PRE_DATA;
			elsif (currentState = DataState) then
				owdata <= 'Z';
				enableState <= DATA_STATE;
			elsif (currentState = PostData) then
				owdata <= 'Z';
				enableState <= POST_DATA;
			elsif (currentState = Done) then
				owdata <= 'Z';
				enableState <= DONE_STATE;
			else
				owdata <= 'Z';
				enableState <= STANDBY_STATE;
			end if;
		end process;

end Behavioral;






















