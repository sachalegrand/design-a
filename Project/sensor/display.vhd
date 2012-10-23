library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

package display_package is
	component display
		port (clock : in std_logic;
				number : in integer;
				an : inout std_logic_vector(3 downto 0);
				ca : out std_logic_vector(0 to 7));
	end component;
end package;

library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use integer_divider_package.all;

entity display is
	port (clock : in std_logic;
			number : in integer;
			an : inout std_logic_vector(3 downto 0);
			ca : out std_logic_vector(0 to 7));
end display;

architecture behavioral of display is
	
	signal counter : integer := 0;
	signal digit, digit3, digit2, digit1, digit0 : integer := 0;
	signal q2, q1 : integer := 0;
	
	begin
	
		-- separate the digits
		sep1: integer_divider port map (clock, number, 10, q2, digit0);
		sep2: integer_divider port map (clock, q2, 10, q1, digit1);
		sep3: integer_divider port map (clock, q1, 10, digit3, digit2);
		
		process (clock) begin
			if (clock'event AND clock = '1') then
				if (counter = 0) then
					if (an(2) = '0') then
						an(2) <= '1';
						digit <= digit3;
						an(3) <= '0';
					elsif (an(1) = '0') then
						an(1) <= '1';
						digit <= digit2;
						an(2) <= '0';
					elsif (an(0) = '0') then
						an(0) <= '1';
						digit <= digit1;
						an(1) <= '0';
					elsif (an(3) = '0') then
						an(3) <= '1';
						digit <= digit0;
						an(0) <= '0';
					end if;
				end if;
				counter <= counter + 1;
				if (counter > 5000) then
					counter <= 0;
				end if;
			end if;
		end process;
		
		process (digit) begin
			if (digit = 0) then
				ca <= "00000011";
			elsif (digit = 1) then
				ca <= "10011111";
			elsif (digit = 2) then
				ca <= "00100101";
			elsif (digit = 3) then
				ca <= "00001101";
			elsif (digit = 4) then
				ca <= "10011001";
			elsif (digit = 5) then
				ca <= "01001001";
			elsif (digit = 6) then
				ca <= "01000001";
			elsif (digit = 7) then
				ca <= "00011111";
			elsif (digit = 8) then
				ca <= "00000001";
			elsif (digit = 9) then
				ca <= "00001001";
			else
				ca <= "11111111";
			end if;
		end process;
		
end behavioral;