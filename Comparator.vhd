library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Comparator Entity
entity comparator is -- Membandingkan dua nilai masukan (A dan B) dan memberikan output logika apakah A lebih besar dari B.

    Port ( clk : in STD_LOGIC;                   -- Clock signal-- clk 
           reset : in STD_LOGIC;                 -- Reset signal untuk menginisialisasi modul
           A : in STD_LOGIC_VECTOR(15 downto 0); -- First input to compare
           B : in STD_LOGIC_VECTOR(15 downto 0); -- Second input to compare
           compare_out : out STD_LOGIC);         -- Compare_out : Output logika, bernilai '1' jika A > B, atau '0' jika sebaliknya
end comparator;

architecture Behavioral of comparator is
    signal compare_result : STD_LOGIC; -- Internal comparison result
begin
    process(clk, reset) -- membandingkan nilai A dan B setiap siklus clock dan memberikan hasil perbandingan pada Compare_out.

    begin
        if reset = '1' then
            compare_result <= '0';
        elsif rising_edge(clk) then
            if SIGNED(A) > SIGNED(B) then
                compare_result <= '1';
            else
                compare_result <= '0';
            end if;
        end if;
    end process;

    compare_out <= compare_result; -- map the internal signal to the output port
end Behavioral;
