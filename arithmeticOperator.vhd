library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity arithmeticOperator is
    port ( A : in STD_LOGIC_VECTOR(3 downto 0);
           B : in STD_LOGIC_VECTOR(3 downto 0);
           sel : in STD_LOGIC_VECTOR(2 downto 0);
           Cout: out STD_LOGIC;
           overFlow: out STD_LOGIC;
           arith_out : out STD_LOGIC_VECTOR(3 downto 0));
end arithmeticOperator;

architecture Behavioral of arithmeticOperator is 

    component fullAdder 
        port ( X : in STD_LOGIC;
               Y : in STD_LOGIC;
               Cin : in STD_LOGIC;
               S : out STD_LOGIC;
               Cout : out STD_LOGIC);
    end component;
    
-- Auxiliary signals for intermediate operations
signal sum, carry, sub, carrySub, sInc, carryInc, notB, sShift, sAbsolute, carryAbsolute, opAbsolute, notA: STD_LOGIC_VECTOR(3 downto 0);
signal Cin1: STD_LOGIC;

begin 

    notA <= not A;
    notB <= not B;

    Cin1 <= '0' when sel = "000" else 
            '1';--(others => '0');

    -- 2's complement addition
    -- Cascade of 1-bit full adder blocks, where the Cout of one block is used as the Cin of the next
    FA0: fullAdder port map (X => A(0), Y => B(0), Cin => Cin1    , S => sum(0), Cout => carry(0));
    FA1: fullAdder port map (X => A(1), Y => B(1), Cin => carry(0), S => sum(1), Cout => carry(1));
    FA2: fullAdder port map (X => A(2), Y => B(2), Cin => carry(1), S => sum(2), Cout => carry(2));
    FA3: fullAdder port map (X => A(3), Y => B(3), Cin => carry(2), S => sum(3), Cout => carry(3));

    -- 2's complement subtraction
    -- Using the same cascade logic, input B is inverted and increased by 1 (Cin of the first adder block is set to high)
    FB0: fullAdder port map (X => A(0), Y => notB(0), Cin => Cin1       , S => sub(0), Cout => carrySub(0));
    FB1: fullAdder port map (X => A(1), Y => notB(1), Cin => carrySub(0), S => sub(1), Cout => carrySub(1));
    FB2: fullAdder port map (X => A(2), Y => notB(2), Cin => carrySub(1), S => sub(2), Cout => carrySub(2));
    FB3: fullAdder port map (X => A(3), Y => notB(3), Cin => carrySub(2), S => sub(3), Cout => carrySub(3));
     
    -- Increment by 1
    FD0: fullAdder port map (X => A(0), Y => '0' , Cin => Cin1       , S => sInc(0), Cout => carryInc(0));
    FD1: fullAdder port map (X => A(1), Y => '0' , Cin => carryInc(0), S => sInc(1), Cout => carryInc(1));
    FD2: fullAdder port map (X => A(2), Y => '0' , Cin => carryInc(1), S => sInc(2), Cout => carryInc(2));
    FD3: fullAdder port map (X => A(3), Y => '0' , Cin => carryInc(2), S => sInc(3), Cout => carryInc(3));

    -- Absolute value: increments by 1 when receiving a negative number
    FC0: fullAdder port map (X => notA(0), Y => '0', Cin => Cin1          , S => opAbsolute(0), Cout => carryAbsolute(0));
    FC1: fullAdder port map (X => notA(1), Y => '0', Cin => carryAbsolute(0), S => opAbsolute(1), Cout => carryAbsolute(1));
    FC2: fullAdder port map (X => notA(2), Y => '0', Cin => carryAbsolute(1), S => opAbsolute(2), Cout => carryAbsolute(2));
    FC3: fullAdder port map (X => notA(3), Y => '0', Cin => carryAbsolute(2), S => opAbsolute(3), Cout => carryAbsolute(3));


    -- Right shift (division by 2)
    sShift <= '0' & A(3 downto 1);
     
    -- Logic to detect overflow
    overFlow <= carry(2) XOR carry(3) when sel = "000" else
                carrySub(2) XOR carrySub(3) when sel = "001" else
                carryInc(2) XOR carryInc(3) when sel = "011" else
                carryAbsolute(2) XOR carryAbsolute(3) when sel = "111" else
                '0';--(others => '0');

    Cout <= carry(3) when sel = "000" else
            carrySub(3) when sel = "001" else
            carryInc(3) when sel = "011" else
            carryAbsolute(3) when sel = "111" else
            '0';--(others => '0');

    -- If input A is positive, the absolute output equals the input. However, if A is negative, the output returns A inverted and incremented by 1
    sAbsolute <= A when A(3) = '0' else
               opAbsolute;
    
    -- The output of this block depends on the selected operation
    arith_out <= sum when sel = "000" else
                sub when sel = "001" else
                sShift when sel = "010" else
                sInc when sel = "011" else
                sAbsolute when sel = "111" else
                "0000";--(others => '0');

end Behavioral;