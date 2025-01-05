-- register16bit.vhd
-- berfungsi sebagai register 16 bit yang dapat menyimpan data dengan sinyal enable dan reset.
-- input:   A       data 16 bit
--          En      sinyal pengaktifan (1 untuk aktif)
--          Res     sinyal reset, mengubah isi menjadi 0 (1 untuk reset)
--          Clk     sinyal clock
-- output:  Data    output data yang tersimpan

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity
entity register16bit is
    port	(
                A		: in    std_logic_vector (15 downto 0);	-- data A
                En		: in	std_logic;								-- sinyal Enable
                Res	    : in	std_logic;								-- sinyal Reset
                Clk	    : in	std_logic;								-- sinyal Clock
                Data	: out   std_logic_vector (15 downto 0)		-- luaran data
            );
end register16bit;

-- Architecture
architecture rtl of register16bit is
    -- sinyal untuk data yang akan disimpan. default bernilai 0.
    signal v_data	:	std_logic_vector (15 downto 0) := "0000000000000000";

begin
    -- proses dengan mengamati sinyal clock
    process (Clk)
    begin
        -- jika sinyal clock berubah dan bernilai 1
        if rising_edge (Clk) then
            -- check sinyal reset. jika bernilai 1, maka ...
            if (Res = '1') then
                -- data diubah menjadi 0.
                v_data <= "0000000000000000";
            else
            -- sinyal reset bernilai 0.
                -- jika sinyal enable bernilai 1, maka simpan data
                if(En = '1') then
                    -- data A disimpan ke sinyal data
                    v_data <= A;
                end if;
            end if;
        end if;
    end process;
    -- sinyal data dimasukkan ke luaran Data.
    Data <= v_data;
end rtl;
