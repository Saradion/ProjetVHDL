library IEEE;
use IEEE.std_logic_1164.all;

entity master_sum is
    port (
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
	 signal sending : std_logic_vector(7 downto 0);
	 signal receiving : std_logic_vector(7 downto 0);
	 signal comp_busy : std_logic;
	 signal comp_en : std_logic;
begin
    comp1 : er_1octet port map ( clk, reset, comp_en, miso, comp_busy , sclk, mosi, receiving, sending );
	 
	 main : process(clk, reset)
	     variable timer_slave : natural := 5;
		  variable timer_down : natural := 2;
		  variable buffer1 : std_logic_vector(7 downto 0);
		  variable buffer2 : std_logic_vector(7 downto 0);
	 begin
	     if reset = '0' then
	         busy <= '0';
		      ss <= '1';
		      carry <= '0';
		      s <= (others => '0');
        elsif rising_edge(clk) then
		      case state is
				when waiting => 
				    if en = '1' then
					     busy <= '1';
					     buffer1 := e1;
						  buffer2 := e2;
					     ss <= '0';
						  timer_slave := 5;
					     state <= waiting_for_slave;
				    end if;
				when waiting_for_slave =>
				    timer_slave := timer_slave - 1;
				    if timer_slave = 1 then
					     comp_en <= '1';
						  sending <= buffer1;
					     state <= first;
					 end if;
			   when first =>
				    if comp_busy = '0' then
					     s <= receiving;
						  state <= downtime;
						  comp_en <= '0';
						  timer_down <= 2;
					 end if;
				when downtime =>
				    timer_down <= timer_down - 1;
					 if timer_down = 1 then
					     sending <= buffer2;
						  comp_en <= '1';
						  state <= second;
					 end if;
				when second =>
				    if comp_busy = '0' then
					     carry <= receiving(0);
						  state <= waiting;
						  comp_en <= '0';
						  busy <= '0';
						  ss <= '1';
					 end if;
				end case;
		  end if;
    end process;
end arch_master_sum;