library ieee;
use ieee.std_logic_1164.all;
use sensor_package.sensor;
use display_package.display;

entity streaming is
	port (clock : in std_logic;
			owdata : inout std_logic;
			anode : inout std_logic_vector(3 downto 0);
			cathode : out std_logic_vector(0 to 7));
end streaming;

architecture behavioural of streaming is
	
	type stateType is (Initialize, SensorProcess, Cooldown);
	signal currentState, nextState : stateType := Initialize;
	signal enableState : integer := 1;
	signal initializeLength, sensorProcessLength, cooldownLength : integer := 0;
	signal reset, start, done : std_logic;
	signal humidity, temperature : integer := 0;
	
	begin
	
	sensorMapping: sensor port map (clock, reset, start, owdata, humidity, temperature, done);
	displayTemperature : display port map (clock, temperature, anode, cathode);
	
	process (clock) begin
		if (clock'event and clock = '1') then
			currentState <= nextState;
			if (enableState = 1) then
				reset <= '1';
				start <= '0';
				initializeLength <= initializeLength + 1;
				sensorProcessLength <= 0;
				cooldownLength <= 0;
			elsif (enableState = 2) then
				reset <= '0';
				start <= '1';
				initializeLength <= 0;
				sensorProcessLength <= sensorProcessLength + 1;
				cooldownLength <= 0;
			elsif (enableState = 3) then
				reset <= '0';
				start <= '0';
				initializeLength <= 0;
				sensorProcessLength <= 0;
				cooldownLength <= cooldownLength + 1;
			end if;
		end if;
	end process;
	
	process (initializeLength, done, cooldownLength) begin
		case currentState is
			when Initialize =>
				if (initializeLength = 10) then
					nextState <= SensorProcess;
				else
					nextState <= Initialize;
				end if;
			when SensorProcess =>
				if (done = '1') then
					nextState <= Cooldown;
				else
					nextState <= SensorProcess;
				end if;
			when Cooldown =>
					if (cooldownLength = 100000000) then nextState <= Initialize;
					else nextState <= Cooldown; end if;
		end case;
	end process;
	
	process (currentState) begin
		if (currentState = Initialize) then
			enableState <= 1;
		elsif (currentState = SensorProcess) then
			enableState <= 2;
		elsif (currentState = Cooldown) then
			enableState <= 3;
		else
			enableState <= 0;
		end if;
	end process;		
	
end behavioural;