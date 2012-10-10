library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity length_decoder is
	port (pulse_length : in integer;
			bit_value : out std_logic);
end length_decoder;

architecture behaviour of length_decoder is
	begin
		bit_value <= '0' when (pulse_length > 500 and pulse_length < 1500) else
						 '1' when (pulse_length > 2500 and pulse_length < 4000) else
						 'X';
end behaviour;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

package length_decoder_package is
	component length_decoder
		port (pulse_length : in integer;
				bit_value : out std_logic);
	end component;
end length_decoder_package;