LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY TestSum IS
END TestSum;

ARCHITECTURE behavior OF TestSum IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT master_sum
    PORT(
        clk : IN  std_logic;
        reset : IN  std_logic;
        en : IN  std_logic;
        miso : IN  std_logic;
        sclk : OUT  std_logic;
        mosi : OUT  std_logic;
        ss : OUT  std_logic;
        busy : OUT  std_logic;
        carry : OUT  std_logic;
        e1 : IN  std_logic_vector(7 downto 0);
        e2 : IN  std_logic_vector(7 downto 0);
        s : OUT  std_logic_vector(7 downto 0)
    );
    END COMPONENT;

    COMPONENT slave_sum
    PORT(
        sclk : in std_logic;
        mosi : in std_logic;
        miso : out std_logic;
        ss : in std_logic
    );
    END COMPONENT;

    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal en : std_logic := '0';
    signal e1 : std_logic_vector(7 downto 0) := (others => '0');
    signal e2 : std_logic_vector(7 downto 0) := (others => '0');

    -- Internal signals
    signal miso : std_logic := '0';
    signal mosi : std_logic;
    signal sclk : std_logic;
    signal ss : std_logic;

    -- Outputs
    signal busy : std_logic;
    signal carry : std_logic;
    signal s : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: master_sum PORT MAP (
        clk => clk,
        reset => reset,
        en => en,
        miso => miso,
        sclk => sclk,
        mosi => mosi,
        ss => ss,
        busy => busy,
        carry => carry,
        e1 => e1,
        e2 => e2,
        s => s
    );

    -- Instantiate the slave module
    slave: slave_sum PORT MAP (
        sclk => sclk,
        mosi => mosi,
        miso => miso,
        ss => ss
    );
    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
        variable vect : std_logic_vector(7 downto 0) := (others => '0');
    begin
        -- hold reset state for 100 ns.
        wait for 100 ns;
        
        reset <= '1';
        wait for clk_period*10;
        for i in 0 to 7 loop
            vect(i) := '1';
            e1 <= vect;
            e2 <= (7 => '1', others => '0');
            en <= '1';
            wait for clk_period*2;
            en <= '0';
            wait until busy = '0';
        end loop;  
        wait;
    end process;
END;
