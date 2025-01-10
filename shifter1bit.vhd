library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter1bit is
    port (
        input_data  : in std_logic_vector(15 downto 0);
        output_data : out std_logic_vector(15 downto 0)
    );
end entity shifter1bit;

architecture behavioral of shifter1bit is
begin
    output_data <= std_logic_vector(shift_right(unsigned(input_data), 1));
end architecture behavioral;
