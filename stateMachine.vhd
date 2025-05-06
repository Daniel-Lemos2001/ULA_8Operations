library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity stateMachine is
    port ( switches: in STD_LOGIC_VECTOR(3 downto 0);
           confirm: in STD_LOGIC;
           clock: in STD_LOGIC;
           reset: in STD_LOGIC;
           LED: out STD_LOGIC_VECTOR(7 downto 0));
end stateMachine;

architecture Behavioral of stateMachine is 

    component ALU
        port ( A : in STD_LOGIC_VECTOR(3 downto 0);
               B : in STD_LOGIC_VECTOR(3 downto 0);
               sel : in STD_LOGIC_VECTOR(2 downto 0);
               Cout: out STD_LOGIC;
               overFlow: out STD_LOGIC;
               zero: out STD_LOGIC;
               negative: out STD_LOGIC;
               alu_out : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

-- State identification
type states is (selectOp, waitSel, receiveA, waitA, receiveB, waitB, showResult);

-- ":=" indicates the initial value of the variable
signal currentState : states := selectOp;

-- The following variables help with the user-code interface (intermediate signals)
-- If nothing is done, these signals receive an initial value (zero)
signal inputA, inputB, output : STD_LOGIC_VECTOR (3 downto 0) := "0000";
signal opSel: STD_LOGIC_VECTOR (2 downto 0) := "000";
signal counter: STD_LOGIC_VECTOR (29 downto 0) := (others => '0');
signal overFlowInt, CoutInt, zeroInt, negativeInt: STD_LOGIC := '0';

begin

process(clock, reset) 
begin

    -- If reset is activated, return to operation selection state
    if (reset = '1') then
        currentState <= selectOp;
    elsif rising_edge(clock) then
        case currentState is 
            -- First state selects the desired operation
            when selectOp =>
                opSel <= switches(2 downto 0);
                LED(7 downto 5) <= "001";
                LED(4 downto 3) <= "00";
                LED(2 downto 0) <= switches(2 downto 0);
                -- To enter the values for the chosen operation, user must confirm selection
                if (confirm = '1') then
                    currentState <= waitSel;
                end if;
            -- Debounce state: counter maintains state for a time. Meanwhile, selected operation is shown on LEDs
            when waitSel => 
                -- The three leftmost LEDs show state identification (wait states don't participate in this count)
                LED(7 downto 5) <= "001";
                LED(4 downto 3) <= "00";
                LED(2 downto 0) <= opSel;
                counter <= counter + 1;
                if (counter = "000101101101111110000110010010") then 
                    counter <= (others => '0');
                    currentState <= receiveA;
                end if;
            -- This state receives input A    
            when receiveA => 
                inputA <= switches;
                LED(7 downto 5) <= "010";
                LED(4) <= '0';
                LED(3 downto 0) <= switches;
                -- User must confirm selection
                if (confirm = '1') then
                    currentState <= waitA;
                end if;
            -- Debounce state: counter maintains state for a time. Meanwhile...
            when waitA => 
                LED(7 downto 5) <= "010";
                LED(4) <= '0';
                LED(3 downto 0) <= inputA;
                counter <= counter + 1;
                if (counter = "000101101101111110000110010010") then
                    counter <= (others => '0');
                    -- If the selected operation has the second least significant bit equal to 1, it means it's a single-input operation, so the input B state is skipped
                    if (opSel(1) = '1') then
                        currentState <= showResult;
                    else
                        currentState <= receiveB;
                    end if;
                end if;
            -- This state receives input B 
            when receiveB =>
                inputB <= switches;
                LED(7 downto 5) <= "011";
                LED(4) <= '0';
                LED(3 downto 0) <= switches;
                -- User must confirm selection
                if (confirm = '1') then
                    currentState <= waitB;
                end if;
            -- For parallelism, this state waits the same time as other debounce states
            when waitB => 
                LED(7 downto 5) <= "011";
                LED(4) <= '0';
                LED(3 downto 0) <= inputB;
                counter <= counter + 1;
                if (counter = "000101101101111110000110010010") then 
                    counter <= (others => '0');
                    currentState <= showResult;
                end if;
            -- The final state shows the result and flags. Can only exit this state with reset
            when showResult =>
                LED(7) <= overFlowInt;
                LED(6) <= CoutInt;
                LED(5) <= negativeInt;
                LED(4) <= zeroInt;
                LED(3 downto 0) <= output;
            when others =>
                null;
        end case;
    end if;
end process;

U1: ALU port map (A => inputA, B => inputB, sel => opSel, Cout => CoutInt, overFlow => overFlowInt, 
                  zero => zeroInt, negative => negativeInt, alu_out => output);
end Behavioral;