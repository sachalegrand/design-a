library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all ;
use ieee.std_logic_arith.all;

entity clk_ms is
	port (clk_50 : in std_logic;
			clk_1ms : inout std_logic);
end clk_ms;

architecture Behavioral of clk_ms is
	signal counter : std_logic_vector(18 downto 0);
	begin
		process (clk_50) begin -- 100Hz clock
			if (clk_50'event AND clk_50 = '1') then
				counter <= counter + "0000000000000000001";
				if (counter = "111101000010010000") then
					clk_1ms <= '1';
				elsif (counter > "111101000010010000" and counter < "1111010000100100000") then
					clk_1ms <= clk_1ms;
				elsif (counter > "1111010000100100000") then
					counter <= "0000000000000000000";
					clk_1ms <= '0';
				else
					--
				end if;
			end if;
		end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

package clk_ms_package is
	component clk_ms
		port (clk_50 : in std_logic;
			clk_1ms : out std_logic);
	end component;
end clk_ms_package;

