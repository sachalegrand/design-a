----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:42:30 10/07/2012 
-- Design Name: 
-- Module Name:    clocked_display - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use display_decoder_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clocked_display is
	port (clock : in std_logic;
			display3, display2, display1, display0 : in integer;
			an : inout std_logic_vector(3 downto 0);
			ca : out std_logic_vector(0 to 6));
end clocked_display;

architecture Behavioral of clocked_display is
	signal counter : integer := 0;
	signal disp3, disp2, disp1 : integer := 0;
	signal display : integer;
	begin
		disp3 <= 
		decode: display_decoder port map (display, ca);
		process (clock) begin
			if (clock'event AND clock = '1') then
				if (counter = 0) then
					if (an(2) = '0') then
						an(2) <= '1';
						display <= display3;
						an(3) <= '0';
					elsif (an(1) = '0') then
						an(1) <= '1';
						display <= display2;
						an(2) <= '0';
					elsif (an(0) = '0') then
						an(0) <= '1';
						display <= display1;
						an(1) <= '0';
					elsif (an(3) = '0') then
						an(3) <= '1';
						display <= display0;
						an(0) <= '0';
					end if;
				end if;
				counter <= counter + 1;
				if (counter = 4000) then
					counter <= 0;
				end if;
			end if;
		end process;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

package clocked_display_package is
	component clocked_display
		port (clock : in std_logic;
				display3, display2, display1, display0 : in integer;
				an : inout std_logic_vector(3 downto 0);
				ca : out std_logic_vector(0 to 6));
	end component;
end package;































