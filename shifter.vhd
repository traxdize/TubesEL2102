-- Blok Shift right / divider 2 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
	port(
		input_data  : in std_logic_vector(15 downto 0);
		output_data	: out std_logic_vector(15 downto 0)
	);
end shifter;

architecture behavioral of shifter is
begin
	output_data <= std_logic_vector(shift_right(unsigned(input_data), 1));
end behavioral;