library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity slicer is
    port (
        input_data  : in std_logic_vector(47 downto 0); -- Wide input data
        output_data : out std_logic_vector(31 downto 0) -- Sliced output (47 downto 16)
    );
end entity slicer;

architecture behavioral of slicer is
begin
    process(input_data)
    begin
        output_data <= input_data(47 downto 16);
    end process;
end architecture behavioral;
