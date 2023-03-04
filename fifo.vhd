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
-- @version        1
-- @email          matt@matthewgilpin.com
-- @contact        matthewgilpin.com
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

architecture behavioural of fifo is 

shared variable writeCounter: integer := 0;
shared variable readCounter: integer := 0;

signal isFull : std_logic := '0';
signal isEmpty : std_logic := '1';

type ramType is array (d - 1 downto 0) of std_logic_vector(w - 1 downto 0);
shared variable RAM_STORE : ramType;


begin

HEAD_POINTER : process(clkWrite)
begin
    if rising_edge(clkWrite) then
        if rst = '1' then
            writeCounter := 0;
        else 
            if write = '1' and isFull = '0' then
                if (writeCounter + 1) = d then
                    writeCounter := 0;
                else 
                    writeCounter := writeCounter + 1;
                    RAM_STORE(writeCounter) := datIn;
                end if;
            end if;
        end if;    
    end if;
end process;
   
   
TAIL_POINTER : process(clkRead)
begin
    if rising_edge(clkRead) then
        if rst = '1' then
            readCounter := 0;
        else 
            if read = '1' and isEmpty = '0' then
                if (readCounter + 1) = d then
                    readCounter := 0;
                else 
                    readCounter := readCounter + 1;
                    datOut <= RAM_STORE(readCounter);
                end if;
            end if;
        end if;
    end if; 
end process;


SET_LIMITS : process(clkRead, clkWrite)
begin
    if rising_edge(clkRead) or rising_edge(clkWrite) then
        -- May need to account for lag -> +1
        if writeCounter = (readCounter) then
            isFull <= '0';
            isEmpty <= '1';
        else
            isFull <= '0';
            isEmpty <= '0';
        end if;
        
        if writeCounter > readCounter then            
            if (writeCounter - readCounter) = (d - 1) then 
                isFull <= '1';
            else 
                isFull <= '0';
            end if;
            
        elsif writeCounter < readCounter then            
            if (readCounter - writeCounter) = 1 then 
                isFull <= '1';
            else 
                isFull <= '0';
            end if;
        end if;
        
    end if;
end process;

full <= isFull;
empty <= isEmpty;


end behavioural;