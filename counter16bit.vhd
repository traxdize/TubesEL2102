-- Code untuk counter 16 bit
-- Membuat counter dari 0 hingga 255
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter16bit is
    port(
        En : in std_logic;
        Res : in std_logic;
        Clk : in std_logic;
        Count : out integer;
    );
end counter16bit;

architecture behavioral of counter16bit is
    signal Count_temp : integer range 0 to 255 := 0;
begin
    process(Clk)
    begin
        if rising_edge(Clk) then
            if (Res = '1') then
                Count_temp <= 0;
            else
                if (En = '1') then
                    Count_temp <= Count_temp + 1;
                end if;
            end if;
        end if;
    end process;
    Count <= Count_temp;
end architecture behavioral;