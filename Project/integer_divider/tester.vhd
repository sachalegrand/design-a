----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:24:12 10/07/2012 
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
use integer_divider_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tester is
	port(clock : in std_logic;
		  reset : in std_logic;
		  selVar : in std_logic;
		  leds : out std_logic_vector(7 downto 0));
end tester;

architecture Behavioral of tester is
	signal quotient, remainder : integer;
	begin
		with selVar select
			leds <= conv_std_logic_vector(quotient, 8) when '0',
					  conv_std_logic_vector(remainder, 8) when '1',
					  "00000000" when others;
		test: integer_divider port map (clock, reset, 56, 10, quotient, remainder);
end Behavioral;



















