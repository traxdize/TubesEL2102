library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity demux_1to2_32bit is
    Port (
        D_in : in  STD_LOGIC_VECTOR(31 downto 0);
        sel  : in  STD_LOGIC;
        D_out1 : out STD_LOGIC_VECTOR(31 downto 0);
        D_out2 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end demux_1to2_32bit;

architecture Behavioral of demux_1to2_32bit is
begin
    process(D_in, sel)
    begin
        if sel = '0' then
            D_out1 <= D_in;
            D_out2 <= (others => '0');
        else
            D_out1 <= (others => '0');
            D_out2 <= D_in;
        end if;
    end process;
end Behavioral;
