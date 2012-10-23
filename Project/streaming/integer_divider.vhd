library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package integer_divider_package is
	component integer_divider
		port (clock : in std_logic;
				dividend : in integer;
				divisor : in integer;
				quotient : out integer;
				remainder : out integer);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity integer_divider is
	port (clock : in std_logic;
			dividend : in integer;
			divisor : in integer;
			quotient : inout integer;
			remainder : inout integer);
end integer_divider;

architecture behaviour of integer_divider is
	signal numerator : integer;
	signal done : std_logic := '0';
	begin
		process(clock) begin
			if (clock'event and clock = '1') then
				if (done = '0') then
					if((dividend - numerator) >= divisor) then
						numerator <= numerator + divisor;
						quotient <= quotient + 1;
					else
						remainder <= dividend - numerator;
						done <= '1';
					end if;
				else
					if ((numerator + remainder) /= dividend) then
						numerator <= 0;
						quotient <= 0;
						remainder <= 0;
						done <= '0';
					end if;
				end if;
			end if;
		end process;
end behaviour;


























