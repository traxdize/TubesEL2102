library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplier16Bit is
    Port ( 
        a : in signed(15 downto 0);
        b   : in signed(15 downto 0);
        product     : out signed(31 downto 0)
    );
end Multiplier16Bit;

architecture Behavioral of Multiplier16Bit is
begin
    -- Perform signed multiplication
    product <= a * b;
end Behavioral;
