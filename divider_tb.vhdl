library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_divider is
end tb_divider;

architecture test of tb_divider is
	signal reset : std_logic := '1';
	signal clk : std_logic := '0';
	signal a: std_logic_vector(31 downto 0);
   signal b: std_logic_vector(15 downto 0);
   signal y_div: std_logic_vector(15 downto 0) := (others => '0');
   signal y_rem: std_logic_vector(15 downto 0) := (others => '0');
   signal y_valid: std_logic ;
   constant Tclk: time := 20 ns;
 
 begin

	clk_gen: clk <= not clk after Tclk/2;

	dut: entity work.divider port map(clk=>clk, reset=> reset, a=>a, b=>b, y_rem=>y_rem, y_valid=>y_valid, y_div => y_div);
	
	stimulus: process
	begin
		reset <= '0';
		a <= std_logic_vector(to_signed(256, a'length));
		b <= std_logic_vector(to_signed(8, b'length));
		wait for 20*Tclk;
		b <= std_logic_vector(to_signed(17, b'length));
		wait for 20*Tclk;
		b <= std_logic_vector(to_signed(19, a'length));
		wait for 20*Tclk;
		b <= std_logic_vector(to_signed(10, b'length));
		wait for 20*Tclk;
		wait;
	
	
	
	end process;
end test;