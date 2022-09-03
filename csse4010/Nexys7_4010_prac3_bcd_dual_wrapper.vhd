----------------------------------------------------------------------------------
-- Engineer: Matthew Gilpin
-- 
-- Create Date: 03.09.2022 12:37:52
-- Module Name: nexys7_bcd_dual_wrapper - Behavioral
-- Target Devices: Nexys A7-100T
-- Description: A wrapper for the csse4010 task 2 in prac3 - a dual digit BCD adder
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nexys7_bcd_dual_wrapper is
    Port ( 
        SW : in STD_LOGIC_VECTOR(15 downto 0);
        AN : out STD_LOGIC_VECTOR(7 downto 0); -- anode of ssd
        BTNL : in STD_LOGIC; -- carry in
        CLK100MHZ: in STD_LOGIC;
        ssdc : out STD_LOGIC_VECTOR(6 downto 0)
    );
end nexys7_bcd_dual_wrapper;

architecture Behavioral of nexys7_bcd_dual_wrapper is

component bcdadder_dual port (
    a : in STD_LOGIC_VECTOR (7 downto 0);
    b : in STD_LOGIC_VECTOR (7 downto 0);
    c_in : in STD_LOGIC;
    c_out : out STD_LOGIC;
    sum : out std_logic_vector(11 downto 0)
);
end component;

component sevenSegDisp port (
    value : in STD_LOGIC_VECTOR (3 downto 0);
    display : out STD_LOGIC_VECTOR (6 downto 0)
);
end component;

type ssdSelect is (D0, D1, D2, D3);
signal currentSsd : ssdSelect := D0;

constant counter_max : natural := 100000; -- 100mhz / desired = value, desired 10khz => 100 000khz/ 10khz - 10000
signal clock_counter : natural range 0 to counter_max;

signal SSD1_display : std_logic_vector(7 downto 0) := "00000000";
signal SSD2_display : std_logic_vector(7 downto 0) := "00000000";
signal SSD3_display : std_logic_vector(7 downto 0) := "00000000";
signal SSD4_display : std_logic_vector(7 downto 0) := "00000000";

signal bcd_sum : std_logic_vector(11 downto 0) := "000000000000";


begin


adder : bcdadder_dual 
    port map (
        a => SW(15 downto 8),
        b => SW(7 downto 0),
        c_in => BTNL,
        c_out => open,
        sum => bcd_sum
    );
    
    
ssd3 : sevenSegDisp 
    port map (
        value => bcd_sum(11 downto 8),
        display => SSD2_display(6 downto 0)
    );
    
ssd2 : sevenSegDisp 
    port map (
        value => bcd_sum(7 downto 4),
        display => SSD3_display(6 downto 0)
    );
ssd1 : sevenSegDisp 
    port map (
        value => bcd_sum(3 downto 0),
        display => SSD4_display(6 downto 0)
    );
ssd4 : sevenSegDisp 
    port map (
        value => "0000",
        display => SSD1_display(6 downto 0)
    );
    

ssd_control: process(CLK100MHZ, currentSsd) is 
begin
    if rising_edge(CLK100MHZ) then
        if clock_counter = counter_max then
            clock_counter <= 0;
            
            -- Select the next display to display to.
            case currentSsd is 
                when D3 => currentSsd <= D0;
                when D2 => currentSsd <= D3;
                when D1 => currentSsd <= D2;
                when D0 => currentSsd <= D1;
            end case;
            
            
            case currentSsd is 
                when D3 => AN <= not "00001000";
                    ssdc <= not SSD1_display(6 downto 0);
                when D2 => AN <= not "00000100";
                    ssdc <= not SSD2_display(6 downto 0);
                when D1 => AN <= not "00000010";
                    ssdc <= not SSD3_display(6 downto 0);
                when D0 => AN <= not "00000001";
                    ssdc <= not SSD4_display(6 downto 0);
            end case;
      
        else 
            clock_counter <= clock_counter + 1;
        end if;
    end if;
end process;

end Behavioral;
