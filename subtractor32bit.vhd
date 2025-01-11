-- Subtractor 32 bit
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity subtractor32bit is
    port (
        A : in signed(31 downto 0);
        B : in signed(31 downto 0);
        Sum : out signed(31 downto 0)
    );
end entity subtractor32bit;

architecture behavioral of subtractor32bit is
    signal Sum_temp, A_temp, B_temp : signed(31 downto 0);
begin
    A_temp <= A;
    B_temp <= B;
    Sum_temp <= A_temp - B_temp;
    Sum <= signed(Sum_temp);
end architecture behavioral;