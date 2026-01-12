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
        when 5 => rst_n_tb <= '1';

        -- ============================================================
        -- 1. TEST BASE
        -- ============================================================
        when START_CYCLE => 
             din_tb <= std_logic_vector(to_signed(0, N));

        -- ============================================================
        -- 2. TEST "DEAD ZONE" (Differenze minime)
        -- ============================================================
        
        -- Caso A: Differenza = +1 (Dead Zone)
        when START_CYCLE + (L * 1) => 
             din_tb <= std_logic_vector(to_signed(1, N));

        -- Caso B: Differenza = +2
        when START_CYCLE + (L * 2) => 
             din_tb <= std_logic_vector(to_signed(3, N));

        -- Caso C: Differenza = +3
        when START_CYCLE + (L * 3) => 
             din_tb <= std_logic_vector(to_signed(6, N));

        -- Caso D: Differenza PERFETTA (+4)
        when START_CYCLE + (L * 4) => 
             din_tb <= std_logic_vector(to_signed(10, N));

        -- ============================================================
        -- 3. TEST PRECISIONE NEGATIVA
        -- ============================================================
        
        -- Caso E: Piccola discesa (-1)
        when START_CYCLE + (L * 5) => 
             din_tb <= std_logic_vector(to_signed(9, N));

        -- Caso F: Discesa Perfetta (-4)
        when START_CYCLE + (L * 6) => 
             din_tb <= std_logic_vector(to_signed(5, N));

        -- ============================================================
        -- 4. TEST STRESS
        -- ============================================================
        
        -- Vai molto giù (-100)
        when START_CYCLE + (L * 7) => 
             din_tb <= std_logic_vector(to_signed(-100, N));
        
        -- Vai molto su (+100)
        when START_CYCLE + (L * 8) => 
             din_tb <= std_logic_vector(to_signed(100, N));

        -- Torna a zero
        when START_CYCLE + (L * 9) => 
             din_tb <= std_logic_vector(to_signed(0, N));

        -- ============================================================
        -- 5. LIMITI ESTREMI
        -- ============================================================
        -- Max Positivo
        when START_CYCLE + (L * 10) => 
             din_tb <= std_logic_vector(to_signed(32767, N));
        
        -- Max Negativo
        when START_CYCLE + (L * 11) => 
             din_tb <= std_logic_vector(to_signed(-32768, N));

        -- Fine
        when START_CYCLE + (L * 15) => 
             run_simulation <= '0';

        when others => null;

      end case;

      clock_cycle := clock_cycle + 1;
      
    end if;
  end process;


end architecture;