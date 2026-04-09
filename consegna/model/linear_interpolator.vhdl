library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity linear_interpolator is
    generic (
        N : integer := 16
    );
    port (
        clk   : in  std_logic;
        rst_n : in  std_logic;
        din   : in  std_logic_vector(N-1 downto 0);
        dout  : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture rtl of linear_interpolator is
    
    signal r_y_curr       : signed(N-1 downto 0);
    signal r_y_next       : signed(N-1 downto 0);
    signal r_counter      : unsigned(1 downto 0);
    signal r_dout         : signed(N-1 downto 0);

    signal s_sign_bit      : std_logic; 
    signal s_counter_signed : signed(2 downto 0);
    signal s_next_ext     : signed(N downto 0);
    signal s_curr_ext     : signed(N downto 0);
    signal s_diff         : signed(N downto 0);
    signal s_mult_res     : signed(N+3 downto 0);
    signal s_div_res      : signed(N+3 downto 0);
    signal s_curr_final_ext : signed(N+3 downto 0);
    signal s_sum_final      : signed(N+3 downto 0);
begin

    -- PROCESSO SEQUENZIALE

    process (clk, rst_n)
    begin
        if (rst_n = '0') then
            r_y_curr       <= (others => '0');
            r_y_next       <= (others => '0');
            r_counter      <= "00";
            r_dout         <= (others => '0');
        elsif (rising_edge(clk)) then
     
            if (r_counter = "11") then
                r_counter <= r_counter + 1;
                r_y_curr <= r_y_next;
                r_y_next <= signed(din);
            else
                r_counter <= r_counter + 1;
            end if;
            
    
            r_dout <= s_sum_final(N-1 downto 0);
        end if;
    end process;


    -- Combianatoria
    
    s_counter_signed <= signed('0' & std_logic_vector(r_counter));

   
    s_next_ext <= r_y_next(N-1) & r_y_next; 
    s_curr_ext <= r_y_curr(N-1) & r_y_curr;
    s_diff     <= s_next_ext - s_curr_ext;

    s_mult_res <= s_diff * s_counter_signed;

    s_sign_bit <= s_mult_res(N+3);

  
    s_div_res <= s_sign_bit & s_sign_bit & s_mult_res(N+3 downto 2);

   
    s_curr_final_ext <= r_y_curr(N-1) & r_y_curr(N-1) & r_y_curr(N-1) & r_y_curr(N-1) & r_y_curr;
    s_sum_final      <= s_curr_final_ext + s_div_res;

    dout <= std_logic_vector(r_dout);

end architecture;