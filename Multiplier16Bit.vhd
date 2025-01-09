library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplier16Bit is
    Port ( 
        a       : in  STD_LOGIC_VECTOR(15 downto 0);    -- Input A (16-bit)
        b       : in  STD_LOGIC_VECTOR(15 downto 0);    -- Input B (16-bit)
        result  : out STD_LOGIC_VECTOR(31 downto 0)     -- Output hasil (32-bit)
    );
end Multiplier16Bit;

architecture Behavioral of Multiplier16Bit is
    signal a_signed   : SIGNED(15 downto 0);            -- Sinyal internal bertipe signed untuk A
    signal b_signed   : SIGNED(15 downto 0);            -- Sinyal internal bertipe signed untuk B
    signal mult_result: SIGNED(31 downto 0);            -- Hasil perkalian internal
begin
    -- Mengubah input vector menjadi signed
    a_signed <= SIGNED(a);
    b_signed <= SIGNED(b);
    
    -- Melakukan perkalian bertanda (kombinasi)
    mult_result <= a_signed * b_signed;
    
    -- Mengonversi hasil kembali ke std_logic_vector untuk output
    result <= STD_LOGIC_VECTOR(mult_result);

end Behavioral;
