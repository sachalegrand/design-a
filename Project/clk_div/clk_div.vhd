library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all ;
use ieee.std_logic_arith.all;

entity clk_div is
	port (clk_50 : in std_logic;
			clk_1us : inout std_logic;
			clk_1ms : inout std_logic;
			clk_1s : inout std_logic);
end clk_div;

architecture Behavioral of clk_div is
	signal counter_1us, counter_1ms, counter_1s : std_logic_vector(15 downto 0);
	begin
		process (clk_50) begin
			if (clk_50'event AND clk_50 = '1') then
				counter_1us <= counter_1us + conv_std_logic_vector(1, 16);
				if (counter_1us = conv_std_logic_vector(24, 16)) then
					clk_1us <= '1';
				elsif (counter_1us > conv_std_logic_vector(24, 16) and counter_1us < conv_std_logic_vector(50, 16)) then
					clk_1us <= clk_1us;
				elsif (counter_1us = conv_std_logic_vector(50, 16)) then
					counter_1us <= conv_std_logic_vector(0, 16);
					clk_1us <= '0';
				end if;
			end if;
		end process;
		process (clk_1us) begin
			if (clk_1us'event AND clk_1us = '1') then
				counter_1ms <= counter_1ms + conv_std_logic_vector(1, 16);
				if (counter_1ms = conv_std_logic_vector(499, 16)) then
					clk_1ms <= '1';
				elsif (counter_1ms > conv_std_logic_vector(499, 16) and counter_1ms < conv_std_logic_vector(1000, 16)) then
					clk_1ms <= clk_1ms;
				elsif (counter_1ms = conv_std_logic_vector(1000, 16)) then
					counter_1ms <= conv_std_logic_vector(0, 16);
					clk_1ms <= '0';
				end if;
			end if;
		end process;
		process (clk_1ms) begin
			if (clk_1ms'event AND clk_1ms = '1') then
				counter_1s <= counter_1s + conv_std_logic_vector(1, 16);
				if (counter_1s= conv_std_logic_vector(499, 16)) then
					clk_1s <= '1';
				elsif (counter_1s > conv_std_logic_vector(499, 16) and counter_1s < conv_std_logic_vector(1000, 16)) then
					clk_1s <= clk_1s;
				elsif (counter_1s = conv_std_logic_vector(1000, 16)) then
					counter_1s <= conv_std_logic_vector(0, 16);
					clk_1s <= '0';
				end if;
			end if;
		end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

package clk_div_package is
	component clk_div
		port (clk_50 : in std_logic;
			clk_1us : inout std_logic;
			clk_1ms : inout std_logic;
			clk_1s : inout std_logic);
	end component;
end clk_div_package;

