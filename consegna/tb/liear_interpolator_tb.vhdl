library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  


entity tb_linear_interpolator is
end entity;

architecture testbench of tb_linear_interpolator is

  -----------------------------------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------------------------------
  component linear_interpolator is
    generic (
      N : integer := 16
    );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;
      din   : in std_logic_vector(N-1 downto 0);
      dout  : out std_logic_vector(N-1 downto 0)
    );
  end component;

  -----------------------------------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------------------------------
  constant N : integer := 16;
  constant T_clk : time := 10 ns;
  constant L : integer := 4; -- Fattore interpolazione
  constant START_CYCLE : integer := 10;

  -----------------------------------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------------------------------
  signal clk_tb : std_logic := '0';
  signal rst_n_tb : std_logic := '0';
  signal run_simulation : std_logic := '1';
  signal din_tb : std_logic_vector(N-1 downto 0) := (others => '0');
  signal dout_tb : std_logic_vector(N-1 downto 0);

begin

  -- Generazione Clock
  clk_tb <= (not(clk_tb) and run_simulation) after T_clk / 2;

  -- Istanza DUT
  i_DUT: linear_interpolator
  generic map ( N => N )
  port map (
    clk   => clk_tb,
    rst_n => rst_n_tb,
    din   => din_tb,
    dout  => dout_tb
  );

  -- Processo Stimoli Sincrono
  stimuli: process(clk_tb)
    variable clock_cycle : integer := 0;
  begin
    if (rising_edge(clk_tb)) then
      
      case (clock_cycle) is
        when 5 => 
             rst_n_tb <= '1';
             din_tb <= std_logic_vector(to_signed(1000, N));

        -- ============================================================
        -- TEST 1-10: Rampe positive graduate (SAFE)
        -- ============================================================
        when START_CYCLE + (L * 0) => 
             din_tb <= std_logic_vector(to_signed(0, N));
        when START_CYCLE + (L * 1) => 
             din_tb <= std_logic_vector(to_signed(1000, N));
        when START_CYCLE + (L * 2) => 
             din_tb <= std_logic_vector(to_signed(2000, N));
        when START_CYCLE + (L * 3) => 
             din_tb <= std_logic_vector(to_signed(3000, N));
        when START_CYCLE + (L * 4) => 
             din_tb <= std_logic_vector(to_signed(4000, N));
        when START_CYCLE + (L * 5) => 
             din_tb <= std_logic_vector(to_signed(5000, N));

        -- ============================================================
        -- TEST 11-15: Discese (SAFE)
        -- ============================================================
        when START_CYCLE + (L * 6) => 
             din_tb <= std_logic_vector(to_signed(4000, N));
        when START_CYCLE + (L * 7) => 
             din_tb <= std_logic_vector(to_signed(3000, N));
        when START_CYCLE + (L * 8) => 
             din_tb <= std_logic_vector(to_signed(2000, N));
        when START_CYCLE + (L * 9) => 
             din_tb <= std_logic_vector(to_signed(1000, N));
        when START_CYCLE + (L * 10) => 
             din_tb <= std_logic_vector(to_signed(0, N));

        -- ============================================================
        -- TEST 16-20: Transizioni negative (SAFE)
        -- ============================================================
        when START_CYCLE + (L * 11) => 
             din_tb <= std_logic_vector(to_signed(-1000, N));
        when START_CYCLE + (L * 12) => 
             din_tb <= std_logic_vector(to_signed(-2000, N));
        when START_CYCLE + (L * 13) => 
             din_tb <= std_logic_vector(to_signed(-3000, N));
        when START_CYCLE + (L * 14) => 
             din_tb <= std_logic_vector(to_signed(-4000, N));
        when START_CYCLE + (L * 15) => 
             din_tb <= std_logic_vector(to_signed(-5000, N));

        -- ============================================================
        -- TEST 21-25: Risalite (SAFE)
        -- ============================================================
        when START_CYCLE + (L * 16) => 
             din_tb <= std_logic_vector(to_signed(-4000, N));
        when START_CYCLE + (L * 17) => 
             din_tb <= std_logic_vector(to_signed(-3000, N));
        when START_CYCLE + (L * 18) => 
             din_tb <= std_logic_vector(to_signed(-2000, N));
        when START_CYCLE + (L * 19) => 
             din_tb <= std_logic_vector(to_signed(-1000, N));
        when START_CYCLE + (L * 20) => 
             din_tb <= std_logic_vector(to_signed(0, N));

        -- ============================================================
        -- TEST 26: Salto medio (SAFE)
        -- ============================================================
        when START_CYCLE + (L * 21) => 
             din_tb <= std_logic_vector(to_signed(10000, N));

        -- ============================================================
        -- TEST 27: Salto negativo medio (SAFE)
        -- ============================================================
        when START_CYCLE + (L * 22) => 
             din_tb <= std_logic_vector(to_signed(-10000, N));

        -- ============================================================
        -- TEST 28: Ritorno a zero
        -- ============================================================
        when START_CYCLE + (L * 23) => 
             din_tb <= std_logic_vector(to_signed(0, N));

        -- ============================================================
        -- TEST 29-32: Dead zone (SAFE)
        -- ============================================================
        when START_CYCLE + (L * 24) => 
             din_tb <= std_logic_vector(to_signed(1, N));
        when START_CYCLE + (L * 25) => 
             din_tb <= std_logic_vector(to_signed(3, N));
        when START_CYCLE + (L * 26) => 
             din_tb <= std_logic_vector(to_signed(6, N));
        when START_CYCLE + (L * 27) => 
             din_tb <= std_logic_vector(to_signed(10, N));

        -- ============================================================
        -- TEST 33: OVERFLOW TEST - Vicino al limite positivo
        -- Transizione: 100 -> 20000 (diff=19900, *3 = 59700 > 32767)
        -- ============================================================
        when START_CYCLE + (L * 28) => 
             din_tb <= std_logic_vector(to_signed(100, N));
        when START_CYCLE + (L * 29) => 
             din_tb <= std_logic_vector(to_signed(20000, N));

        -- ============================================================
        -- TEST 34: OVERFLOW TEST - Limite massimo positivo
        -- Transizione: 0 -> 32767 (diff=32767, *3 = 98301 >> overflow!)
        -- ============================================================
        when START_CYCLE + (L * 30) => 
             din_tb <= std_logic_vector(to_signed(0, N));
        when START_CYCLE + (L * 31) => 
             din_tb <= std_logic_vector(to_signed(32767, N));

        -- ============================================================
        -- TEST 35: OVERFLOW TEST ESTREMO - Max pos -> Max neg
        -- Transizione: 32767 -> -32768 (diff=-65535 >> overflow massimo!)
        -- ============================================================
        when START_CYCLE + (L * 32) => 
             din_tb <= std_logic_vector(to_signed(-32768, N));

        -- ============================================================
        -- TEST 36: Recupero - ritorno a valori normali
        -- ============================================================
        when START_CYCLE + (L * 33) => 
             din_tb <= std_logic_vector(to_signed(0, N));

        -- ============================================================
        -- TEST 37: UNDERFLOW TEST - Grande salto negativo
        -- Transizione: 0 -> -25000 (diff=-25000, *3 = -75000 < -32768)
        -- ============================================================
        when START_CYCLE + (L * 34) => 
             din_tb <= std_logic_vector(to_signed(-25000, N));

        -- Fine simulazione - più cicli per osservare ultimo test
        when START_CYCLE + (L * 37) => 
             run_simulation <= '0';

        when others => null;

      end case;

      clock_cycle := clock_cycle + 1;
      
    end if;
  end process;

  -- =============================================================
  -- MONITOR PROCESS - Stampa valori per debug
  -- =============================================================
  monitor: process(clk_tb)
    variable clock_cycle : integer := 0;
  begin
    if (rising_edge(clk_tb) and rst_n_tb = '1') then
      report "Cycle " & integer'image(clock_cycle) & 
             " | din=" & integer'image(to_integer(signed(din_tb))) &
             " | dout=" & integer'image(to_integer(signed(dout_tb)));
      clock_cycle := clock_cycle + 1;
    end if;
  end process;


end architecture;