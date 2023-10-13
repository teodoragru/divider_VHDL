library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity divider is
port(
	a : in std_logic_vector(31 downto 0);
	b : in std_logic_vector(15 downto 0);
	clk : in std_logic;
	reset : in std_logic;
	y_div : out std_logic_vector(15 downto 0) ;
	y_rem : out std_logic_vector(15 downto 0) ;
	y_valid : out std_logic
	);
end entity;

architecture beh of divider is
	type fsm_state_type is (idle, start, div);
	signal fsm_state, next_fsm_state : fsm_state_type; 
	
	signal shift_reg : std_logic_vector(32 downto 0) := (others => '0');
	signal a_reg : std_logic_vector(31 downto 0);
	signal b_reg : std_logic_vector(15 downto 0);
	signal partial_sub : std_logic_vector(16 downto 0);
	signal result_bit : std_logic;
	signal shift_cnt : std_logic_vector(4 downto 0);
	

begin
	
	
	fsm_change_state: 
		process(clk, reset) is
			begin 
				if (reset = '1') then
					fsm_state <= idle;
				elsif (rising_edge(clk)) then
					fsm_state <= next_fsm_state;
				end if;
			end process;
	
	next_fsm_state_logic:
		process(clk, shift_reg, b_reg, fsm_state, shift_cnt, a, b) is
			begin
				case fsm_state is
					when idle =>
						if((a_reg /= a) or (b_reg /= b)) then
							next_fsm_state <= start;
						else
							next_fsm_state <= idle;
						end if;
					when start =>
						next_fsm_state <= div;
					when div =>
						if(unsigned(shift_cnt) = 16) then
							next_fsm_state <= idle;
							--y_div <= shift_reg(15 downto 0);
							--y_rem <= shift_reg(32 downto 17);
						else 
							next_fsm_state <= div;
						end if;
					when others =>
						next_fsm_state <= idle;
				end case;
			end process;

	shift_cnt_logic: process(reset, clk) is
		begin
			if (reset = '1') then
				shift_cnt <= (others => '0');
			elsif (rising_edge(clk)) then
				if (fsm_state = div) then
					if (unsigned(shift_cnt) < 16) then
						shift_cnt <= std_logic_vector(unsigned(shift_cnt) + 1);
					end if;
				elsif (fsm_state = idle) then
					shift_cnt <= (others => '0');
				end if;
			end if;
		end process;
		
	shift_reg_logic: process(reset, clk) is
	begin
		if (reset = '1') then
			shift_reg <= (others => '0');
			a_reg <= (others => '0');
			b_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			if (fsm_state = div) then
				shift_reg <= partial_sub(15 downto 0) & shift_reg(15 downto 0)& result_bit;
			elsif(fsm_state = start) then
				a_reg <= a;
				b_reg <= b;
				shift_reg <= '0' & a;
--			else
--				
			end if;
		end if;
	end process;
	
	partial_sub_logic: 
		process(shift_reg, b_reg) is 
			begin
				if(fsm_state = div) then
					if (unsigned(shift_reg(32 downto 16)) >= unsigned('0' & b_reg)) then
						partial_sub <= std_logic_vector(unsigned(shift_reg(32 downto 16)) - unsigned('0' & b_reg));
						result_bit <= '1';
					else
						partial_sub <= shift_reg(32 downto 16);
						result_bit <= '0';
					end if;
				else 
					partial_sub <= (others => '0');
					result_bit <= '0';
				end if;
			end process;
--		
--	output_logic:
--		process(clk) is
--			begin
--				if(rising_edge(clk)) then
--					if(fsm_state = div) then
--						y_div_pom <= (y_div_pom(14 downto 0)) & result_bit;
--						y_valid <= '0';
--					else
--						y_valid <= '1';
--					end if;
--				end if;
--			end process;
			
		--y_div <= shift_reg(32 downto 17);
		--y_rem <= shift_reg(15 downto 0);
		output_logic: process (reset, fsm_state) is
		begin
			if (reset = '1') then
				y_div <= (others => '0');
				y_rem <= (others => '0');
				y_valid <= '0';
			else
				if (fsm_state = idle) then
					if (unsigned(shift_cnt) = 16) then
						y_div <= shift_reg(15 downto 0);
						y_rem <= shift_reg(32 downto 17);
						y_valid <= '1';
					else
						y_valid <= '0';
					end if;
				else
					y_valid <= '0';
				end if;
			end if;
		end process;
end architecture;