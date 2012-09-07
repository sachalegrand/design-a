library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.DisplayDecoderPackage.all;

entity LedDisplay is
	port (clk : in std_logic;
			led_in_3 : in integer;
			led_in_2 : in integer;
			led_in_1 : in integer;
			led_in_0 : in integer;
			an : inout std_logic_vector(3 downto 0);
			led : out std_logic_vector(0 to 6));
end LedDisplay;

architecture Behavioral of LedDisplay is
	signal counter : std_logic_vector(12 downto 0);
	signal number : integer;
	begin
		decode_value: DisplayDecoder port map (number, led);
		process (clk) begin
			if (clk'event AND clk = '1') then
				if (counter = "0000000000000") then
					if (an(2) = '0') then
						an(2) <= '1';
						number <= led_in_3;
						an(3) <= '0';
					elsif (an(1) = '0') then
						an(1) <= '1';
						number <= led_in_2;
						an(2) <= '0';
					elsif (an(0) = '0') then
						an(0) <= '1';
						number <= led_in_1;
						an(1) <= '0';
					elsif (an(3) = '0') then
						an(3) <= '1';
						number <= led_in_0;
						an(0) <= '0';
					end if;
				end if;
				counter <= counter + "0000000000001";
				if (counter > "1000000000000") then
					counter <= "0000000000000";
				end if;
			end if;
		end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

package LedDisplayPackage is
	component LedDisplay
		port (clk : in std_logic;
				led_in_3 : in integer;
				led_in_2 : in integer;
				led_in_1 : in integer;
				led_in_0 : in integer;
				an : inout std_logic_vector(3 downto 0);
				led : out std_logic_vector(0 to 6));
	end component;
end LedDisplayPackage;















