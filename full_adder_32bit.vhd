library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity full_adder_32bit is
    Port ( 
        a      : in  SIGNED (31 downto 0);
        b      : in  SIGNED (31 downto 0);
        cin    : in  STD_LOGIC;           -- Diubah ke STD_LOGIC
        sum    : out SIGNED (31 downto 0);
        cout   : out STD_LOGIC            -- Diubah ke STD_LOGIC
    );
end full_adder_32bit;

architecture Behavioral of full_adder_32bit is
begin
    process(a, b, cin)
        variable temp_sum : signed(32 downto 0);
        variable a_ext   : signed(32 downto 0);
        variable b_ext   : signed(32 downto 0);
        variable cin_ext : signed(32 downto 0);
    begin
        -- Extend input vectors dengan sign bit
        a_ext := signed(a(31) & a);
        b_ext := signed(b(31) & b);
        
        -- Convert cin ke signed dan extend
        cin_ext := (others => '0');
        if cin = '1' then
            cin_ext(0) := '1';
        end if;
        
        -- Perform addition
        temp_sum := a_ext + b_ext + cin_ext;
        
        -- Assign outputs
        sum <= temp_sum(31 downto 0);
        cout <= temp_sum(32);
    end process;
end Behavioral;