library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all ;
use ieee.std_logic_arith.all;
use work.clk_div_package.all;

entity sensor is
	port (clk_50 : in std_logic;
			reset : in std_logic;
			leds : out std_logic_vector(7 downto 0);
			one_wire : inout std_logic);
end sensor;

architecture structure of sensor is
	
	signal clk_1us, clk_1ms, clk_1s : std_logic;
	signal timer_1us, timer_1ms, timer_1s : integer;
	type state_type is (Standby, Sending, Waiting, Handshake, Done);
	signal current_state : state_type;
	
	begin
		
		timer_inst: clk_div port map (clk_50, clk_1us, clk_1ms, clk_1s);		
		
		process (reset, clk_1us) begin
			if (clk_1us'event AND clk_1us = '1') then
				if (reset = '1') then
					-- reset everything
					timer_1us <= 0;
					timer_1ms <= 0;
					timer_1s <= 0;
					current_state <= Standby;
				else
					-- increment timer
					if (timer_1us = 1000) then
						timer_1us <= 0;
						if (timer_1ms = 1000) then
							timer_1ms <= 0;
							timer_1s <= timer_1s + 1;
						else
							timer_1ms <= timer_1ms + 1;
						end if;
					else
						timer_1us <= timer_1us + 1;
					end if;
					-- state transition
					if (current_state = Standby) then
						if (timer_1s = 3) then
							current_state <= Sending;
							timer_1us <= 0; timer_1ms <= 0; timer_1s  <= 0; -- reset timer
						end if;
					elsif (current_state = Sending) then
						if (timer_1ms = 9) then
							current_state <= Waiting;
							timer_1us <= 0; timer_1ms <= 0; timer_1s  <= 0;
						end if;
					elsif (current_state = Waiting) then
						if (one_wire = '0') then
							current_state <= Handshake;
							timer_1us <= 0; timer_1ms <= 0; timer_1s  <= 0;
						end if;
					elsif (current_state = Handshake) then
						if (one_wire = '1') then
							current_state <= Done;
							timer_1us <= 0; timer_1ms <= 0; timer_1s  <= 0;
						end if;
					elsif (current_state = Done) then
						-- nothing yet
					end if;
					
				end if;
			end if;
		end process;
		
		process (current_state) begin
			if (current_state = Standby) then
				one_wire <= '1';
				leds <= "10000000";
			elsif (current_state = Sending) then
				one_wire <= '0';
				leds <= "11000000";
			elsif (current_state = Waiting) then
				one_wire <= '1';
				leds <= "11100000";
			elsif (current_state = Handshake) then
				leds <= "11110000";
			elsif (current_state = Done) then
				leds <= "11111000";
			end if;
		end process;
		
end structure;
























