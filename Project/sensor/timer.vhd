library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	port (clk_50 : in std_logic;
			reset : in std_logic;
			counter_1us : inout integer);
end timer;

architecture Behavioral of timer is
	signal counter_50 : integer;
	begin
		process (clk_50, reset) begin
			if (clk_50'event and clk_50 = '0') then
				if (reset = '1') then
					counter_50 <= 0;
					counter_1us <= 0;
				else
					if (counter_50 = 50) then
						counter_50 <= 0;
						if (counter_1us = 9999) then
							counter_1us <= 0;
						else
							counter_1us <= counter_1us + 1;
						end if;
					else
						counter_50 <= counter_50 + 1;
					end if;
				end if;
			end if;
		end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package timer_package is
	component timer
		port (clk_50 : in std_logic;
				reset : in std_logic;
				counter_1us : inout integer);
	end component;
end timer_package;















