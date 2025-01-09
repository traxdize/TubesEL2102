library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplier32Bit is
    Port ( 
        a       : in  STD_LOGIC_VECTOR(31 downto 0);    -- Input A (32-bit)
        b       : in  STD_LOGIC_VECTOR(31 downto 0);    -- Input B (32-bit)
        result  : out STD_LOGIC_VECTOR(63 downto 0)     -- Output hasil (64-bit)
    );
end Multiplier32Bit;

architecture Behavioral of Multiplier32Bit is
    signal a_signed   : SIGNED(31 downto 0);            -- Sinyal internal bertipe signed untuk A
    signal b_signed   : SIGNED(31 downto 0);            -- Sinyal internal bertipe signed untuk B
    signal mult_result: SIGNED(63 downto 0);            -- Hasil perkalian internal
begin
    -- Mengubah input vector menjadi bertipe signed
    a_signed <= SIGNED(a);
    b_signed <= SIGNED(b);
    
    -- Melakukan perkalian bertanda (kombinasi)
    mult_result <= a_signed * b_signed;
    
    -- Mengonversi hasil kembali ke std_logic_vector untuk output
    result <= STD_LOGIC_VECTOR(mult_result);

end Behavioral;
