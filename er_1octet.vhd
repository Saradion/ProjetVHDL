library IEEE;
use IEEE.std_logic_1164.all;

entity er_1octet is
    port (
		  clk, reset : in std_logic;
    	  en, miso : in std_logic;
		  busy, sclk, mosi : out std_logic;
        din : in std_logic_vector(7 downto 0);
		  dout : out std_logic_vector(7 downto 0)
    );
end er_1octet;

architecture arch_er_1octet of er_1octet is
    type t_state is (waiting, reading, writing);
    signal state : t_state := waiting;
begin
    main : process(clk, reset)
	     variable tmp_register : std_logic_vector(7 downto 0) := (others => '0');
        variable cpt : natural := 7;
    begin
       if reset = '0' then
	    sclk <= '0';
	    busy <= '0';
	    mosi <= '0';
		 state <= waiting;
	    tmp_register := (others => '0');
	    dout <= tmp_register;
	elsif rising_edge(clk) then
	    case state is
	       when waiting =>
			 if (en = '1') then
		    tmp_register := din;
		    cpt := 7;
		    busy <= '1';
		    mosi <= tmp_register(cpt);
		    state <= reading;
			 end if;
		when reading =>
		    tmp_register(cpt) := miso;
		    sclk <= '1';
		    state <= writing;
		when writing =>
		    if (cpt /= 0) then
		        cpt := cpt - 1;
			mosi <= tmp_register(cpt);
			sclk <= '0';
			state <= reading;
	            else
		        dout <= tmp_register;
		        busy <= '0';
		        sclk <= '0';
				  mosi <= '0';
		        state <= waiting;
		    end if;
            end case;
        end if;
    end process;
		    
end arch_er_1octet;

