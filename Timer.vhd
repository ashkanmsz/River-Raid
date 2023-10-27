library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;


entity Timer is
    Port ( Clk       : in  STD_LOGIC;
           Reset     : in  STD_LOGIC;
			  en        : out STD_LOGIC_VECTOR(3 downto 0);
			  sevensegO : out STD_LOGIC_VECTOR(7 downto 0);
           led       : out STD_LOGIC_VECTOR(7 downto 0);
			  start     : in  BOOLEAN;
			  SquareY   : in  std_logic_vector(9 downto 0);
			  SquareX   : in  std_logic_vector(9 downto 0);
			  BlockX1	: in  std_logic_vector(8 downto 0);
			  BlockX2	: in  std_logic_vector(8 downto 0);
			  BlockX3	: in  std_logic_vector(8 downto 0);
			  BlockX4	: in  std_logic_vector(8 downto 0);
			  BlockX5	: in  std_logic_vector(8 downto 0);
			  BlockY1	: in  std_logic_vector(8 downto 0);
			  BlockY2	: in  std_logic_vector(8 downto 0);
			  BlockY3	: in  std_logic_vector(8 downto 0);
			  BlockY4	: in  std_logic_vector(8 downto 0);
			  BlockY5	: in  std_logic_vector(8 downto 0);
			  shotX     : in  std_logic_vector(9 downto 0);
			  shotY     : in  std_logic_vector(9 downto 0);
			  finish1   : out boolean ;
			  finish2   : in boolean ;
			  booster   : out integer range 0 to 250000;
			  pushButton3: in std_logic ;
			  win       : out boolean
			  );
end Timer;

architecture Behavioral of Timer is

	signal counter1  : integer range 0 to 240000000:=0; -- manges secounds
	signal counter2  : integer range 0 to 240000:=0; -- manage enable
	signal counter3  : integer range 0 to 360000000:=0;
	signal yekan     : STD_LOGIC_VECTOR(3 downto 0):= "0001";-- yekAn
	signal dahgan 	  : STD_LOGIC_VECTOR(3 downto 0):= "0010";-- dahgAn
	signal sadgan    : STD_LOGIC_VECTOR(3 downto 0):= "0000";-- sadgAn
	signal hezargan  : STD_LOGIC_VECTOR(3 downto 0):= "0011";-- hezargAn
	signal en_tmp    : STD_LOGIC_VECTOR(3 downto 0):="0011";
	signal led_tmp   : STD_LOGIC_VECTOR(7 downto 0):= "00000000";
	signal finish_tmp: boolean := false; 
	signal booster_tmp: integer range 0 to 250000:=0; 
	signal BLOCKWIDTH: STD_LOGIC_VECTOR(7 downto 0) := "00100000";
	signal win_tmp   : boolean := false;

function sevenSeg( input : in std_logic_vector ) return std_logic_vector is 
variable output : std_logic_vector(7 downto 0);
begin
	if input = "0000" then output := x"c0";
	elsif input = "0001" then output := x"f9";
	elsif input = "0010" then output := x"a4";
	elsif input = "0011" then output := x"b0";
	elsif input = "0100" then output := x"99";
	elsif input = "0101" then output := x"92";
	elsif input = "0110" then output := x"82";
	elsif input = "0111" then output := x"f8";
	elsif input = "1000" then output := x"80";
	elsif input = "1001" then output := x"98";	
	elsif input = "1010" then output := x"88";
	elsif input = "1011" then output := x"83";
	elsif input = "1100" then output := x"c6";
	elsif input = "1101" then output := x"a1";
	elsif input = "1110" then output := x"86";
	elsif input = "1111" then output := x"8e";
	end if;
	return output;
end function sevenSeg;



begin

process(clk , reset )
begin
		if(reset= '1')then
		
			booster_tmp <= 0;
			counter3 <= 0;
		
		elsif(rising_edge(clk))then
		
			if start then
			
				counter3 <= counter3 + 1;
				
				if(counter3 = 360000000)then -- after 15 seconds
					
					counter3 <= 0;	
					booster_tmp <= booster_tmp + 30000;

				end if;
				
		   end if;
			
		end if;
end process;


process(clk , reset)
begin

if(reset = '1')then
	
	yekan    <= "0001";
	dahgan   <= "0010";
	sadgan   <= "0000";
	hezargan <= "0011";
	
	finish_tmp <= false;
	
	win_tmp <= false;
	
	counter2 <= 0;
	counter1 <= 0;
	
	led_tmp <= "00000000";
		
