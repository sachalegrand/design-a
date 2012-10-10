library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity decoder is
	port (clock: in std_logic;
			input: in std_logic_vector(7 downto 0);
			output: out std_logic_vector(7 downto 0));
end decoder;

architecture behaviour of decoder is
	signal countVal: integer;
	signal pulseLength: integer;
	signal counter: integer;
	signal quotient: integer;
	signal product: integer;
	begin
		countVal <= to_integer(unsigned(input));
		output <= conv_std_logic_vector(pulseLength, 7);
		pulseLength <= quotient;
		product <= quotient*50;
		process (clock) begin
			if (rising_edge(clock)) then
				if (product < countVal) then
					counter <= counter + 1;
					if (counter = 50) then
						counter <= 0;
						quotient <= quotient + 1;
					end if;
				end if;
			end if;
		end process;
end behaviour;