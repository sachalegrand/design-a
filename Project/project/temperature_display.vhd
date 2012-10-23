library ieee;
use ieee.std_logic_1164.all;

package temperature_display_package is
	component temperature_display
		port (clock : in std_logic;
				temperature : in integer;
				anode : inout std_logic_vector(3 downto 0);
				cathode : out std_logic_vector(0 to 7));
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use integer_divider_package.integer_divider;

entity temperature_display is
	port (clock : in std_logic;
			temperature : in integer;
			anode : inout std_logic_vector(3 downto 0);
			cathode : out std_logic_vector(0 to 7));
end temperature_display;

architecture behavioral of temperature_display is
	
	signal counter : integer := 0;
	signal digit, temp1, temp0 : integer := 0;

	begin
		
		separateDigits: integer_divider port map (clock, temperature, 10, temp1, temp0);
	
		process (clock) begin
			if (clock'event AND clock = '1') then
				if (counter = 0) then
					if (anode(2) = '0') then
						anode(2) <= '1';
						digit <= temp1;
						anode(3) <= '0';
					elsif (anode(1) = '0') then
						anode(1) <= '1';
						digit <= temp0;
						anode(2) <= '0';
					elsif (anode(0) = '0') then
						anode(0) <= '1';
						digit <= 10;
						anode(1) <= '0';
					elsif (anode(3) = '0') then
						anode(3) <= '1';
						digit <= 11;
						anode(0) <= '0';
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
				cathode <= "00000011";
			elsif (digit = 1) then
				cathode <= "10011111";
			elsif (digit = 2) then
				cathode <= "00100101";
			elsif (digit = 3) then
				cathode <= "00001101";
			elsif (digit = 4) then
				cathode <= "10011001";
			elsif (digit = 5) then
				cathode <= "01001001";
			elsif (digit = 6) then
				cathode <= "01000001";
			elsif (digit = 7) then
				cathode <= "00011111";
			elsif (digit = 8) then
				cathode <= "00000001";
			elsif (digit = 9) then
				cathode <= "00001001";
			elsif (digit = 10) then
				cathode <= "00111001";
			elsif (digit = 11) then
				cathode <= "01100011";
			else
				cathode <= "11111111";
			end if;
		end process;


end behavioral;

