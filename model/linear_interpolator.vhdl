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

    -- REGISTRI
    signal r_y_curr       : signed(N-1 downto 0);
    signal r_y_next       : signed(N-1 downto 0);
    signal r_k_2bit       : unsigned(1 downto 0); 
    signal r_first_sample : std_logic;

    -- SEGNALI MATEMATICI
    
    -- Costanti manuali
    signal s_sign_bit      : std_logic; -- Il bit di segno per lo shift

    -- K esteso
    signal s_k_3bit_signed : signed(2 downto 0);

    -- Differenza
    signal s_next_ext     : signed(N downto 0);
    signal s_curr_ext     : signed(N downto 0);
    signal s_diff         : signed(N downto 0);

    -- Moltiplicazione
    signal s_mult_res     : signed(N+3 downto 0);

    -- Divisione (Manuale)
    signal s_div_res      : signed(N+3 downto 0);

    -- Somma Finale
    signal s_curr_final_ext : signed(N+3 downto 0);
    signal s_sum_final      : signed(N+3 downto 0);

begin

    -- =============================================================
    -- PROCESSO SEQUENZIALE
    -- =============================================================
    process (clk, rst_n)
    begin
        if (rst_n = '0') then
            r_y_curr       <= (others => '0');
            r_y_next       <= (others => '0');
            r_k_2bit       <= "00";
            r_first_sample <= '1';
        elsif (rising_edge(clk)) then
            if (r_k_2bit = "11") then
                r_k_2bit <= "00";
                if (r_first_sample = '1') then
                    r_y_curr       <= (others => '0');
                    r_y_next       <= signed(din);
                    r_first_sample <= '0';
                else
                    r_y_curr <= r_y_next;
                    r_y_next <= signed(din);
                end if;
            else
                r_k_2bit <= r_k_2bit + 1;
            end if;
        end if;
    end process;

    -- =============================================================
    -- DATA PATH (Tutto Manuale)
    -- =============================================================

    -- 1. K SIGNED (Manuale: "0" & k)
    s_k_3bit_signed <= signed('0' & std_logic_vector(r_k_2bit));

    -- 2. DIFFERENZA (Manuale: MSB & val)
    s_next_ext <= r_y_next(N-1) & r_y_next; 
    s_curr_ext <= r_y_curr(N-1) & r_y_curr;
    s_diff     <= s_next_ext - s_curr_ext;

    -- 3. MOLTIPLICAZIONE
    s_mult_res <= s_diff * s_k_3bit_signed;

    -- 4. DIVISIONE MANUALE (SHIFT RIGHT ARITMETICO)
    -- L'MSB del risultato della moltiplicazione è all'indice N+3.
    s_sign_bit <= s_mult_res(N+3);

    -- Costruiamo il risultato spostando i bit e replicando il segno in alto.
    -- Bit scartati: i due più bassi (1 e 0).
    -- Bit tenuti: dal 2 fino all'ultimo (N+3).
    -- Riempimento: due copie del bit di segno in cima.
    s_div_res <= s_sign_bit & s_sign_bit & s_mult_res(N+3 downto 2);

    -- 5. SOMMA (Estensione Manuale)
    s_curr_final_ext <= r_y_curr(N-1) & r_y_curr(N-1) & r_y_curr(N-1) & r_y_curr(N-1) & r_y_curr;
    s_sum_final      <= s_curr_final_ext + s_div_res;

    -- 6. USCITA (Slicing Manuale)
    dout <= std_logic_vector(s_sum_final(N-1 downto 0));

end architecture;