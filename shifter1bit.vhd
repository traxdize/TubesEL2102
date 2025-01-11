-- Blok Shift right / divider 2 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter1bit is
	port(
		input_data  : in signed(31 downto 0);
		output_data	: out signed(31 downto 0)
	);
end shifter1bit;

architecture behavioral of shifter1bit is
begin
	output_data <= shift_right(signed(input_data), 1);
end behavioral;