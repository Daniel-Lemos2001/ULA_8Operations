library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU is
    port ( A : in STD_LOGIC_VECTOR(3 downto 0);
           B : in STD_LOGIC_VECTOR(3 downto 0);
           sel : in STD_LOGIC_VECTOR(2 downto 0);
           Cout: out STD_LOGIC;
           overFlow: out STD_LOGIC;
           zero: out STD_LOGIC;
           negative: out STD_LOGIC;
           alu_out : out STD_LOGIC_VECTOR(3 downto 0));
end ALU;

architecture Behavioral of ALU is 

    component logicOperator 
        port ( A : in STD_LOGIC_VECTOR(3 downto 0);
               B : in STD_LOGIC_VECTOR(3 downto 0);
               sel : in STD_LOGIC_VECTOR(2 downto 0);
               logic_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    component arithmeticOperator
        port ( A : in STD_LOGIC_VECTOR(3 downto 0);
               B : in STD_LOGIC_VECTOR(3 downto 0);
               sel : in STD_LOGIC_VECTOR(2 downto 0);
               Cout: out STD_LOGIC;
               overFlow: out STD_LOGIC;
               arith_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

signal logic_out, arith_out, alu_out_internal : STD_LOGIC_VECTOR (3 downto 0);
signal overFlow_internal : STD_LOGIC;

begin

    -- Instantiate the blocks that perform logical or arithmetic operations based on user selection
    U0: logicOperator port map (A => A, B => B, sel => sel, logic_out => logic_out);
    U1: arithmeticOperator port map (A => A, B => B, sel => sel, Cout => Cout, overFlow => overFlow_internal, arith_out => arith_out);

    
    alu_out_internal <= arith_out when sel(2) = '0' or sel = "111" else
        logic_out;

    -- If there's overflow, the condition changes
    zero <= '1' when overFlow_internal = '0' and alu_out_internal = "0000" else
            '0' when overFlow_internal = '1' and alu_out_internal = "0000" else
            '0';
    
    -- If there's overflow, the condition changes
    negative <= overFlow_internal XOR alu_out_internal(3); 
    
    overFlow <= overFlow_internal;

    alu_out <= alu_out_internal;
        
end Behavioral;