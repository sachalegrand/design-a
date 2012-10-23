library ieee;
use ieee.std_logic_1164.all;

package pulse_decoder_package is
	component pulse_decoder
		port (pulseLength : in integer;
				bitValue : out std_logic;
				bitValid : out std_logic);
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;

entity pulse_decoder is
	port (pulseLength : in integer;
			bitValue : out std_logic;
			bitValid : out std_logic);
end pulse_decoder;

architecture Behavioral of pulse_decoder is
	begin
		process (pulseLength) begin
			if (pulseLength > 1100 and pulseLength < 1600) then
				bitValue <= '0';
				bitValid <= '1';
			elsif (pulseLength > 3250 and pulseLength < 3750) then
				bitValue <= '1';
				bitValid <= '1';
			elsif (pulseLength = 0) then
				bitValue <= '0';
				bitValid <= '0';
			else
				bitValid <= '0';
			end if;
		end process;
end Behavioral;

