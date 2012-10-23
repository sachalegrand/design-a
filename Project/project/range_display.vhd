library ieee;
use ieee.std_logic_1164.all;

package range_display_package is
	component range_display
		port (clock : in std_logic;
				rangeType : in std_logic;
				humdLow, humdHigh, tempLow, tempHigh : in integer;
				anode : inout std_logic_vector(3 downto 0);
				cathode : out std_logic_vector(0 to 7));
	end component;
end package;


library ieee;
use ieee.std_logic_1164.all;
use integer_divider_package.integer_divider;

entity range_display is
	port (clock : in std_logic;
			rangeType : in std_logic;
			humdLow, humdHigh, tempLow, tempHigh : in integer;
			anode : inout std_logic_vector(3 downto 0);
			cathode : out std_logic_vector(0 to 7));
end range_display;

architecture Behavioral of range_display is
	
	signal counter : integer := 0;
	signal digit : integer := 0;
	signal humdLow1, humdLow0, humdHigh1, humdHigh0 : integer := 0;
	signal tempLow1, tempLow0, tempHigh1, tempHigh0 : integer := 0;
	
	begin
		
		humdLowSep: integer_divider port map (clock, humdLow, 10, humdLow1, humdLow0);
		humdHighSep: integer_divider port map (clock, humdHigh, 10, humdHigh1, humdHigh0);
		tempLowSep: integer_divider port map (clock, tempLow, 10, tempLow1, tempLow0);
		tempHighSep: integer_divider port map (clock, tempHigh, 10, tempHigh1, tempHigh0);
		
		process (clock) begin
			if (clock'event AND clock = '1') then
				if (counter = 0) then
					if (anode(2) = '0') then
						anode(2) <= '1';
						if (rangeType = '0') then digit <= humdLow1; else digit <= tempLow1; end if;
						anode(3) <= '0';
					elsif (anode(1) = '0') then
						anode(1) <= '1';
						if (rangeType = '0') then digit <= humdLow0; else digit <= tempLow0; end if;
						anode(2) <= '0';
					elsif (anode(0) = '0') then
						anode(0) <= '1';
						if (rangeType = '0') then digit <= humdHigh1; else digit <= tempHigh1; end if;
						anode(1) <= '0';
					elsif (anode(3) = '0') then
						anode(3) <= '1';
						if (rangeType = '0') then digit <= humdHigh0; else digit <= tempHigh0; end if;
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
			else
				cathode <= "11111111";
			end if;
		end process;
		
		
end Behavioral;

