library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DisplayDecoder is
	port (input : in integer;
			output : out std_logic_vector(0 to 6));
end DisplayDecoder;

architecture Behavioral of DisplayDecoder is
	begin
		process (input) begin
			if (input = 32) then
				output <= "1111111"; -- blank
			elsif (input = 45) then
				output <= "1111110"; -- -
			elsif (input = 0) then
				output <= "0000001"; -- 0
			elsif (input = 1) then
				output <= "1001111"; -- 1
			elsif (input = 2) then
				output <= "0010010";	-- 2
			elsif (input = 3) then
				output <= "0000110";	-- 3
			elsif (input = 4) then
				output <= "1001100";	-- 4
			elsif (input = 5) then
				output <= "0100100";	-- 5
			elsif (input = 6) then
				output <= "0100000";	-- 6
			elsif (input = 7) then
				output <= "0001111";	-- 7
			elsif (input = 8) then
				output <= "0000000";	-- 8
			elsif (input = 9) then
				output <= "0000100";	-- 9
			end if;
		end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

package DisplayDecoderPackage is
	component DisplayDecoder
		port (input : in integer;
			   output : out std_logic_vector(0 to 6));
	end component;
end DisplayDecoderPackage;

