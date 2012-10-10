library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity PulseLengthDecoder is
	port (pulseLength : in integer;
			bitValue : out std_logic;
			bitValueValid : out std_logic);
end PulseLengthDecoder;

architecture behaviour of PulseLengthDecoder is
	begin
		process (pulseLength) begin
			if (pulseLength > 750 and pulseLength < 1750) then
				bitValue <= '0';
				bitValueValid <= '1';
			elsif (pulseLength > 3000 and pulseLength < 4000) then
				bitValue <= '1';
				bitValueValid <= '1';
			else
				bitValueValid <= '0';
			end if;
		end process;		
end behaviour;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

package PulseLengthDecoderPackage is
	component PulseLengthDecoder
		port (pulseLength : in integer;
				bitValue : out std_logic;
				bitValueValid : out std_logic);
	end component;
end package;