----------------------------------------------------------------------------------
-- Engineer: Matthew Gilpin
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Nexys7Lock is
    Port ( 
        SW : in STD_LOGIC_VECTOR(7 downto 0);
        AN : out STD_LOGIC_VECTOR(7 downto 0); -- anode of ssd
        BTNL : in STD_LOGIC;
        BTNR : in STD_LOGIC;
        BTNU : in STD_LOGIC;
        CLK100MHZ: in STD_LOGIC;
        LED : out STD_LOGIC_VECTOR(1 downto 0);
        LED16_B: out std_logic;
        LED16_G: out std_logic;
        LED16_R: out std_logic;
        ssdc : out STD_LOGIC_VECTOR(6 downto 0)
        );
end Nexys7Lock;

architecture Behavioral of Nexys7Lock is

type ssdSelect is (D0, D1, D2, D3);
signal currentSsd : ssdSelect := D0;

component locktop_sync port(
    DigitA : in STD_LOGIC_VECTOR (3 downto 0);
    DigitB : in STD_LOGIC_VECTOR (3 downto 0);
    SSD1 : out STD_LOGIC_VECTOR (7 downto 0);
    SSD2 : out STD_LOGIC_VECTOR (7 downto 0);
    SSD3 : out STD_LOGIC_VECTOR (7 downto 0);
    SSD4 : out STD_LOGIC_VECTOR (7 downto 0);
    Lock : out STD_LOGIC;
    Unlock : out STD_LOGIC;
    Reset, Button1, Button2, clkIn : in std_logic 
);
end component;

constant counter_max : natural := 100000; -- 100mhz / desired = value, desired 10khz => 100 000khz/ 10khz - 10000
signal clock_counter : natural range 0 to counter_max;

signal SSD1_display : std_logic_vector(7 downto 0) := "00000000";
signal SSD2_display : std_logic_vector(7 downto 0) := "00000000";
signal SSD3_display : std_logic_vector(7 downto 0) := "00000000";
signal SSD4_display : std_logic_vector(7 downto 0) := "00000000";


begin

lock: locktop_sync
    port map (
        DigitA => SW(7 downto 4),
        DigitB => SW(3 downto 0),
        Button1 => BTNL,
        Button2 => BTNR,
        Reset => BTNU,
        unlock => LED(0),
        lock => LED(1),
        SSD1 => SSD1_display,
        SSD2 => SSD2_display,
        SSD3 => SSD3_display,
        SSD4 => SSD4_display,
        clkIn => CLK100MHZ
    );
    
ssd1: process(CLK100MHZ, currentSsd) is 
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

LED16_R <= BTNR;
LED16_G <= BTNL;
LED16_B <= BTNU;



end Behavioral;
