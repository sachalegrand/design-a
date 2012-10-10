----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:54:04 10/07/2012 
-- Design Name: 
-- Module Name:    display - Behavioral 
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
use digit_separator_package.all;
use clocked_display_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
	port (clock : in std_logic;
			reset : in std_logic;
			an : inout std_logic_vector(3 downto 0);
			ca : out std_logic_vector(0 to 6));
end display;

architecture Behavioral of display is
	signal digit3, digit2, digit1, digit0 : integer;
	signal number : integer := 23;
	begin
		separate: digit_separator port map (clock, reset, number, digit3, digit2, digit1, digit0);
		display: clocked_display port map (clock, digit3, digit2, digit1, digit0, an, ca);
end Behavioral;

























