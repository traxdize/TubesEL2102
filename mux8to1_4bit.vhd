-- mux8to1_4bit.vhd
-- Deskripsi    : berfungsi untuk memilih salah satu dari 8 data 4 bit yang masuk dengan selector
--                berupa 4 bit sel yang menentukan data yang akan menjadi output
--                jika sel bernilai 0001, maka data_1 yang diteruskan ke luaran, dst.
-- input        : data_1 sampai data_8    data 4 bit
--                Sel                     selector 4 bit
-- output       : Data    output data yang tersimpan

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity
entity mux8to1_4bit is
    port	(
                data_1	: in    std_logic_vector (3 downto 0);	-- data 1
                data_2	: in	std_logic_vector (3 downto 0);	-- data 2
                data_3	: in	std_logic_vector (3 downto 0);	-- data 3
                data_4	: in	std_logic_vector (3 downto 0);	-- data 4
                data_5	: in	std_logic_vector (3 downto 0);	-- data 5
                data_6	: in	std_logic_vector (3 downto 0);	-- data 6
                data_7	: in	std_logic_vector (3 downto 0);	-- data 7
                data_8	: in	std_logic_vector (3 downto 0);	-- data 8
                Sel	    : in	std_logic_vector (3 downto 0);	-- selector
                Data	: out   std_logic_vector (3 downto 0) 	-- luaran data
            );
end mux8to1_4bit;

-- Architecture
architecture rtl of mux8to1_4bit is
begin
    -- process yang mengamati perubahan di selector
    process (Sel, data_1, data_2, data_3, data_4, data_5, data_6, data_7, data_8)
    begin
        -- jika selector bernilai 1, maka data yang diteruskan ke luaran.
        if    (Sel = 0001) then
                Data <= data_1;
        elsif (Sel = 0010) then
                Data <= data_2;
        elsif (Sel = 0011) then
                Data <= data_3;
        elsif (Sel = 0100) then
                Data <= data_4;
        elsif (Sel = 0101) then
                Data <= data_5;
        elsif (Sel = 0110) then
                Data <= data_6;
        elsif (Sel = 0111) then
                Data <= data_7;
        elsif (Sel = 1000) then
                Data <= data_8; 
        else
        -- jika selector tidak valid, maka 0000 yang diteruskan ke luaran.
            Data <= 0000;
        end if;
    end process;
end rtl;