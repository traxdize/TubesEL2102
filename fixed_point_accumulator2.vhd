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
    -- Component declaration for 16-bit multiplier
    component Multiplier16Bit is
        Port ( 
            a : in signed(15 downto 0);
            b : in signed(15 downto 0);
            product : out signed(31 downto 0)
        );
    end component;

    -- Component declaration for 32-bit full adder
    component full_adder_32bit is
        Port ( 
            a      : in  SIGNED (31 downto 0);
            b      : in  SIGNED (31 downto 0);
            cin    : in  STD_LOGIC;
            sum    : out SIGNED (31 downto 0);
            cout   : out STD_LOGIC
        );
    end component;

    type state_type is (IDLE, COMPUTE_PRODUCTS, ACCUMULATE, FINISHED);
    signal state    : state_type := IDLE;
    signal index    : integer range 0 to 7 := 0;
    signal products : product_array;
    signal sum      : signed (31 downto 0) := (others => '0');
    signal temp_result  : signed(31 downto 0) := (others => '0');
    signal done_reg     : std_logic := '0';
    signal mult_result  : signed(31 downto 0);
    signal adder_cout   : std_logic;
    signal adder_sum    : signed(31 downto 0);

begin
    -- Instantiate the 16-bit multiplier
    mult_16bit: Multiplier16Bit port map (
        a => x(index),
        b => y(index),
        product => mult_result
    );

    -- Instantiate the 32-bit full adder
    adder_32bit: full_adder_32bit port map (
        a    => sum,
        b    => products(index),
        cin  => '0',
        sum  => adder_sum,
        cout => adder_cout
    );

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
                    products(index) <= mult_result;
                    if index = 7 then
                        index <= 0;
                        state <= ACCUMULATE;
                    else
                        index <= index + 1;
                    end if;
                when ACCUMULATE =>
                    sum <= adder_sum;
                    if index = 7 then
                        state <= FINISHED;
                        temp_result <= adder_sum;
                    else
                        index <= index + 1;
                    end if;
                when FINISHED =>
                    result <= shift_right(temp_result, 2);
                    done_reg <= '1';
                    if reset = '0' then
                        state <= IDLE;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;