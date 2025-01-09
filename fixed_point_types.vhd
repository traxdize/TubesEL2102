library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fixed_point_types is
    type signed_array is array(0 to 7) of signed(15 downto 0);
    type product_array is array (0 to 7) of signed(31 downto 0);
end package;

package body fixed_point_types is
end package body;