library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_32bit is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        D    : in  STD_LOGIC_VECTOR(31 downto 0);
        Q    : out STD_LOGIC_VECTOR(31 downto 0)
    );
end register_32bit;

architecture Behavioral of register_32bit is
    signal reg : STD_LOGIC_VECTOR(31 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            reg <= D;
        end if;
    end process;
    Q <= reg;
end Behavioral;
