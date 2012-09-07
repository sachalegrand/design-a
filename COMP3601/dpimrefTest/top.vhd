	----------------------------------------------------------------------------------
-- Company: School of CSE, UNSW
-- Engineer: Sacha Beraud
-- 
-- Create Date:    16:09:26 04/12/2012 
-- Design Name:    USB communications testing wrapper
-- Module Name:    top - Behavioral 
-- Project Name: Design Project A
-- Target Devices: Nexys Board
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( 	-- main clk (25mhz, 40ns clk cycle)
				clkT : in  STD_LOGIC;
				-- usb communication ports
				par_data : inout  STD_LOGIC_VECTOR (7 downto 0);
				par_dst : in  STD_LOGIC;
				par_ast : in  STD_LOGIC;
				par_wr : in  STD_LOGIC;
				par_wait : out  STD_LOGIC;
				--	switches, push buttons and leds ports
				switches : in STD_LOGIC_VECTOR(7 downto 0);
				pbs : in  STD_LOGIC_VECTOR(3 downto 0);
				leds : out STD_LOGIC_VECTOR(7 downto 0);
				-- memory ports
				mt_oe : out std_logic;
				mt_we : out std_logic;
				mt_adv : out std_logic;
				mt_clk : out std_logic;
				mt_ub : out std_logic;
				mt_lb : out std_logic;
				mt_cf : out std_logic;
				mt_cre : out std_logic;
				mt_wait : out std_logic;
				mem_data : inout std_logic_vector(15 downto 0);
				mem_addr : out std_logic_vector (22 downto 0)
			  );
			  
end top;

architecture Structural of top is

-- USB communications component
component dpimref
    Port (
				mclk 	: in std_logic;
				pdb		: inout std_logic_vector(7 downto 0);
				astb 	: in std_logic;
				dstb 	: in std_logic;
				pwr 	: in std_logic;
				pwait 	: out std_logic;
				rgSwt	: in std_logic_vector(7 downto 0);
				rgBtn	: in std_logic_vector(4 downto 0);
				btn		: in std_logic;
				ldg		: out std_logic;
				led		: out std_logic
	);
end component;



-- memory communication component
component memory is
		Port (
				clk 		: in std_logic;
				reset 	: in std_logic;
				address	: in std_logic_vector (22 downto 0);
				read_enable : in std_logic;
				write_enable : in std_logic;
				data_in			: in std_logic_vector(15 downto 0);
				data_out 		: out std_logic_vector(15 downto 0);
				busy_flag		: out std_logic;
				mem_address 	: out std_logic_vector(22 downto 0);
				mem_data		: inout std_logic_vector (15 downto 0);
				mem_oe			: out std_logic;
				mem_we			: out std_logic;
				mem_adv	: out std_logic;
				mem_clk	: out std_logic;
				mem_ub		: out std_logic;
				mem_lb		: out std_logic;
				mem_ce		: out std_logic;
				mem_cre	: out std_logic;
				mem_wait	: out std_logic						
		);
end component;


-- component used to test memory operations
component mem_tester is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           data_to_mem : out  STD_LOGIC_VECTOR (15 downto 0);
           addr_to_mem : out  STD_LOGIC_VECTOR (22 downto 0);
           data_to_leds : out  STD_LOGIC_VECTOR (7 downto 0);
           data_from_mem : in  STD_LOGIC_VECTOR (15 downto 0);
			  mem_read_enable : out std_logic;
			  mem_write_enable : out std_logic;
           mem_busy : in  STD_LOGIC);
end component;



--signal sig_switches : std_logic_vector(7 downto 0);
	signal sig_pbs : std_logic_vector(4 downto 0);
	signal sig_ldg : std_logic;
	signal sig_led : std_logic;
	signal sig_mem_address : std_logic_vector(22 downto 0);
	signal sig_mem_read_enable : std_logic;
	signal sig_mem_write_enable : std_logic;
	signal sig_mem_data_in			: std_logic_vector(15 downto 0);
	signal sig_mem_data_out 		: std_logic_vector(15 downto 0);
	signal sig_mem_busy	:std_logic;
	
begin	
--	par_wait <= '0'; 
	sig_pbs <= '0' & pbs;
	
	my_dpimref : dpimref
      port map( mclk => clkT,
                pdb    => par_data,
                astb     => par_ast,
                dstb     => par_dst,
                pwr   => par_wr,
					 pwait => par_wait,
					 rgSwt => switches,
					 rgBtn => sig_pbs,
					 btn => switches(0),
					 ldg => sig_ldg,
					 led => sig_led
		);
	 
	my_memory : memory
		port map (	clk => clkT,
						reset => sig_pbs(0), -- reset = push button 0
						address	=>	sig_mem_address,
						read_enable => sig_mem_read_enable,
						write_enable => sig_mem_write_enable,
						data_in	=> sig_mem_data_in,		
						data_out => sig_mem_data_out,
						busy_flag => sig_mem_busy,
						mem_address => mem_addr,
						mem_data	=> mem_data,
						mem_oe => mt_oe,
						mem_we => mt_we,
						mem_adv => mt_adv,
						mem_clk => mt_clk,
						mem_ub	=> mt_ub,
						mem_lb	=> mt_lb,
						mem_ce	=> mt_cf,
						mem_cre	=> mt_cre,
						mem_wait => mt_wait							
		);
	 
	 my_memory_tester : mem_tester
		port map (	clk => clkT,
						reset => sig_pbs(0),
						data_to_mem => sig_mem_data_in,
						addr_to_mem => sig_mem_address,
						data_to_leds => leds,
						data_from_mem => sig_mem_data_out,
						mem_read_enable => sig_mem_read_enable,
						mem_write_enable => sig_mem_write_enable,
						mem_busy => sig_mem_busy
		);
	 
	 
	 --leds <= switches;

end Structural;

