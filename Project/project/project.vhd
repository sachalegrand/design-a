library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use display_package.display;
use mode_display_package.mode_display;
use range_display_package.range_display;
use range_setter_package.range_setter;
use temperature_display_package.temperature_display;
use sensor_package.sensor;

entity project is
	port (clock : in std_logic;
			button3, button2, button1, button0 : in std_logic;  
			selectMode : in std_logic;
			setRange : in std_logic;
			rangeType : in std_logic;
			owdata : inout std_logic;
			an : inout std_logic_vector(3 downto 0);
			ca : out std_logic_vector(0 to 7));
end project;

architecture Behavioral of project is
	
	type stateType is (SnapshotReady, SnapshotProcessing, SnapshotDone, StreamingReady, StreamingProcessing, StreamingDone, HumidityRange, TemperatureRange);
	
	signal reset, start : std_logic := '0';
	signal currentState, nextState : stateType := SnapshotReady;
	signal displayValue : integer := 0;
	signal modeAnode, rangeAnode, temperatureAnode : std_logic_vector(3 downto 0) := "0000";
	signal modeCathode, rangeCathode, temperatureCathode : std_logic_vector(0 to 7) := "11111111";
	signal humdLow, humdHigh, tempLow, tempHigh : integer := 0;
	signal humdLowDown, humdLowUp, humdHighDown, humdHighUp : std_logic := '0';
	signal tempLowDown, tempLowUp, tempHighDown, tempHighUp : std_logic := '0';
	signal humidity, temperature : integer;
	signal doneFlag : std_logic;
	
	begin

		displayMode: mode_display port map (clock, selectMode, modeAnode, modeCathode);
		displayRange: range_display port map (clock, rangeType, humdLow, humdHigh, tempLow, tempHigh, rangeAnode, rangeCathode);
		setHumidityRange: range_setter port map (clock, humdLowDown, humdLowUp, humdHighDown, humdHighUp, humdLow, humdHigh);
		setTemperatureRange: range_setter port map (clock, tempLowDown, tempLowUp, tempHighDown, tempHighUp, tempLow, tempHigh);
		snapshotMode: sensor port map (clock, reset, start, owdata, humidity, temperature, doneFlag);
		displayTemperature: temperature_display port map (clock, temperature, temperatureAnode, temperatureCathode);
		
		process (clock, reset) begin
			if (reset = '1') then
				currentState <= SnapshotReady;
			elsif (clock'event and clock = '1') then
				currentState <= nextState;
			end if;
		end process;
		
		process (selectMode, setRange, rangeType, start, doneFlag) begin
			case currentState is
				when SnapshotReady =>
					if (start = '1') then
						nextState <= SnapshotProcessing;
					else
						if (setRange = '0') then
							if (selectMode = '0') then nextState <= SnapshotReady;
							else nextState <= StreamingReady; end if;
						else
							if (rangeType = '0') then nextState <= HumidityRange;
							else nextState <= TemperatureRange; end if;
						end if;
					end if;
				when StreamingReady =>
					if (start = '1') then
						nextState <= StreamingProcessing;
					else
						if (setRange = '0') then
							if (selectMode = '0') then nextState <= SnapshotReady;
							else nextState <= StreamingReady; end if;
						else
							if (rangeType = '0') then nextState <= HumidityRange;
							else nextState <= TemperatureRange; end if;
						end if;
					end if;
				when HumidityRange =>
					if (setRange = '0') then
						if (selectMode = '0') then nextState <= SnapshotReady;
						else nextState <= StreamingReady; end if;
					else
						if (rangeType = '0') then nextState <= HumidityRange;
						else nextState <= TemperatureRange; end if;
					end if;
				when TemperatureRange =>
					if (setRange = '0') then
						if (selectMode = '0') then nextState <= SnapshotReady;
						else nextState <= StreamingReady; end if;
					else
						if (rangeType = '0') then nextState <= HumidityRange;
						else nextState <= TemperatureRange; end if;
					end if;
				when SnapshotProcessing =>
					if (doneFlag = '1') then nextState <= SnapshotDone; else nextState <= SnapshotProcessing; end if;
				when StreamingProcessing =>
					nextState <= StreamingProcessing;
				when SnapshotDone =>
					nextState <= SnapshotDone;
				when StreamingDone =>
					nextState <= StreamingDone;
			end case;
		end process;
		
		process (currentState) begin
			if (currentState = SnapshotReady) then
				an <= modeAnode;
				ca <= modeCathode;
				start <= button1;
				reset <= button0;
			elsif (currentState = StreamingReady) then
				an <= modeAnode;
				ca <= modeCathode;
				start <= button1;
				reset <= button0;
			elsif (currentState = HumidityRange) then
				an <= rangeAnode;
				ca <= rangeCathode;
				humdLowDown <= button3;
				humdLowUp <= button2;
				humdHighDown <= button1;
				humdHighUp <= button0;
			elsif (currentState = TemperatureRange) then
				an <= rangeAnode;
				ca <= rangeCathode;
				tempLowDown <= button3;
				tempLowUp <= button2;
				tempHighDown <= button1;
				tempHighUp <= button0;
			elsif (currentState = SnapshotProcessing) then
				an <= temperatureAnode;
				ca <= temperatureCathode;
			elsif (currentState = StreamingProcessing) then
				--
			elsif (currentState = SnapshotDone) then
				an <= temperatureAnode;
				ca <= temperatureCathode;
			elsif (currentState = StreamingDone) then
				--
			else
				--
			end if;
		end process;
	
end Behavioral;



























