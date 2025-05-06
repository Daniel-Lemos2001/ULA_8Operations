library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 1-bit full adder block
entity fullAdder is
    port ( X : in STD_LOGIC;
           Y : in STD_LOGIC;
           Cin : in STD_LOGIC;
           S : out STD_LOGIC;
           Cout : out STD_LOGIC);
end fullAdder;

architecture Behavioral of fullAdder is 

begin
    
    S <= (X XOR Y) XOR Cin; 
    Cout <= (X AND Y) OR (X AND Cin) OR (Y AND Cin);
    
end Behavioral;





