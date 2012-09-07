library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.LedDisplayPackage.all;
use work.clk_div_package.all;

entity top_level is
	port (clk_50 : in std_logic;
			clk_1us : inout std_logic;
			clk_1ms : inout std_logic;
			clk_1s : inout std_logic;
 			an : inout std_logic_vector(3 downto 0);
			led : out std_logic_vector(0 to 6));
end top_level;

architecture Behavioral of top_level is
	signal led_3, led_2, led_1, led_0 : integer;
	begin		
		display: LedDisplay port map (clk_50, led_3, led_2, led_1, led_0, an, led);
		clock: clk_div port map (clk_50, clk_1us, clk_1ms, clk_1s);
		process (clk_1s) begin
			if (clk_1s'event AND clk_1s = '0') then
				led_3 <= 49;
			elsif (clk_1s'event AND clk_1s = '1') then
				led_3 <= 48;
			end if;
		end process;
end Behavioral;



















