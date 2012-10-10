library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.PulseLengthDecoderPackage.all;

entity sensor is
	port (clock : in std_logic; -- 1 clock cycle = 20ns
			reset : in std_logic;
			selByte : in std_logic;
			selPulse : in std_logic_vector(3 downto 0);
			data : inout std_logic;
			leds : out std_logic_vector(7 downto 0));
end sensor;

architecture behaviour of sensor is

	type stateType is (Standby, Sending, Waiting, Presence, Preparation, Sleep, SleepIndexState, DataState, DataIndexState, Done);
	type pulseLengthsArray is array (1 to 40) of integer;

	signal currentState, nextState : stateType := Standby;

	signal dataPulseLengths : pulseLengthsArray := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	signal sleepPulseLengths : pulseLengthsArray := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	
	signal standbyCounter, sendingCounter, dataIndexCounter, sleepIndexCounter, doneCounter : integer := 0;
	signal waitingLength, presenceLength, preparationLength : integer := 0;

	signal enState : std_logic_vector(1 to 10) := "0000000000";

	signal dataIndex : integer := 1;
	signal sleepIndex : integer := 1;

	signal humidity : std_logic_vector(15 downto 0) := "0000000000000000";
	signal humidityValid : std_logic_vector(15 downto 0) := "0000000000000000";
	signal temperature : std_logic_vector(15 downto 0) := "0000000000000000";
	signal temperatureValid : std_logic_vector(15 downto 0) := "0000000000000000";
	signal checksum : std_logic_vector(7 downto 0) := "00000000";
	signal checksumValid : std_logic_vector(7 downto 0) := "00000000";
	
	signal dataIn : std_logic := 'Z';
	
	signal actualChecksum, calculatedChecksum : std_logic_vector(7 downto 0) := "00000000";
	
	signal tem1, tem0, hum1, hum0 : integer := 0;

	begin
		
		-- humidity
		hum_bit15: PulseLengthDecoder port map (dataPulseLengths(1), humidity(15), humidityValid(15));
		hum_bit14: PulseLengthDecoder port map (dataPulseLengths(2), humidity(14), humidityValid(14));
		hum_bit13: PulseLengthDecoder port map (dataPulseLengths(3), humidity(13), humidityValid(13));
		hum_bit12: PulseLengthDecoder port map (dataPulseLengths(4), humidity(12), humidityValid(12));
		hum_bit11: PulseLengthDecoder port map (dataPulseLengths(5), humidity(11), humidityValid(11));
		hum_bit10: PulseLengthDecoder port map (dataPulseLengths(6), humidity(10), humidityValid(10));
		hum_bit09: PulseLengthDecoder port map (dataPulseLengths(7), humidity(9), humidityValid(9));
		hum_bit08: PulseLengthDecoder port map (dataPulseLengths(8), humidity(8), humidityValid(8));
		hum_bit07: PulseLengthDecoder port map (dataPulseLengths(9), humidity(7), humidityValid(7));
		hum_bit06: PulseLengthDecoder port map (dataPulseLengths(10), humidity(6), humidityValid(6));
		hum_bit05: PulseLengthDecoder port map (dataPulseLengths(11), humidity(5), humidityValid(5));
		hum_bit04: PulseLengthDecoder port map (dataPulseLengths(12), humidity(4), humidityValid(4));
		hum_bit03: PulseLengthDecoder port map (dataPulseLengths(13), humidity(3), humidityValid(3));
		hum_bit02: PulseLengthDecoder port map (dataPulseLengths(14), humidity(2), humidityValid(2));
		hum_bit01: PulseLengthDecoder port map (dataPulseLengths(15), humidity(1), humidityValid(1));
		hum_bit00: PulseLengthDecoder port map (dataPulseLengths(16), humidity(0), humidityValid(0));
		
		-- temperature
		temp_bit15: PulseLengthDecoder port map (dataPulseLengths(17), temperature(15), temperatureValid(15));
		temp_bit14: PulseLengthDecoder port map (dataPulseLengths(18), temperature(14), temperatureValid(14));
		temp_bit13: PulseLengthDecoder port map (dataPulseLengths(19), temperature(13), temperatureValid(13));
		temp_bit12: PulseLengthDecoder port map (dataPulseLengths(20), temperature(12), temperatureValid(12));
		temp_bit11: PulseLengthDecoder port map (dataPulseLengths(21), temperature(11), temperatureValid(11));
		temp_bit10: PulseLengthDecoder port map (dataPulseLengths(22), temperature(10), temperatureValid(10));
		temp_bit09: PulseLengthDecoder port map (dataPulseLengths(23), temperature(9), temperatureValid(9));
		temp_bit08: PulseLengthDecoder port map (dataPulseLengths(24), temperature(8), temperatureValid(8));
		temp_bit07: PulseLengthDecoder port map (dataPulseLengths(25), temperature(7), temperatureValid(7));
		temp_bit06: PulseLengthDecoder port map (dataPulseLengths(26), temperature(6), temperatureValid(6));
		temp_bit05: PulseLengthDecoder port map (dataPulseLengths(27), temperature(5), temperatureValid(5));
		temp_bit04: PulseLengthDecoder port map (dataPulseLengths(28), temperature(4), temperatureValid(4));
		temp_bit03: PulseLengthDecoder port map (dataPulseLengths(29), temperature(3), temperatureValid(3));
		temp_bit02: PulseLengthDecoder port map (dataPulseLengths(30), temperature(2), temperatureValid(2));
		temp_bit01: PulseLengthDecoder port map (dataPulseLengths(31), temperature(1), temperatureValid(1));
		temp_bit00: PulseLengthDecoder port map (dataPulseLengths(32), temperature(0), temperatureValid(0));
		
		-- checksum
		chk_bit07: PulseLengthDecoder port map (dataPulseLengths(33), checksum(7), checksumValid(7));
		chk_bit06: PulseLengthDecoder port map (dataPulseLengths(34), checksum(6), checksumValid(6));
		chk_bit05: PulseLengthDecoder port map (dataPulseLengths(35), checksum(5), checksumValid(5));
		chk_bit04: PulseLengthDecoder port map (dataPulseLengths(36), checksum(4), checksumValid(4));
		chk_bit03: PulseLengthDecoder port map (dataPulseLengths(37), checksum(3), checksumValid(3));
		chk_bit02: PulseLengthDecoder port map (dataPulseLengths(38), checksum(2), checksumValid(2));
		chk_bit01: PulseLengthDecoder port map (dataPulseLengths(39), checksum(1), checksumValid(1));
		chk_bit00: PulseLengthDecoder port map (dataPulseLengths(40), checksum(0), checksumValid(0));
		
		actualChecksum <= checksum;
		
		hum1 <= to_integer(unsigned(humidity(15 downto 8)));
		hum0 <= to_integer(unsigned(humidity(7 downto 0)));
		tem1 <= to_integer(unsigned(temperature(15 downto 8)));
		tem0 <= to_integer(unsigned(temperature(7 downto 0)));
		
		calculatedChecksum <= conv_std_logic_vector((hum1 + hum0 + tem1 + tem0), 8);
		
		with selByte select
			leds <= actualChecksum when '1',
					  calculatedChecksum when '0',
					  "00000000" when others;

		-- leds <= checksumValid(7 downto 0);

		process (clock, reset) begin
			if (reset = '1') then
				currentState <= Standby;
				standbyCounter <= 0;
				sendingCounter <= 0;
				waitingLength <= 0;
				presenceLength <= 0;
				preparationLength <= 0;
				sleepPulseLengths <= (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
				sleepIndexCounter <= 0;
				dataPulseLengths <= (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
				dataIndexCounter <= 0;
				doneCounter <= 0;
			elsif (clock'event and clock = '1') then
				currentState <= nextState;
				dataIn <= data;
				if (enState = "1000000000") then
					standbyCounter <= standbyCounter + 1;
				elsif (enState = "0100000000") then
					sendingCounter <= sendingCounter + 1;
				elsif (enState = "0010000000") then
					waitingLength <= waitingLength + 1;
				elsif (enState = "0001000000") then
					presenceLength <= presenceLength + 1;
				elsif (enState = "0000100000") then
					preparationLength <= preparationLength + 1;
				elsif (enState = "0000010000") then
					if (sleepIndex = 1) then
						sleepPulseLengths(1) <= sleepPulseLengths(1) + 1;
					elsif (sleepIndex = 2) then
						sleepPulseLengths(2) <= sleepPulseLengths(2) + 1;
					elsif (sleepIndex = 3) then
						sleepPulseLengths(3) <= sleepPulseLengths(3) + 1;
					elsif (sleepIndex = 4) then
						sleepPulseLengths(4) <= sleepPulseLengths(4) + 1;
					elsif (sleepIndex = 5) then
						sleepPulseLengths(5) <= sleepPulseLengths(5) + 1;
					elsif (sleepIndex = 6) then
						sleepPulseLengths(6) <= sleepPulseLengths(6) + 1;
					elsif (sleepIndex = 7) then
						sleepPulseLengths(7) <= sleepPulseLengths(7) + 1;
					elsif (sleepIndex = 8) then
						sleepPulseLengths(8) <= sleepPulseLengths(8) + 1;
					elsif (sleepIndex = 9) then
						sleepPulseLengths(9) <= sleepPulseLengths(9) + 1;
					elsif (sleepIndex = 10) then
						sleepPulseLengths(10) <= sleepPulseLengths(10) + 1;
					elsif (sleepIndex = 11) then
						sleepPulseLengths(11) <= sleepPulseLengths(11) + 1;
					elsif (sleepIndex = 12) then
						sleepPulseLengths(12) <= sleepPulseLengths(12) + 1;
					elsif (sleepIndex = 13) then
						sleepPulseLengths(13) <= sleepPulseLengths(13) + 1;
					elsif (sleepIndex = 14) then
						sleepPulseLengths(14) <= sleepPulseLengths(14) + 1;
					elsif (sleepIndex = 15) then
						sleepPulseLengths(15) <= sleepPulseLengths(15) + 1;
					elsif (sleepIndex = 16) then
						sleepPulseLengths(16) <= sleepPulseLengths(16) + 1;
					elsif (sleepIndex = 17) then
						sleepPulseLengths(17) <= sleepPulseLengths(17) + 1;
					elsif (sleepIndex = 18) then
						sleepPulseLengths(18) <= sleepPulseLengths(18) + 1;
					elsif (sleepIndex = 19) then
						sleepPulseLengths(19) <= sleepPulseLengths(19) + 1;
					elsif (sleepIndex = 20) then
						sleepPulseLengths(20) <= sleepPulseLengths(20) + 1;
					elsif (sleepIndex = 21) then
						sleepPulseLengths(21) <= sleepPulseLengths(21) + 1;
					elsif (sleepIndex = 22) then
						sleepPulseLengths(22) <= sleepPulseLengths(22) + 1;
					elsif (sleepIndex = 23) then
						sleepPulseLengths(23) <= sleepPulseLengths(23) + 1;
					elsif (sleepIndex = 24) then
						sleepPulseLengths(24) <= sleepPulseLengths(24) + 1;
					elsif (sleepIndex = 25) then
						sleepPulseLengths(25) <= sleepPulseLengths(25) + 1;
					elsif (sleepIndex = 26) then
						sleepPulseLengths(26) <= sleepPulseLengths(26) + 1;
					elsif (sleepIndex = 27) then
						sleepPulseLengths(27) <= sleepPulseLengths(27) + 1;
					elsif (sleepIndex = 28) then
						sleepPulseLengths(28) <= sleepPulseLengths(28) + 1;
					elsif (sleepIndex = 29) then
						sleepPulseLengths(29) <= sleepPulseLengths(29) + 1;
					elsif (sleepIndex = 30) then
						sleepPulseLengths(30) <= sleepPulseLengths(30) + 1;
					elsif (sleepIndex = 31) then
						sleepPulseLengths(31) <= sleepPulseLengths(31) + 1;
					elsif (sleepIndex = 32) then
						sleepPulseLengths(32) <= sleepPulseLengths(32) + 1;
					elsif (sleepIndex = 33) then
						sleepPulseLengths(33) <= sleepPulseLengths(33) + 1;
					elsif (sleepIndex = 34) then
						sleepPulseLengths(34) <= sleepPulseLengths(34) + 1;
					elsif (sleepIndex = 35) then
						sleepPulseLengths(35) <= sleepPulseLengths(35) + 1;
					elsif (sleepIndex = 36) then
						sleepPulseLengths(36) <= sleepPulseLengths(36) + 1;
					elsif (sleepIndex = 37) then
						sleepPulseLengths(37) <= sleepPulseLengths(37) + 1;
					elsif (sleepIndex = 38) then
						sleepPulseLengths(38) <= sleepPulseLengths(38) + 1;
					elsif (sleepIndex = 39) then
						sleepPulseLengths(39) <= sleepPulseLengths(39) + 1;
					elsif (sleepIndex = 40) then
						sleepPulseLengths(40) <= sleepPulseLengths(40) + 1;
					end if;
					sleepIndexCounter <= 0;
				elsif (enState = "0000001000") then
					sleepIndex <= sleepIndex + 1;
					sleepIndexCounter <= sleepIndexCounter + 1;
				elsif (enState = "0000000100") then
					if (dataIndex = 1) then
						dataPulseLengths(1) <= dataPulseLengths(1) + 1;
					elsif (dataIndex = 2) then
						dataPulseLengths(2) <= dataPulseLengths(2) + 1;
					elsif (dataIndex = 3) then
						dataPulseLengths(3) <= dataPulseLengths(3) + 1;
					elsif (dataIndex = 4) then
						dataPulseLengths(4) <= dataPulseLengths(4) + 1;
					elsif (dataIndex = 5) then
						dataPulseLengths(5) <= dataPulseLengths(5) + 1;
					elsif (dataIndex = 6) then
						dataPulseLengths(6) <= dataPulseLengths(6) + 1;
					elsif (dataIndex = 7) then
						dataPulseLengths(7) <= dataPulseLengths(7) + 1;
					elsif (dataIndex = 8) then
						dataPulseLengths(8) <= dataPulseLengths(8) + 1;
					elsif (dataIndex = 9) then
						dataPulseLengths(9) <= dataPulseLengths(9) + 1;
					elsif (dataIndex = 10) then
						dataPulseLengths(10) <= dataPulseLengths(10) + 1;
					elsif (dataIndex = 11) then
						dataPulseLengths(11) <= dataPulseLengths(11) + 1;
					elsif (dataIndex = 12) then
						dataPulseLengths(12) <= dataPulseLengths(12) + 1;
					elsif (dataIndex = 13) then
						dataPulseLengths(13) <= dataPulseLengths(13) + 1;
					elsif (dataIndex = 14) then
						dataPulseLengths(14) <= dataPulseLengths(14) + 1;
					elsif (dataIndex = 15) then
						dataPulseLengths(15) <= dataPulseLengths(15) + 1;
					elsif (dataIndex = 16) then
						dataPulseLengths(16) <= dataPulseLengths(16) + 1;
					elsif (dataIndex = 17) then
						dataPulseLengths(17) <= dataPulseLengths(17) + 1;
					elsif (dataIndex = 18) then
						dataPulseLengths(18) <= dataPulseLengths(18) + 1;
					elsif (dataIndex = 19) then
						dataPulseLengths(19) <= dataPulseLengths(19) + 1;
					elsif (dataIndex = 20) then
						dataPulseLengths(20) <= dataPulseLengths(20) + 1;
					elsif (dataIndex = 21) then
						dataPulseLengths(21) <= dataPulseLengths(21) + 1;
					elsif (dataIndex = 22) then
						dataPulseLengths(22) <= dataPulseLengths(22) + 1;
					elsif (dataIndex = 23) then
						dataPulseLengths(23) <= dataPulseLengths(23) + 1;
					elsif (dataIndex = 24) then
						dataPulseLengths(24) <= dataPulseLengths(24) + 1;
					elsif (dataIndex = 25) then
						dataPulseLengths(25) <= dataPulseLengths(25) + 1;
					elsif (dataIndex = 26) then
						dataPulseLengths(26) <= dataPulseLengths(26) + 1;
					elsif (dataIndex = 27) then
						dataPulseLengths(27) <= dataPulseLengths(27) + 1;
					elsif (dataIndex = 28) then
						dataPulseLengths(28) <= dataPulseLengths(28) + 1;
					elsif (dataIndex = 29) then
						dataPulseLengths(29) <= dataPulseLengths(29) + 1;
					elsif (dataIndex = 30) then
						dataPulseLengths(30) <= dataPulseLengths(30) + 1;
					elsif (dataIndex = 31) then
						dataPulseLengths(31) <= dataPulseLengths(31) + 1;
					elsif (dataIndex = 32) then
						dataPulseLengths(32) <= dataPulseLengths(32) + 1;
					elsif (dataIndex = 33) then
						dataPulseLengths(33) <= dataPulseLengths(33) + 1;
					elsif (dataIndex = 34) then
						dataPulseLengths(34) <= dataPulseLengths(34) + 1;
					elsif (dataIndex = 35) then
						dataPulseLengths(35) <= dataPulseLengths(35) + 1;
					elsif (dataIndex = 36) then
						dataPulseLengths(36) <= dataPulseLengths(36) + 1;
					elsif (dataIndex = 37) then
						dataPulseLengths(37) <= dataPulseLengths(37) + 1;
					elsif (dataIndex = 38) then
						dataPulseLengths(38) <= dataPulseLengths(38) + 1;
					elsif (dataIndex = 39) then
						dataPulseLengths(39) <= dataPulseLengths(39) + 1;
					elsif (dataIndex = 40) then
						dataPulseLengths(40) <= dataPulseLengths(40) + 1;
					end if;
					dataIndexCounter <= 0;
				elsif (enState = "0000000010") then
					dataIndex <= dataIndex + 1;
					dataIndexCounter <= dataIndexCounter + 1;
				elsif (enState = "0000000001") then
					doneCounter <= doneCounter;
				else
					-- nothing
				end if;
			end if;
		end process;

		process (dataIn, standbyCounter, sendingCounter, dataIndexCounter, sleepIndexCounter, doneCounter) begin
			case currentState is
				when Standby =>
					-- Standby for 100,000,000 x 20ns = 2s
					if (standbyCounter = 100000000) then
						nextState <= Sending;
					else
						nextState <= Standby;
					end if;
				when Sending =>
					-- Send 400,000 x 20ns = 8ms '0' pulse
					if (sendingCounter = 400000) then
						nextState <= Waiting;
					else
						nextState <= Sending;
					end if;
				when Waiting =>
					if (dataIn = '0') then
						nextState <= Presence;
					else
						nextState <= Waiting;
					end if;
				when Presence =>
					if (dataIn = '1') then
						nextState <= Preparation;
					else
						nextState <= Presence;
					end if;
				when Preparation =>
					if (dataIn = '0') then
						nextState <= Sleep;
					else
						nextState <= Preparation;
					end if;
				when Sleep =>
					if (dataIn = '1') then
						nextState <= SleepIndexState;
					else
						nextState <= Sleep;
					end if;
				when SleepIndexState =>
					if (sleepIndexCounter = 0) then
						nextState <= DataState;
					else
						nextState <= SleepIndexState;
					end if;
				when DataState =>
					if (dataIndex = 41) then
						nextState <= Done;
					else
						if (dataIn = '0') then
							nextState <= DataIndexState;
						else
							nextState <= DataState;
						end if;
					end if;
				when DataIndexState =>
					if (dataIndexCounter = 0) then
						nextState <= Sleep;
					else
						nextState <= DataIndexState;
					end if;
				when Done =>
					nextState <= Done;
			end case;
		end process;

		process (currentState) begin
			if (currentState = Standby) then
				data <= 'Z';
				enState <= "1000000000";
			elsif (currentState = Sending) then
				data <= '0';
				enState <= "0100000000";
			elsif (currentState = Waiting) then
				data <= 'Z';
				enState <= "0010000000";
			elsif (currentState = Presence) then
				data <= 'Z';
				enState <= "0001000000";
			elsif (currentState = Preparation) then
				data <= 'Z';
				enState <= "0000100000";
			elsif (currentState = Sleep) then
				data <= 'Z';
				enState <= "0000010000";
			elsif (currentState = SleepIndexState) then
				data <= 'Z';
				enState <= "0000001000";
			elsif (currentState = DataState) then
				data <= 'Z';
				enState <= "0000000100";
			elsif (currentState = DataIndexState) then
				data <= 'Z';
				enState <= "0000000010";
			elsif (currentState = Done) then
				data <= 'Z';
				enState <= "0000000001";
			else
				data <= 'Z';
				enState <= "0000000000";
			end if;
		end process;

end behaviour;
