elsif(rising_edge(clk))then

		
		----------- manage enable ------------------------------
		counter2 <= counter2 +1;
		
		if(counter2 = 60000 ) then 

			en_tmp <= "0111";
			
		elsif(counter2 = 120000 ) then 
		
			en_tmp <= "1011";
			
		elsif(counter2 = 180000 ) then 
		
			en_tmp <= "1101";	
			
		elsif(counter2 = 240000 ) then 
		
			en_tmp <= "1110";
				
		
		end if;
		
	------------- set 0000 on 7seg ---------------------------
	if(pushbutton3 = '0')then
	
		yekan    <= "0000";
		dahgan   <= "0000";
		sadgan   <= "0000";
		hezargan <= "0000";
		
	end if;		
	
	------------ start game ----------------------------------
	if(start)then 
		counter1 <= counter1 +1;
		
		------------ manage secounds ----------------------------
		if(counter1 = 24000000 and not finish_tmp and not finish2)then
			if(yekan = "1001" and dahgan /= "1001") then 
			
					dahgan <= dahgan + 1;
					yekan <= "0000";
					
			elsif (dahgan = "1001" and yekan = "1001") then	
			
					finish_tmp <= true;
					led_tmp <= "11111111";
					win_tmp <= true;
			else
					yekan <= yekan + 1;
			
			end if;
			
				counter1 <= 0;
		
		end if; 
		
		------------ manage score ---------------------------
	
	if((counter2 = 240000 - booster_tmp) and not finish_tmp and not finish2)then
		
		if(((shotY = BlockY1 + BLOCKWIDTH or shotY + "01" = BlockY1 + BLOCKWIDTH )and (((BlockX1 <= shotX + "100") and (BlockX1 + "10"*BLOCKWIDTH >= shotX + "100" )) or ((BlockX1 <= shotX ) and (BlockX1 + "10"*BLOCKWIDTH >= shotX ))))or
		((shotY = BlockY2 + BLOCKWIDTH or shotY + "01" = BlockY2 + BLOCKWIDTH )and (((BlockX2 <= shotX + "100") and (BlockX2 + BLOCKWIDTH >= shotX + "100" )) or ((BlockX2 <= shotX ) and (BlockX2 + BLOCKWIDTH >= shotX  ))))or
		((shotY = BlockY3 + BLOCKWIDTH or shotY + "01" = BlockY3 + BLOCKWIDTH )and (((BlockX3 <= shotX + "100") and (BlockX3 + "11"*BLOCKWIDTH >= shotX + "100" )) or ((BlockX3 <= shotX ) and (BlockX3 + "11"*BLOCKWIDTH >= shotX ))))or
		((shotY = BlockY4 + BLOCKWIDTH or shotY + "01" = BlockY4 + BLOCKWIDTH )and (((BlockX4 <= shotX + "100") and (BlockX4 + "10"*BLOCKWIDTH >= shotX + "100" )) or ((BlockX4 <= shotX ) and (BlockX4 + "10"*BLOCKWIDTH >= shotX ))))or
		((shotY = BlockY5 + BLOCKWIDTH or shotY + "01" = BlockY5 + BLOCKWIDTH )and (((BlockX5 <= shotX + "100") and (BlockX5 + BLOCKWIDTH >= shotX + "100" )) or ((BlockX5 <= shotX ) and (BlockX5 + BLOCKWIDTH >= shotX )))))then
					
					
			if(sadgan= "1001" and hezargan /= "0101") then -- if adad = x9 and x != 5
			
					hezargan <= hezargan + 1;
					sadgan <= "0000";
					
			elsif (hezargan = "0101" and sadgan = "0000") then	-- if adad = 50
			
					finish_tmp <= true;
					win_tmp <= true;
					led_tmp <= "11111111";
			
			else
					sadgan <= sadgan + 1;
					
		   end if;

		end if;
		
			counter2 <= 0;
	end if;	
		-----------------------------------------------------
		
		
	end if; -- start
	
	
end if;
end process;

	process(en_tmp,yekan,dahgan) 
	begin
	
	
	if( en_tmp(3)= '0') then
			sevensegO <= sevenSeg(yekan);
	
	elsif( en_tmp(2)= '0') then
			sevensegO <= sevenSeg(dahgan);
			
	elsif( en_tmp(1)= '0') then
			sevensegO <= sevenSeg(sadgan);
			
	elsif( en_tmp(0)= '0') then
			sevensegO <= sevenSeg(hezargan);
			
	else
			sevensegO <= "10111111";
	
	end if;
	end process;
	
	en <= en_tmp;
	led <= led_tmp;
	finish1 <= finish_tmp;
	booster <= booster_tmp;
	win <= win_tmp;

end Behavioral;

