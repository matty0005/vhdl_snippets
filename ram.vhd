--------------------------------------------------------------------------------
-- RAM
-- This an implementation of dual port BRAM based on the Xilinx documentation: 
-- https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Initializing-Block-RAM-Verilog
--
-- IO DESCRIPTION
--  clk: clock input
--  addrA: Address of memory for Port A
--  addrB: Address of memory for Port B
--  enA: Enable port A
--  enB: Enable port B
--  writeEn: Set to '1' to write to RAM
--  datIn: Data to write to the RAM
--  datOut: Data to read to the RAM
--           
-- @author         Matthew Gilpin
-- @version        1
-- @email          matt@matthewgilpin.com
-- @contact        matthewgilpin.com
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
 use IEEE.std_logic_unsigned.all; 
 
entity ram is
    Generic (
        w : integer := 8; -- width
        d : integer := 64 -- depth
    );
    Port (  clk     :   in  std_logic;
            addrA   :   in  std_logic_vector(15 downto 0) := (others => '0'); -- limits to 65536 values
            addrB   :   in  std_logic_vector(15 downto 0) := (others => '0'); -- limits to 65536 values
            readEn  :   in  std_logic;
            writeEn :   in  std_logic;
            datIn   :   in  std_logic_vector(w - 1 downto 0);
            datOut  :   out std_logic_vector(w - 1 downto 0) := (others => '0')
         );
end ram;

architecture behavioural of ram is 

type ramType is array (d - 1 downto 0) of std_logic_vector(w - 1 downto 0);
shared variable RAM_STORE : ramType;

begin

    WRITE: process(clk)
    begin
        if rising_edge(clk) then
            if writeEn = '1' then
                RAM_STORE(conv_integer(addrA)) := datIn;
            end if;
        end if;
    end process;

    READ: process(clk)
    begin
        if rising_edge(clk) then
            if readEn = '1' then
                datOut <= RAM_STORE(conv_integer(addrB));
            end if;
        end if;
    end process;

end behavioural;