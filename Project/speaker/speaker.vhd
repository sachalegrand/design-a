library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity speaker is
	port (clock : in std_logic;
			output : out std_logic);
end speaker;

architecture Behavioral of speaker is
	signal time_counter : integer range 0 to 4000000;
	signal time_signal : std_logic;
	signal speaker_counter : integer range 0 to 5000;
	signal speaker_signal : std_logic;
	begin
		
		with time_signal select
			output <= '0' when '0',
						 speaker_signal when '1',
						 '1' when others;
		
		process (clock) begin
			if (clock'event and clock = '1') then
				time_counter <= time_counter + 1;
				speaker_counter <= speaker_counter + 1;
				if (time_counter = 0) then
					time_signal <= not time_signal;
				end if;
				if (speaker_counter = 0) then
					speaker_signal <= not speaker_signal;
				end if;
			end if;
		end process;
		
end Behavioral;


















