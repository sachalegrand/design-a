----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:58:17 10/07/2012 
-- Design Name: 
-- Module Name:    digit_separator - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use integer_divider_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity digit_separator is
	port(clock : in std_logic;
		  reset : in std_logic;
		  number : in integer;
		  digit3, digit2, digit1, digit0 : out integer);
end digit_separator;

architecture Behavioral of digit_separator is
	signal dividend3, dividend2, dividend1, dividend0 : integer;
	signal dividendd : integer;
	begin
		dividend3 <= number;
		dig0: integer_divider port map (clock, reset, dividend3, 10, dividend2, digit0);
		dig1: integer_divider port map (clock, reset, dividend2, 10, dividend1, digit1);
		dig2: integer_divider port map (clock, reset, dividend1, 10, dividend0, digit2);
		dig3: integer_divider port map (clock, reset, dividend0, 10, dividendd, digit3);		
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

package digit_separator_package is
	component digit_separator
		port(clock : in std_logic;
			  reset : in std_logic;
			  number : in integer;
			  digit3, digit2, digit1, digit0 : out integer);
	end component;
end package;



















