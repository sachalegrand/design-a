----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:08:20 10/07/2012 
-- Design Name: 
-- Module Name:    tester - Behavioral 
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
use digit_separator_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tester is
	port (clock : in std_logic;
			reset : in std_logic;
			selDigit : in std_logic_vector(1 downto 0);
			leds : out std_logic_vector(7 downto 0));
end tester;

architecture Behavioral of tester is
	signal digit3, digit2, digit1, digit0 : integer;
	begin
		with selDigit select
			leds <= conv_std_logic_vector(digit0, 8) when "00",
					  conv_std_logic_vector(digit1, 8) when "01",
					  conv_std_logic_vector(digit2, 8) when "10",
					  conv_std_logic_vector(digit3, 8) when "11",
					  "00000000" when others;
		separate: digit_separator port map (clock, reset, 348, digit3, digit2, digit1, digit0);
end Behavioral;






















