library IEEE;
use IEEE.std_logic_1164.all;

entity master_sum is
    port(
        clk, reset : in std_logic;
        en, miso : in std_logic;
        sclk, mosi, ss, busy, carry : out std_logic;
        e1, e2 : in std_logic_vector(7 downto 0);
        s : out std_logic_vector(7 downto 0)
    );
end master_sum;

architecture arch_master_sum of master_sum is
    component er_1octet
    port (
        clk, reset : in std_logic;
        en, miso : in std_logic;
        busy, sclk, mosi : out std_logic;
        din : in std_logic_vector(7 downto 0);
        dout : out std_logic_vector(7 downto 0)
    );
    end component;

    type t_state is (waiting, waiting_for_slave, first, downtime, second);
    signal state : t_state := waiting;
    signal din : std_logic_vector(7 downto 0);
    signal dout : std_logic_vector(7 downto 0);
    signal comp_busy : std_logic;
    signal comp_en : std_logic;
begin
    comp1 : er_1octet port map ( clk, reset, comp_en, miso, comp_busy , sclk, mosi, din, dout );

    main : process(clk, reset)
        variable timer : natural := 5;
        variable buffer1 : std_logic_vector(7 downto 0);
        variable buffer2 : std_logic_vector(7 downto 0);
    begin
        if reset = '0' then
            busy <= '0';
            ss <= '1';
            carry <= '0';
            s <= (others => '0');
				state <= waiting;
        elsif rising_edge(clk) then
            case state is
            when waiting =>
                if en = '1' then
                    busy <= '1';
                    buffer1 := e1;
                    buffer2 := e2;
                    ss <= '0';
                    timer := 5;
                    state <= waiting_for_slave;
                end if;
            when waiting_for_slave =>
				    if timer = 1 then
					     din <= buffer1;
						  comp_en <= '1';
						  timer := timer - 1;
				    elsif timer = 0 then
						  state <= first;
					 else
					     timer := timer - 1;
                end if;
            when first =>
				    comp_en <= '0';
                if comp_busy = '0' then
                    s <= dout;
                    state <= downtime;
                    timer := 2;
                end if;
            when downtime =>
				    if timer = 1 then
					     din <= buffer2;
						  comp_en <= '1';
						  timer := timer - 1;
                elsif timer = 0 then
                    state <= second;
					 else
					     timer := timer - 1;
                end if;
            when second =>
				    comp_en <= '0';
                if comp_busy = '0' then
                    carry <= dout(0);
                    state <= waiting;
                    busy <= '0';
                    ss <= '1';
                end if;
            end case;
        end if;
    end process;
end arch_master_sum;
