LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY test_er_1octet IS
END test_er_1octet;

ARCHITECTURE behavior OF test_er_1octet IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT er_1octet
    PORT(
        clk : IN  std_logic;
        reset : IN  std_logic;
        en : IN  std_logic;
        miso : IN  std_logic;
        busy : OUT  std_logic;
        sclk : OUT  std_logic;
        mosi : OUT  std_logic;
        din : IN  std_logic_vector(7 downto 0);
        dout : OUT  std_logic_vector(7 downto 0)
    );
    END COMPONENT;


    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal en : std_logic := '0';
    signal miso : std_logic := '0';
    signal din : std_logic_vector(7 downto 0) := (others => '0');

    --Outputs
    signal busy : std_logic;
    signal sclk : std_logic;
    signal mosi : std_logic;
    signal dout : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: er_1octet PORT MAP (
        clk => clk,
        reset => reset,
        en => en,
        miso => miso,
        busy => busy,
        sclk => sclk,
        mosi => mosi,
        din => din,
        dout => dout
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
    cmd: process
    begin
        -- hold reset state for 100 ns.
        wait for clk_period*2;
        reset <= '1';
        wait for clk_period*5;

        for i in 0 to 3 loop
            en <= '1';
            din <= (i => '1', others => '0');
            wait for clk_period*1.5;
            en <= '0';
            din <= (others => '0');
            wait until busy = '0';
        end loop;
        wait;
    end process;

    slave_output: process
        variable output : std_logic_vector(7 downto 0) := (0 => '1', 2 => '1', 5 => '1', others => '0');
    begin
        wait for clk_period*5;

        for i in 0 to 3 loop
            for j in 0 to 7 loop
                miso <= output(j);
                wait for clk_period*2;
            end loop;
        end loop;
    end process;
END;
