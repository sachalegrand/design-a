----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:38:56 10/07/2012 
-- Design Name: 
-- Module Name:    display_decoder - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display_decoder is
	port (input_value : in integer;
			display_value : out std_logic_vector(0 to 6));
end display_decoder;

architecture Behavioral of display_decoder is
	begin
		process (input_value) begin
			case (input_value) is
				when 0 => display_value <= "0000001";
				when 1 => display_value <= "1001111";
				when 2 => display_value <= "0010010";
				when 3 => display_value <= "0000110";
				when 4 => display_value <= "1001100";
				when 5 => display_value <= "0100100";
				when 6 => display_value <= "0100000";
				when 7 => display_value <= "0001111";
				when 8 => display_value <= "0000000";
				when 9 => display_value <= "0000100";
				when others => display_value <= "1111111";
			end case;
		end process;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package display_decoder_package is
	component display_decoder
		port (input_value : in integer;
				display_value : out std_logic_vector);
	end component;
end package;





























