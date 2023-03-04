--------------------------------------------------------------------------------
-- Test FIFO
-- This simulation verifies that a FIFO buffer works correctly. 
--
-- Note: this is not an exhaustive test, neither is this an automated one.
--           
-- @author         Matthew Gilpin
-- @version        1
-- @email          matt@matthewgilpin.com
-- @contact        matthewgilpin.com
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_fifo is
--  Port ( );
end test_fifo;

architecture Behavioral of test_fifo is

component fifo
    Generic (
        w : integer := 8; -- width
        d : integer := 64 -- depth
    );
    Port (  
        clkRead           :   in  std_logic;
        clkWrite          :   in  std_logic;
        rst               :   in  std_logic;
        read              :   in  std_logic;
        write             :   in  std_logic;
        full              :   out  std_logic;
        empty             :   out  std_logic;
        datIn             :   in  std_logic_vector(w - 1 downto 0);
        datOut            :   out  std_logic_vector(w - 1 downto 0) := (others => '0')
     );
end component;


signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal read : std_logic := '0';
signal write : std_logic := '0';
signal full : std_logic := '0';
signal empty : std_logic := '0';
signal dataIn : std_logic_vector(7 downto 0) := (others => '0');
signal dataOut : std_logic_vector(7 downto 0) := (others => '0');

signal testSignal : std_logic_vector(95 downto 0) := x"efcdab9078563412efbeadde";

begin

fifo_component : fifo
port map (
    clkRead  => clk,
    clkWrite => clk,
    rst => rst,
    read => read,
    write => write,
    full  => full,
    empty => empty,
    datIn  => dataIn,
    datOut => dataOut
);

test: process
begin
    -- Reset FIFO
    rst <= '1';
    wait for 1ps;
    clk <= '1';
    wait for 1ps;
    rst <= '0';
    clk <= '0';
    wait for 1ps;
    
    -- Test Write
    for i in 0 to 11 loop
        dataIn <= testSignal((i + 1) * 8 - 1 downto i * 8);
        write <= '1';
        wait for 1ps;
        clk <= '1';
        wait for 1ps;
        write <= '0';
        clk <= '0';
        wait for 1ps;       
    end loop;
    
    -- Test Read
    for i in 0 to 12 loop
        read <= '1';
        wait for 1ps;
        clk <= '1';
        wait for 1ps;
        read <= '0';
        clk <= '0';
        wait for 1ps;       
    end loop;
    
    
    -- Full test
    for j in 1 to 6 loop 
        for i in 0 to 11 loop
            dataIn <= testSignal((i + 1) * 8 - 1 downto i * 8);
            write <= '1';
            wait for 1ps;
            clk <= '1';
            wait for 1ps;
            write <= '0';
            clk <= '0';
            wait for 1ps;       
        end loop;
    end loop;
    
    wait;
    
end process;

end Behavioral;
