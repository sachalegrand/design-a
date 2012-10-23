library ieee;
use ieee.std_logic_1164.all;

package mode_display_package is
	component mode_display
		port (clock : in std_logic;
				mode : in std_logic;
				anode : out std_logic_vector(3 downto 0);
				cathode : out std_logic_vector(0 to 7));
	end component;
end package;

library ieee;
use ieee.std_logic_1164.all;

entity mode_display is
	port (clock : in std_logic;
			mode : in std_logic;
			anode : inout std_logic_vector(3 downto 0);
			cathode : out std_logic_vector(0 to 7));
end mode_display;

architecture Behavioral of mode_display is
	
	signal char, counter : integer := 0;	
	
	begin
		
		process (clock) begin
			if (clock'event AND clock = '1') then
				if (counter = 0) then
					if (anode(2) = '0') then
						anode(2) <= '1';
						char <= 45;
						anode(3) <= '0';
					elsif (anode(1) = '0') then
						anode(1) <= '1';
						char <= 83;
						anode(2) <= '0';
					elsif (anode(0) = '0') then
						anode(0) <= '1';
						if (mode = '0') then char <= 110; else char <= 116; end if;
						anode(1) <= '0';
					elsif (anode(3) = '0') then
						anode(3) <= '1';
						char <= 32;
						anode(0) <= '0';
					end if;
				end if;
				counter <= counter + 1;
				if (counter > 5000) then
					counter <= 0;
				end if;
			end if;
		end process;
		
		process (char) begin
			if (char = 83) then
				cathode <= "01001001"; -- S
			elsif (char = 110) then
				cathode <= "11010101"; -- n
			elsif (char = 116) then
				cathode <= "11100001"; -- t
			elsif (char = 32) then
				cathode <= "11111111"; --  
			else
				cathode <= "11111111"; --  
			end if;
		end process;

end Behavioral;

