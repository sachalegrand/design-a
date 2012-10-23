library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

package range_setter_package is
	component range_setter
		port (clock : in std_logic;
				minDown, minUp, maxDown, maxUp : in std_logic;
				minValue, maxValue : out integer);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity range_setter is
	port (clock : in std_logic;
			minDown, minUp, maxDown, maxUp : in std_logic;
			minValue, maxValue : out integer);
end range_setter;

architecture Behavioral of range_setter is
	
	signal minValueSignal : integer := 0;
	signal maxValueSignal : integer := 99;
	signal enableSleep : std_logic := '0';
	signal counter : integer := 0;
	
	begin
	
		minValue <= minValueSignal;
		maxValue <= maxValueSignal;
	
		process (clock) begin
			if (clock'event and clock = '1') then
				if (enableSleep = '0') then
					-- decrement min value
					if (minDown = '1') then
						if (minValueSignal > 0) then
							minValueSignal <= minValueSignal - 1;
							enableSleep <= '1';
						end if;
					-- increment min value
					elsif (minUp = '1') then
						if (minValueSignal < 99) then
							minValueSignal <= minValueSignal + 1;
							enableSleep <= '1';
						end if;
					-- decrement max value
					elsif (maxDown = '1') then
						if (maxValueSignal > 0) then
							maxValueSignal <= maxValueSignal - 1;
							enableSleep <= '1';
						end if;
					-- increment max value
					elsif (maxUp = '1') then
						if (maxValueSignal < 99) then
							maxValueSignal <= maxValueSignal + 1;
							enableSleep <= '1';
						end if;
					end if;
				else
					counter <= counter + 1;
					if (counter = 5000000) then
						counter <= 0;
						enableSleep <= '0';
					end if;
				end if;
			end if;
		end process;
		
end Behavioral;























