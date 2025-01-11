library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Fixed_Point_Types.all;

entity fixed_point_accumulator is
    Port(
        clk             : in std_logic;
        reset           : in std_logic;
        start           : in std_logic;
        x               : in signed_array;
        y               : in signed_array;
        result          : out signed(31 downto 0);
        done            : out std_logic
    );
end fixed_point_accumulator;

architecture Behavioral of fixed_point_accumulator is
    type state_type is (IDLE, COMPUTE_PRODUCTS, ACCUMULATE, FINISHED);
    signal state    : state_type := IDLE;
    signal index    : integer range 0 to 7 := 0;
    signal products : product_array;
    signal sum      : signed (31 downto 0) := (others => '0');
    signal temp_result  : signed(31 downto 0) := (others => '0');
    signal done_reg     : std_logic := '0';

begin
    done <= done_reg;
    
    process(clk, reset)
    begin
        if reset = '0' then
            state <= IDLE;
            index <= 0;
            sum <= (others => '0');
            temp_result <= (others => '0');
            done_reg <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        state <= COMPUTE_PRODUCTS;
                    end if;
                    index <= 0;
                    sum <= (others => '0');
                    temp_result <= (others => '0');
                    done_reg <= '0';

                when COMPUTE_PRODUCTS =>
                    products(index) <= x(index) * y(index); -- 16 BIT MULTIPLIER
                    if index = 7 then
                        index <= 0;
                        state <= ACCUMULATE;
                    else
                        index <= index + 1;
                    end if;

                when ACCUMULATE =>
                    sum <= sum + products(index);
                    if index = 7 then
                        state <= FINISHED;
                        temp_result <= sum + products(index);  -- Include last product -- 32 BIT ADDER
                    else
                        index <= index + 1;
                    end if;
                
                when FINISHED =>
                    result <= shift_right(temp_result, 2); -- RIGHT SHIFTER 2 BIT
                    done_reg <= '1';  -- Set done to indicate completion
                    -- Stay in FINISHED state until reset goes low
                    if reset = '0' then
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;
