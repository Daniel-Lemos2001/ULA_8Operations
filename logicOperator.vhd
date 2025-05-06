library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity logicOperator is
    port ( A : in STD_LOGIC_VECTOR(3 downto 0);
           B : in STD_LOGIC_VECTOR(3 downto 0);
           sel : in STD_LOGIC_VECTOR(2 downto 0);
           logic_out : out STD_LOGIC_VECTOR(3 downto 0));
end logicOperator;

architecture Behavioral of logicOperator is 

-- Auxiliary signals to enable the operations
signal sAND, sOR, sMirror: STD_LOGIC_VECTOR(3 downto 0);


begin 
    
    sAND <= A AND B; 
    sOR <= A OR B;

    -- Input number mirroring is done by concatenating bits from least significant to most significant
    sMirror <= A(0) & A(1) & A(2) & A(3);
    

    logic_out <= sAND when sel = "100" else 
               sOR when sel = "101" else
               sMirror when sel = "110" else 
               "0000";--(others => '0');

end Behavioral;