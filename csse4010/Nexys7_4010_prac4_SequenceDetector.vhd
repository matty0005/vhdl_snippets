----------------------------------------------------------------------------------
-- Engineer: Matthew Gilpin
-- 
-- Create Date: 09.09.2022 22:54:30
-- Module Name: SequenceDetectorWrapper - Behavioral
-- Description: The wrapper for the sequence detector.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SequenceDetectorWrapper is
    Port ( 
        BTNL, BTNC : in STD_LOGIC;
        CLK100MHZ: in STD_LOGIC;
        LED : out STD_LOGIC_VECTOR(1 downto 0)
    );        

end SequenceDetectorWrapper;

architecture Behavioral of SequenceDetectorWrapper is

constant counter_max : natural := 100000000; -- 100mhz / desired = value, desired = 1hz
constant counter_led : natural := 10000000; -- 100mhz / desired = value, desired = 10hz
signal clock_counter : natural range 0 to counter_max;

signal downscaled_clock : std_logic := '0';

component SequenceDetector is port (
    Clock, Input, Reset : in STD_LOGIC;
    z : out STD_LOGIC
);
end component;

begin

sd : SequenceDetector 
port map (
    Clock => downscaled_clock,
    reset => BTNC,
    Input => BTNL,
    z => LED(1)
);

control: process(CLK100MHZ, BTNL) is 
begin
    if rising_edge(CLK100MHZ) then
        if clock_counter = counter_led then
            LED(0) <= '0';        
            downscaled_clock <= '0';

        end if;
        
        if clock_counter = counter_max then
            clock_counter <= 0;
            LED(0) <= '1';
            downscaled_clock <= '1';
      
        else 
            clock_counter <= clock_counter + 1;
        end if;
    end if;
end process;

end Behavioral;
