--------------------------------------------------------------------------------
-- FIFO
-- This memory stores bytes of information in a first-in, first-out format.
--
-- IO DESCRIPTION
--      w: Width of word
--      d: Depth of FIFO
--  clk: clock input
--  rst: Reset fifo - does not clear values as such, just resets the pointers
--  read: Set to 1 when wanting to read from the FIFO.
--  write: Set to 1 to write to the FIFO
--  full: Asserted when the FIFO buffer is full
--  empty: Asserted when the FIFO buffer is empty
--  datIn: Data to write to the RAM
--  datOut: Data to read to the RAM
--           
-- @author         Matthew Gilpin
-- @version        1.1
-- @email          matt@matthewgilpin.com
-- @contact        matthewgilpin.com
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo is
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
end fifo;

architecture Behavioral of fifo is

type ramType is array (d - 1 downto 0) of std_logic_vector(w - 1 downto 0);
shared variable RAM : ramType;

signal isFull : std_logic := '0';
signal isEmpty : std_logic := '1';

shared variable headCounter : integer := 0;
shared variable tailCounter : integer := 0;


begin

HEAD_POINTER : process (clkWrite, rst)
begin
    if rst = '1' then 
        headCounter := 0;
    elsif clkWrite'event and clkWrite = '1' then
        if write = '1' and isFull = '0' then
            headCounter := headCounter + 1;
            
            if headCounter = d then
                headCounter := 0;                
            end if;
        end if;        
    end if;
end process;

TAIL_POINTER : process (clkRead, rst)
begin
    if rst = '1' then 
        tailCounter := 0;
    elsif clkRead'event and clkRead = '1' then
        if read = '1' and isEmpty = '0' then
            tailCounter := tailCounter + 1;
            
            if tailCounter = d then
                tailCounter := 0;                
            end if;
        end if;        
    end if;
end process;

SET_LIMITS : process(clkRead, clkWrite)
begin
    if (clkRead'event and clkRead = '1') or (clkWrite'event and clkWrite = '1') then
        if headCounter = tailCounter then
            isFull <= '0';
            isEmpty <= '1';
        else 
            isFull <= '0';
            isEmpty <= '0';
        end if;
        
        if headCounter > tailCounter then            
            if (headCounter - tailCounter) = (d - 1) then 
                isFull <= '1';
            else 
                isFull <= '0';
            end if;
            
        elsif headCounter < tailCounter then            
            if (tailCounter - headCounter) = 1 then 
                isFull <= '1';
            else 
                isFull <= '0';
            end if;
        end if;
    end if;
end process;


WRITE_RAM : process(clkWrite)
begin
    if clkWrite'event and clkWrite = '1' then
        RAM(headCounter) := datIn;
    end if;
end process;

READ_RAM : process(clkRead)
begin
    if clkRead'event and clkRead = '1' then
        datOut <= RAM(tailCounter);
    end if;
end process;

full <= isFull;
empty <= isEmpty;

end Behavioral;
