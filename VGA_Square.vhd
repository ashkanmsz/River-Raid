library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;


entity VGA_Square is
  port ( CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			BLOCKWIDTH		: in std_logic_vector(7 downto 0);
			KEY            : in std_logic_vector(3 downto 0); -- buttons
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0);
			LED 				: out std_logic_vector(7 downto 0);
			en      			: out STD_LOGIC_VECTOR(3 downto 0);
			sevensegO  		: out  STD_LOGIC_VECTOR(7 downto 0)
			
  );
end VGA_Square;

architecture Behavioral of VGA_Square is
  
  signal ColorOutput: std_logic_vector(5 downto 0);
  
  --airplane
  signal SquareX: std_logic_vector(9 downto 0) := "0100110000";-- 304  
  signal SquareY: std_logic_vector(9 downto 0) := "0110000000";-- 384
  signal SquareXMoveDir, SquareYMoveDir: std_logic := '0';-- left or right | up or down
  
  --Bat
  signal BlockX1: std_logic_vector(8 downto 0):= (others => '0') ;
  signal BlockY1: std_logic_vector(8 downto 0):= "000001000" ;
  
  --heart
  signal BlockX2: std_logic_vector(8 downto 0):= "010000001" ;
  signal BlockY2: std_logic_vector(8 downto 0):= "001010100"; -- in the same row
  
  --boat
  signal BlockX3: std_logic_vector(8 downto 0):= (others => '0') ;
  signal BlockY3: std_logic_vector(8 downto 0):= "010101000" ;
  
  --havapeima
  signal BlockX4: std_logic_vector(8 downto 0):= (others => '0') ;
  signal BlockY4: std_logic_vector(8 downto 0):= "011111000" ;
  
  --helikoofter
  signal BlockX5: std_logic_vector(8 downto 0):= "011010100" ;
  signal BlockY5: std_logic_vector(8 downto 0):= "001010100"; -- in the same row
	
  --shot
  signal shotX: std_logic_vector(9 downto 0):= "0000000000";
  signal shotY: std_logic_vector(9 downto 0):= "0000000000";
  
  
  constant SquareXmin: std_logic_vector(9 downto 0) := "0010000000";
  signal SquareXmax: std_logic_vector(9 downto 0):="0111100100";
  
  signal random_numbX1:std_logic_vector(31 downto 0):= ( others => '0');
  signal random_numbX2:std_logic_vector(31 downto 0):= ( others => '0');
  signal random_numbX3:std_logic_vector(31 downto 0):= ( others => '0');
  signal random_numbX4:std_logic_vector(31 downto 0):= ( others => '0');
  signal random_numbX5:std_logic_vector(31 downto 0):= ( others => '0');
  
  -- flags for favourite random 
  -- first time
  signal a1:std_logic:='0';
  signal a2:std_logic:='0';
  signal a3:std_logic:='0';
  signal a4:std_logic:='0';
  signal a5:std_logic:='0';
  -- next round
  signal b1:std_logic:='0';
  signal b2:std_logic:='0';
  signal b3:std_logic:='0';
  signal b4:std_logic:='0';
  signal b5:std_logic:='0';
  -- barkhord ba tir
  signal c1:std_logic:='0';
  signal c2:std_logic:='0';
  signal c3:std_logic:='0';
  signal c4:std_logic:='0';
  signal c5:std_logic:='0';
  
  
  signal start : boolean := false;
  signal score: integer range 0 to 50 := 0;
  
  signal backGroundY1 :std_logic_vector(9 downto 0) := "0000000000"; -- left
  signal backGroundY2 :std_logic_vector(9 downto 0) := "0000000000"; -- right
  
  
  signal counter1:integer range 0 to 240000:=0;
  signal counter2:integer range 0 to 50000:=0;
  
  signal LED_tmp : std_logic_vector(7 downto 0):= "00000000"; -- bakht
  signal LED_tmp2 : std_logic_vector(7 downto 0):= "00000000"; -- times up
  
  signal finish1 : boolean;-- times up or score = 50
  signal finish2 : boolean:= false;
  
  signal booster : integer range 0 to 250000;
  
  signal win : boolean ;
----------------------------------------------------------------------------
 
 function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is 
	begin
	return x(29 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31)) & (x(0) xnor x(1) xnor x(21) xnor x(31)); 
 end function; 
 
-----------------------------------------------------------------------------

component Timer is
    Port ( 
			  Clk       : in  STD_LOGIC;
           Reset     : in  STD_LOGIC;
			  en        : out STD_LOGIC_VECTOR(3 downto 0);
			  sevensegO : out STD_LOGIC_VECTOR(7 downto 0);
           led       : out STD_LOGIC_VECTOR(7 downto 0);
			  start     : in  BOOLEAN;
			  SquareY   : in  std_logic_vector(9 downto 0);
			  BlockY1	: in  std_logic_vector(8 downto 0);
			  BlockY2	: in  std_logic_vector(8 downto 0);
			  BlockY3	: in  std_logic_vector(8 downto 0);
			  BlockY4	: in  std_logic_vector(8 downto 0);
			  BlockY5	: in  std_logic_vector(8 downto 0);
			  SquareX   : in  std_logic_vector(9 downto 0);
			  BlockX1	: in  std_logic_vector(8 downto 0);
			  BlockX2	: in  std_logic_vector(8 downto 0);
			  BlockX3	: in  std_logic_vector(8 downto 0);
			  BlockX4	: in  std_logic_vector(8 downto 0);
			  BlockX5	: in  std_logic_vector(8 downto 0);
			  shotX     : in  std_logic_vector(9 downto 0);
			  shotY     : in  std_logic_vector(9 downto 0);
			  finish1   : out boolean;
			  finish2   : in boolean ;
			  booster   : out integer range 0 to 250000;
			  pushButton3: in std_logic;
			  win       : out boolean
			  );
end component;

------------------------------------------------------------------------------

begin

	component1 : Timer
	port map(
	
	reset 		=> reset,
	en 			=> en,
	sevensegO    => sevensegO,
	clk         => CLK_24MHz,
	led         => led_tmp2,
	start       => start,
	squareY     => squareY,
	blockY1     => blockY1,
	blockY2     => blockY2,
	blockY3     => blockY3,
	blockY4     => blockY4,
	blockY5     => blockY5,
	squareX     => squareX,
	blockX1     => blockX1,
	blockX2     => blockX2,
	blockX3     => blockX3,
	blockX4     => blockX4,
	blockX5     => blockX5,
	finish1     => finish1,
	finish2     => finish2,
	booster     => booster,
	shotX       => shotX,
	shotY       => shotY,
	pushButton3 => key(3),
	win         => win
	);
	

	favouriteRandom: 
	process(CLK_24MHz, RESET) 
	begin	 
			
			if(reset='1') then				
				random_numbX1 <= lfsr32(random_numbX1);
				random_numbX2 <= lfsr32(random_numbX2);
				random_numbX3 <= lfsr32(random_numbX3);
				random_numbX4 <= lfsr32(random_numbX4);
				random_numbX5 <= lfsr32(random_numbX5);

				
			elsif rising_edge(CLK_24MHz) then
				if(a1='0' or b1 = '1' ) then
				
					random_numbX1 <= lfsr32(random_numbX1);
					
				end if;
				if(a2='0' or b2 = '1') then
				
					random_numbX2 <= lfsr32(random_numbX2);
					
				end if;
				if(a3='0' or b3 = '1') then
				
					random_numbX3 <= lfsr32(random_numbX3);
					
				end if;
				if(a4='0' or b4 = '1') then
				
					random_numbX4 <= lfsr32(random_numbX4);
					
				end if;
				if(a5='0' or b5 = '1') then
				
					random_numbX5 <= lfsr32(random_numbX5);
					
				end if;
			end if;
		end process;
		
		
		
process (random_numbX1,random_numbX2,random_numbX3,random_numbX4,random_numbX5,c1,c2,c3,c4,c5)
begin
	
	
		--bat
		if(c1 = '1')then
			BlockX1 <= "000000000";
		elsif( random_numbX1(8 downto 0) > "010000010" and random_numbX1(8 downto 0) < "110111111" ) then
				
					BlockX1 <= random_numbX1(8 downto 0);
					a1 <= '1';
		else
					BlockX1 <= "110111110";
		end if;
		--heart
		if(c2 = '1')then
			BlockX2 <= "000000000";
		elsif( random_numbX2(8 downto 0) > "010000010" and random_numbX2(8 downto 0) < "100010000" ) then
					
					BlockX2 <= random_numbX2(8 downto 0);
					a2 <= '1';
		else
					BlockX2 <= "010001010";
		end if;
		--boat
		if(c3 = '1')then
			BlockX3 <= "000000000";
		elsif( random_numbX3(8 downto 0) > "010000010" and random_numbX3(8 downto 0) < "110100000" ) then
					
					BlockX3 <= random_numbX3(8 downto 0);
					a3 <= '1';
		else
					BlockX3 <= "101000000";
		end if;
		--havapeima
		if(c4 = '1')then
			BlockX4 <= "000000000";
		elsif( random_numbX4(8 downto 0) > "010000010" and random_numbX4(8 downto 0) < "110111111" ) then
					
					BlockX4 <= random_numbX4(8 downto 0);
					a4 <= '1';
		else
					BlockX4 <= "010011011";
		end if;
		--helikoofter
		
		
		if(c5 = '1')then
			BlockX5 <= "000000000";
		elsif( random_numbX5(8 downto 0) > "101100010" and random_numbX5(8 downto 0) < "111100000" ) then
						
					BlockX5 <= random_numbX5(8 downto 0);
					a5 <= '1';
		else
					BlockX5 <= "101100110";
		end if;	

		
			
end process;
	


	PrescalerCounter: process(CLK_24MHz, RESET)
	begin
	
		if RESET = '1' then
			
			SquareX <= "0100110000"; -- 304
			SquareY <= "0110110000"; -- 432
			
			LED_tmp <= "00000000";
			
			start <= false;
			finish2 <= false;
			
			c1 <= '0';
			c2 <= '0';
			c3 <= '0';
			c4 <= '0';
			c5 <= '0';
			
			BlockY1 <= "000001000";
			BlockY2 <= "001010100";
			BlockY3 <= "010101000";
			BlockY4 <= "011111000";
			BlockY5 <= "001010100";
			
			
			backGroundY1 <= "0000000000";
			backGroundY2 <= "0000000000";
			
			shotY <= "0000000000";
			shotX <= "0000000000";
		
			counter1 <= 0;
			counter2 <= 0;
			
		elsif rising_edge(CLK_24MHz) then
		
	-- start button
		if(key(3) = '0')then
			start <= true;
		else
			start <= start;
		end if;
		
	-- game start	
	if(start)then
	
		counter1 <= counter1 + 1;
		counter2 <= counter2 + 1;
	
		 if(counter2 = 50000)then
		
			   if(backGroundY1 /= "1111111111")then
					 backGroundY1 <= backGroundY1 + 1;
					 backGroundY2 <= backGroundY2 + 1;
				else
					 backGroundY1 <= backGroundY1;
					 backGroundY2 <= backGroundY2;
				end if;
				
		counter2 <= 0;		
		end if;
	
	
		if(counter1 = (240000 - booster ) and not finish2 and not finish1)then

								-- 480
			if(BlockY1 /= "111100000")then -- bat
				BlockY1 <= BlockY1 + 1;
				b1 <= '0';
			else				-- begin row
			   BlockY1 <= "000001000";
				b1 <= '1';
				c1 <= '0';
			end if;
			
									-- 480
			if(BlockY2 /= "111100000")then
				BlockY2 <= BlockY2 + 1;
				b2 <= '0';
			else			-- begin row
			   BlockY2 <= "000001000";
				b2 <= '1';
				c2 <= '0';
			end if;
			
									-- 480
			if(BlockY3 /= "111100000")then
				BlockY3 <= BlockY3 + 1;
				b3 <= '0';
			else				-- begin row
			   BlockY3 <= "000001000";
				b3 <= '1';
				c3 <= '0';
			end if;
			
			
								  -- 480
			if(BlockY4 /= "111100000")then
				BlockY4 <= BlockY4 + 1;
				b4 <= '0';
			else				-- begin row
			   BlockY4 <= "000001000";
				b4 <= '1';
				c4 <= '0';
			end if;
			
			
								-- 480
			if(BlockY5 /= "111100000")then
				BlockY5 <= BlockY5 + 1;
				b5 <= '0';
			else				-- begin row
			   BlockY5 <= "000001000";
				b5 <= '1';
				c5 <= '0';
			end if;
	
	
			
			if(shotY /= "0000000000")then
				shotY <= shotY - 1;
			else -- mahv shodane tir
				shotY <= "0000000000";
				shotX <= "0000000000";
			end if;
			
			---------------------------- harekate hava peima --------------------------------------
			
				if key(0) = '0' then -- push button 1
					if ( SquareX < SquareXmax ) then
					---------------------------------- barkhord be mavane -----------------------------------------------------
						 
						 --barkhord az chap	 
								-- bat
						 if (( squareX + SQUAREWIDTH = BlockX1 and (((BlockY1 <= SquareY + SQUAREWIDTH) and (BlockY1 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY1 <= SquareY ) and (BlockY1 + BLOCKWIDTH >= SquareY ))))or
								-- heart
							  ( squareX + SQUAREWIDTH = BlockX2 and (((BlockY2 <= SquareY + SQUAREWIDTH) and (BlockY2 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY2 <= SquareY ) and (BlockY2 + BLOCKWIDTH >= SquareY ))))or
							   -- boat
							  ( squareX + SQUAREWIDTH = BlockX3 and (((BlockY3 <= SquareY + SQUAREWIDTH) and (BlockY3 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY3 <= SquareY ) and (BlockY3 + BLOCKWIDTH >= SquareY ))))or
								-- hava peima
							  ( squareX + SQUAREWIDTH = BlockX4 and (((BlockY4 <= SquareY + SQUAREWIDTH) and (BlockY4 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY4 <= SquareY ) and (BlockY4 + BLOCKWIDTH >= SquareY ))))or
							   -- helikoofter
							  ( squareX + SQUAREWIDTH = BlockX5 and (((BlockY5 <= SquareY + SQUAREWIDTH) and (BlockY5 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY5 <= SquareY ) and (BlockY5 + BLOCKWIDTH >= SquareY )))))then
								
								LED_tmp <= "11111111";
								SquareX <= SquareX;
								finish2 <= true;
								
						 
						 -- barkhord az paeen
						 elsif ((squareY = BlockY1 + BLOCKWIDTH and (((BlockX1 <= SquareX + SQUAREWIDTH) and (BlockX1 + "10"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX1 <= SquareX ) and (BlockX1 + "10"*BLOCKWIDTH >= SquareX ))))or
								 ( squareY = BlockY2 + BLOCKWIDTH and (((BlockX2 <= SquareX + SQUAREWIDTH) and (BlockX2 + BLOCKWIDTH >= SquareX + SQUAREWIDTH )) 	  or ((BlockX2 <= SquareX ) and (BlockX2 + BLOCKWIDTH >= SquareX 		 ))))or
								 ( squareY = BlockY3 + BLOCKWIDTH and (((BlockX3 <= SquareX + SQUAREWIDTH) and (BlockX3 + "11"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX3 <= SquareX ) and (BlockX3 + "11"*BLOCKWIDTH >= SquareX ))))or
								 ( squareY = BlockY4 + BLOCKWIDTH and (((BlockX4 <= SquareX + SQUAREWIDTH) and (BlockX4 + "10"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX4 <= SquareX ) and (BlockX4 + "10"*BLOCKWIDTH >= SquareX ))))or
								 ( squareY = BlockY5 + BLOCKWIDTH and (((BlockX5 <= SquareX + SQUAREWIDTH) and (BlockX5 + BLOCKWIDTH >= SquareX + SQUAREWIDTH )) 	  or ((BlockX5 <= SquareX ) and (BlockX5 + BLOCKWIDTH >= SquareX 		 )))))then
								
								LED_tmp <= "11111111";
								SquareX <= SquareX;
								finish2 <= true;
								
						else
								SquareX <= SquareX + 1;
						end if;
						
						---------------------------------- barkhord be mavane -----------------------------------------------------
					
					-- sharte barkhord ba divar	
					else 	
						  SquareX <= SquareX;
						  LED_tmp <= "11111111";
						  finish2 <= true;
						  
					end if;
					
					
					
				elsif key(1) = '0' then -- push button 2 
					if SquareX > SquareXmin then
					
					---------------------------------- barkhord be mavane -----------------------------------------------------
											 
						 -- barkhord az rast
								-- bat
						 if (( squareX = BlockX1 + "10"*BLOCKWIDTH and (((BlockY1 <= SquareY + SQUAREWIDTH) and (BlockY1 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY1 <= SquareY ) and (BlockY1 + BLOCKWIDTH >= SquareY ))))or
							   -- heart
							  ( squareX = BlockX2 + BLOCKWIDTH      and (((BlockY2 <= SquareY + SQUAREWIDTH) and (BlockY2 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY2 <= SquareY ) and (BlockY2 + BLOCKWIDTH >= SquareY ))))or
								-- boat
							  ( squareX = BlockX3 + "11"*BLOCKWIDTH and (((BlockY3 <= SquareY + SQUAREWIDTH) and (BlockY3 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY3 <= SquareY ) and (BlockY3 + BLOCKWIDTH >= SquareY ))))or
							   -- hava peima
							  ( squareX = BlockX4 + "10"*BLOCKWIDTH and (((BlockY4 <= SquareY + SQUAREWIDTH) and (BlockY4 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY4 <= SquareY ) and (BlockY4 + BLOCKWIDTH >= SquareY ))))or
							  -- helikoofter
							  ( squareX = BlockX5 + BLOCKWIDTH 		 and (((BlockY5 <= SquareY + SQUAREWIDTH) and (BlockY5 + BLOCKWIDTH >= SquareY + SQUAREWIDTH )) or ((BlockY5 <= SquareY ) and (BlockY5 + BLOCKWIDTH >= SquareY )))))then
								
								LED_tmp <= "11111111";
								SquareX <= SquareX;
								finish2 <= true;
						 
						 -- barkhord az paeen
						 elsif (( squareY = BlockY1 + BLOCKWIDTH and (((BlockX1 <= SquareX + SQUAREWIDTH) and (BlockX1 + "10"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX1 <= SquareX ) and (BlockX1 + "10"*BLOCKWIDTH >= SquareX ))))or
								  ( squareY = BlockY2 + BLOCKWIDTH and (((BlockX2 <= SquareX + SQUAREWIDTH) and (BlockX2 + "01"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX2 <= SquareX ) and (BlockX2 + "01"*BLOCKWIDTH >= SquareX ))))or
								  ( squareY = BlockY3 + BLOCKWIDTH and (((BlockX3 <= SquareX + SQUAREWIDTH) and (BlockX3 + "11"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX3 <= SquareX ) and (BlockX3 + "11"*BLOCKWIDTH >= SquareX ))))or
								  ( squareY = BlockY4 + BLOCKWIDTH and (((BlockX4 <= SquareX + SQUAREWIDTH) and (BlockX4 + "10"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX4 <= SquareX ) and (BlockX4 + "10"*BLOCKWIDTH >= SquareX ))))or
								  ( squareY = BlockY5 + BLOCKWIDTH and (((BlockX5 <= SquareX + SQUAREWIDTH) and (BlockX5 + "01"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX5 <= SquareX ) and (BlockX5 + "01"*BLOCKWIDTH >= SquareX )))))then
								
								LED_tmp <= "11111111";
								SquareX <= SquareX;
								finish2 <= true;
														
						 else
								SquareX <= SquareX - 1;
						 end if;
							
					-- sharte barkhord ba divar
					else 
							SquareX <= SquareX;
							LED_tmp <= "11111111";
						   finish2 <= true;
							
					end if;
				
				
				elsif key(2) = '0' then -- push Button 3
					
					shotX <= squareX + "000001100";
					shotY <= squareY - "000000100";
				
				-- kelidi zade nashode
				else 
						
						squareX <= SquareX;
								
								-- bat
						if (( squareY = BlockY1 + BLOCKWIDTH and (((BlockX1 <= SquareX + SQUAREWIDTH) and (BlockX1 + "10"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX1 <= SquareX ) and (BlockX1 + "10"*BLOCKWIDTH >= SquareX ))))or
								-- heart
							 ( squareY = BlockY2 + BLOCKWIDTH and (((BlockX2 <= SquareX + SQUAREWIDTH) and (BlockX2 + "01"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX2 <= SquareX ) and (BlockX2 + "01"*BLOCKWIDTH >= SquareX ))))or
								-- boat
							 ( squareY = BlockY3 + BLOCKWIDTH and (((BlockX3 <= SquareX + SQUAREWIDTH) and (BlockX3 + "11"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX3 <= SquareX ) and (BlockX3 + "11"*BLOCKWIDTH >= SquareX ))))or
								-- hava peima
							 ( squareY = BlockY4 + BLOCKWIDTH and (((BlockX4 <= SquareX + SQUAREWIDTH) and (BlockX4 + "10"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX4 <= SquareX ) and (BlockX4 + "10"*BLOCKWIDTH >= SquareX ))))or
							   -- heli koofter
							 ( squareY = BlockY5 + BLOCKWIDTH and (((BlockX5 <= SquareX + SQUAREWIDTH) and (BlockX5 + "01"*BLOCKWIDTH >= SquareX + SQUAREWIDTH )) or ((BlockX5 <= SquareX ) and (BlockX5 + "01"*BLOCKWIDTH >= SquareX )))))then
								
								LED_tmp <= "11111111";
								finish2 <= true;
								
						end if;	
							
		  
				end if;
				
				---------------------------------- barkhorde tir ba maane ha -------------------------------------------
				
							if  ((shotY = BlockY1 + BLOCKWIDTH or shotY + "01" = BlockY1 + BLOCKWIDTH )and (((BlockX1 <= shotX + "100") and (BlockX1 + "10"*BLOCKWIDTH >= shotX + "100" )) or ((BlockX1 <= shotX ) and (BlockX1 + "10"*BLOCKWIDTH >= shotX )))) then
										c1 <= '1';
										shotX <= "0000000000";
							end if;
							if	 ((shotY = BlockY2 + BLOCKWIDTH or shotY + "01" = BlockY2 + BLOCKWIDTH )and (((BlockX2 <= shotX + "100") and (BlockX2 + BLOCKWIDTH >= shotX + "100" )) or ((BlockX2 <= shotX ) and (BlockX2 + BLOCKWIDTH >= shotX  ))))then
										c2 <= '1';
										shotX <= "0000000000";
							end if;
							if	 ((shotY = BlockY3 + BLOCKWIDTH or shotY + "01" = BlockY3 + BLOCKWIDTH )and (((BlockX3 <= shotX + "100") and (BlockX3 + "11"*BLOCKWIDTH >= shotX + "100" )) or ((BlockX3 <= shotX ) and (BlockX3 + "11"*BLOCKWIDTH >= shotX ))))then
										c3 <= '1';
										shotX <= "0000000000";
							end if;
							if	 ((shotY = BlockY4 + BLOCKWIDTH or shotY + "01" = BlockY4 + BLOCKWIDTH )and (((BlockX4 <= shotX + "100") and (BlockX4 + "10"*BLOCKWIDTH >= shotX + "100" )) or ((BlockX4 <= shotX ) and (BlockX4 + "10"*BLOCKWIDTH >= shotX ))))then
										c4 <= '1';
										shotX <= "0000000000";
							end if;
							if  ((shotY = BlockY5 + BLOCKWIDTH or shotY + "01" = BlockY5 + BLOCKWIDTH )and (((BlockX5 <= shotX + "100") and (BlockX5 + BLOCKWIDTH >= shotX + "100" )) or ((BlockX5 <= shotX ) and (BlockX5 + BLOCKWIDTH >= shotX ))))then
										c5 <= '1';
										shotX <= "0000000000";
							end if;
				
				----------------------------------------------------------------------------------------------------
				
				counter1 <= 0;
				
			end if; -- if counter
		end if; -- if start
	end if; -- if reset
end process PrescalerCounter; 

	
	
	-- manage colors													
	ColorOutput <=	--background
						 "000100" when not(finish1 xor finish2) and((ScanlineX <= "00010000000" OR ScanlineX >= "01000000000") or	--taeene bakhshe sabz rang menhaye bakhshe mosalasi
	
						("0100"*ScanlineY - "0011"*ScanlineX >= (backGroundY1 + "01100000000") and ScanlineX >= "00010000000" and ScanlineX < "00100000000" and ScanlineY >= "00100100000") or	--taeen bakhshe mosalasie chap
						("0100"*ScanlineY + "0011"*ScanlineX >= (backGroundY2 + "101010000000") and ScanlineX >= "00110000000" and ScanlineX < "01000000000" and ScanlineY >= "00100100000"))else --taeen bakhshe mosalasie rast
							
						
						--havapeima
						"111100" when not(finish1 xor finish2) and((ScanlineX >= SquareX and ScanlineY >= SquareY and ScanlineY <= SquareY+SQUAREWIDTH and ScanlineX <= SquareX+SQUAREWIDTH and (
																											  (( ScanlineX <= SquareX + "0000000100" or ScanlineX >= SquareX + "0000011000")and ScanlineY >= SquareY + "0000001100" and ScanlineY <= SquareY + "0000010100" ) or 
																											  ((( ScanlineX >= SquareX + "0000000100" and ScanlineX <= SquareX + "0000001000")or( ScanlineX >= SquareX + "0000010100" and ScanlineX <= SquareX + "0000011000")) and((ScanLineY >= SquareY +"0000001010" and ScanlineY <= SquareY + "0000010010" ) or (ScanlineY >= SquareY + "0000011000")))or
																											  ((( ScanlineX >= SquareX + "0000001000" and ScanlineX <= SquareX + "0000001100")or( ScanlineX >= SquareX + "0000010000" and ScanlineX <= SquareX + "0000010100")) and((ScanLineY >= SquareY + "0000001000" and ScanlineY <= SquareY + "0000010000" ) or ((ScanlineY >= SquareY+"0000010110") and (ScanlineY <= SquareY + "0000011010"))))or
																											  ((ScanlineX >= SquareX +"0000001100" and ScanlineX <= SquareX +"0000010000")))))else
						--boat
						"000000" when not(finish1 xor finish2) and((ScanlineX >= BlockX3 and ScanlineY >= BlockY3 and ScanlineY <= BlockY3+BLOCKWIDTH and ScanlineX <= BlockX3+"0011"*BLOCKWIDTH and (
																											  (ScanlineX >= BlockX3 + "0000110000" and ScanlineX <= BlockX3 + "0000111100"and ScanlineY <= BlockY3 + "0000001000" )or
																										     (ScanlineX >= BlockX3 + "0000110000" and ScanlineX <= BlockX3 + "0001001000" and ScanLineY >= BlockY3 +"0000001000" and ScanlineY <= BlockY3 + "0000001100" )or
																											  (ScanlineX >= BlockX3 + "0000100100" and ScanlineX <= BlockX3 + "0001010100" and ScanLineY >= BlockY3 + "0000001100" and ScanlineY <= BlockY3 + "0000010000" ))))else
						"110000" when not(finish1 xor finish2) and((ScanlineX >= BlockX3 and ScanlineY >= BlockY3 and ScanlineY <= BlockY3+BLOCKWIDTH and ScanlineX <= BlockX3+"0011"*BLOCKWIDTH and (
																											  (ScanlineY >= BlockY3 + "0000010000" and  ScanlineY <= BlockY3 + "0000010100")or -- sotune aval
																											  (ScanlineX >= BlockX3 + "0000001100" and ScanLineY >= BlockY3 +"0000010100" and ScanlineY <= BlockY3 + "0000011000" ))))else
						"001111" when not(finish1 xor finish2) and((ScanlineX >= BlockX3 and ScanlineY >= BlockY3 and ScanlineY <= BlockY3+BLOCKWIDTH and ScanlineX <= BlockX3+"0011"*BLOCKWIDTH and (
																											  (ScanlineX >= BlockX3 + "0000011000" and  ScanlineY >= BlockY3 + "0000011000" and ScanlineY <= BlockY3 + "0000011100")or 
																											  (ScanlineX >= BlockX3 + "0000011000" and ScanlineX <= BlockX3 + "0001010100" and ScanLineY >= BlockY3 +"0000011100" ))))else
						
						--helikoofter
						"111100" when not(finish1 xor finish2) and((ScanlineX >= BlockX5 and ScanlineY >= BlockY5 and ScanlineY <= BlockY5+BLOCKWIDTH and ScanlineX <= BlockX5+BLOCKWIDTH and (
																												(ScanlineX >= BlockX5 + "0000001100" and ScanlineX <= BlockX5 + "0000011000"and ScanlineY <= BlockY5 + "0000000110" and ScanlineY >= BlockY5 + "0000000100")or 
																												(ScanlineX >= BlockX5 + "0000010100" and ScanlineX <= BlockX5 + "0000100000" and ScanLineY >= BlockY5 +"0000000110" and ScanlineY <= BlockY5 + "0000001000" )or
																												(ScanlineX >= BlockX5 + "0000010100" and ScanlineX <= BlockX5 + "0000011000" and ScanLineY >= BlockY5 + "0000001000" and ScanlineY <= BlockY5 + "0000001100" ))))else
						"000100" when not(finish1 xor finish2) and((ScanlineX >= BlockX5 and ScanlineY >= BlockY5 and ScanlineY <= BlockY5+BLOCKWIDTH and ScanlineX <= BlockX5+BLOCKWIDTH and (
																											   (ScanlineX >= BlockX5 + "0000010000" and  ScanlineX <= BlockX5 + "0000011100" and ScanlineY >= BlockY5 + "0000001110" and  ScanlineY <= BlockY5 + "0000010010")or
																											   ((ScanlineX <= BlockX5 + "0000000100" or scanlineX>= BlockX5 + "0000001100" )and ScanLineY >= BlockY5 +"0000010010" and ScanlineY <= BlockY5 + "0000010100" )or
																											   ((ScanlineX <= BlockX5 + "0000000100" or (scanlineX>= BlockX5 + "0000010000" and scanlineX <= BlockX5 + "0000011100" ))and ScanLineY >= BlockY5 +"0000011010" and ScanlineY <= BlockY5 + "0000011100" )or
																											   (ScanlineX >= BlockX5 + "0000010100" and  ScanlineX <= BlockX5 + "0000011000" and ScanlineY >= BlockY5 + "0000011100" and  ScanlineY <= BlockY5 + "0000011110") or
																											   (scanlineX>= BlockX5 + "0000010000" and scanlineX <= BlockX5 + "0000011100" and ScanLineY >= BlockY5 +"0000011110" ))))else
						"000001" when not(finish1 xor finish2) and((ScanlineX >= BlockX5 and ScanlineY >= BlockY5 and ScanlineY <= BlockY5+BLOCKWIDTH and ScanlineX <= BlockX5+BLOCKWIDTH and (
																											   (ScanlineY >= BlockY5 + "0000010100" and ScanlineY <= BlockY5 + "0000011010"))))else
						
						
						--havapeima
						"111111" when not(finish1 xor finish2) and((ScanlineX > BlockX4 and ScanlineY >= BlockY4 and ScanlineY <= BlockY4 +BLOCKWIDTH and ScanlineX <= BlockX4+"0010"*BLOCKWIDTH and (
																												(ScanlineX >= BlockX4 + "0000111000" and ScanlineY >= BlockY4 + "0000000100" and  ScanlineY <= BlockY4 + "0000001000")or
																												(((ScanlineX >= BlockX4 + "0000001000" and ScanlineX <= BlockX4 + "0000011000") or ScanlineX >= BlockX4 + "0000110000" )and ScanlineY >= BlockY4 + "0000001000" and  ScanlineY <= BlockY4 + "0000001110"))))else
						"001111" when not(finish1 xor finish2) and((ScanlineX > BlockX4 and ScanlineY >= BlockY4 and ScanlineY <= BlockY4 +BLOCKWIDTH and ScanlineX <= BlockX4+"0010"*BLOCKWIDTH and (
																												(ScanlineY >= BlockY4 + "0000001110" and ScanlineY <= BlockY4 + "0000010100")or
																												((ScanlineX <= BlockX4 + "0000100000" or (ScanlineX >= BlockX4 + "0000110000" and ScanlineX <= BlockX4 + "0000111000" )) and ScanlineY >= BlockY4 + "0000010100" and ScanlineY <= BlockY4 + "0000011000"))))else
						"111111" when not(finish1 xor finish2) and((ScanlineX > BlockX4 and ScanlineY >= BlockY4 and ScanlineY <= BlockY4 +BLOCKWIDTH and ScanlineX <= BlockX4+"0010"*BLOCKWIDTH and (
																												(ScanlineX >= BlockX4 + "0000011000" and ScanlineX <= BlockX4 + "0000110000" and ScanlineY >= BlockY4 + "0000011000" and ScanlineY <= BlockY4 + "0000011100")or
																												(ScanlineX >= BlockX4 + "0000100000" and ScanlineX <= BlockX4 + "0000110000" and ScanlineY >= BlockY4 + "0000011100"))))else
						
						
						-- heart
						"000000" when not(finish1 xor finish2) and((ScanlineX > BlockX2 and ScanlineY >= BlockY2 and ScanlineY <= BlockY2 +BLOCKWIDTH and ScanlineX <= BlockX2+"0010"*BLOCKWIDTH and (
																												(ScanlineY >= BlockY2 + "0000001000" and ScanlineY <= BlockY2 + "0000001010" and ((ScanlineX >= BlockX2 + "0000000100" and ScanlineX <= BlockX2 + "0000001110" )or( ScanlineX >= BlockX2 + "0000010010" and ScanlineX <= BlockX2 + "0000011100")))or
																												(ScanlineY >= BlockY2 + "0000001010" and ScanlineY <= BlockY2 + "0000001100" and ((ScanlineX >= BlockX2 + "0000000010" and ScanlineX <= BlockX2 + "0000000110" )or( ScanlineX >= BlockX2 + "0000001100" and ScanlineX <= BlockX2 + "0000001110")or(ScanlineX >= BlockX2 + "0000010010" and ScanlineX <= BlockX2 + "0000010100" )or( ScanlineX >= BlockX2 + "0000011010" and ScanlineX <= BlockX2 + "0000011110")))or
																												(ScanlineY >= BlockY2 + "0000001100" and ScanlineY <= BlockY2 + "0000001110" and ((ScanlineX >= BlockX2 + "0000000010" and ScanlineX <= BlockX2 + "0000000100" )or( ScanlineX >= BlockX2 + "0000001110" and ScanlineX <= BlockX2 + "0000010010")or(ScanlineX >= BlockX2 + "0000011100" and ScanlineX <= BlockX2 + "0000011110" )))or
																												(ScanlineY >= BlockY2 + "0000001110" and ScanlineY <= BlockY2 + "0000010100" and ((ScanlineX >= BlockX2 + "0000000010" and ScanlineX <= BlockX2 + "0000000100" )or( ScanlineX >= BlockX2 + "0000011100" and ScanlineX <= BlockX2 + "0000011110")))or
																												(ScanlineY >= BlockY2 + "0000010100" and ScanlineY <= BlockY2 + "0000010110" and ((ScanlineX >= BlockX2 + "0000000010" and ScanlineX <= BlockX2 + "0000000110" )or( ScanlineX >= BlockX2 + "0000011010" and ScanlineX <= BlockX2 + "0000011110")))or
																												(ScanlineY >= BlockY2 + "0000010110" and ScanlineY <= BlockY2 + "0000011000" and ((ScanlineX >= BlockX2 + "0000000100" and ScanlineX <= BlockX2 + "0000001000" )or( ScanlineX >= BlockX2 + "0000011000" and ScanlineX <= BlockX2 + "0000011100")))or
																												(ScanlineY >= BlockY2 + "0000011000" and ScanlineY <= BlockY2 + "0000011010" and ((ScanlineX >= BlockX2 + "0000000110" and ScanlineX <= BlockX2 + "0000001010" )or( ScanlineX >= BlockX2 + "0000010110" and ScanlineX <= BlockX2 + "0000011010")))or
																												(ScanlineY >= BlockY2 + "0000011010" and ScanlineY <= BlockY2 + "0000011100" and ((ScanlineX >= BlockX2 + "0000001000" and ScanlineX <= BlockX2 + "0000001100" )or( ScanlineX >= BlockX2 + "0000010100" and ScanlineX <= BlockX2 + "0000011000")))or
																												(ScanlineY >= BlockY2 + "0000011100" and ScanlineY <= BlockY2 + "0000011110" and ((ScanlineX >= BlockX2 + "0000001010" and ScanlineX <= BlockX2 + "0000001110" )or( ScanlineX >= BlockX2 + "0000010010" and ScanlineX <= BlockX2 + "0000010110")))or
																												(scanlineY >= BlockY2 + "0000011110" and ScanlineX >= BlockX2 + "0000001100" and ScanlineX <= BlockX2 + "0000010100"))))else
						"110000" when not(finish1 xor finish2) and ((ScanlineX > BlockX2 and ScanlineY >= BlockY2 and ScanlineY <= BlockY2 +BLOCKWIDTH and ScanlineX <= BlockX2+"0010"*BLOCKWIDTH and (
																												(ScanlineY > BlockY2 + "0000001010" and ScanlineY <= BlockY2 + "0000001100" and ((ScanlineX >= BlockX2 + "0000000110" and ScanlineX <= BlockX2 + "0000001100" )or( ScanlineX >= BlockX2 + "0000010100" and ScanlineX <= BlockX2 + "0000011010")))or
																												(ScanlineY >= BlockY2 + "0000001100" and ScanlineY <= BlockY2 + "0000001110" and ((ScanlineX >= BlockX2 + "0000000100" and ScanlineX <= BlockX2 + "0000000110" )or( ScanlineX >= BlockX2 + "0000001010" and ScanlineX <= BlockX2 + "0000001110")or(ScanlineX >= BlockX2 + "0000010010" and ScanlineX <= BlockX2 + "0000011100" )))or
																												(ScanlineY >= BlockY2 + "0000001110" and ScanlineY <= BlockY2 + "0000010000" and ((ScanlineX >= BlockX2 + "0000000100" and ScanlineX <= BlockX2 + "0000000110" )or( ScanlineX >= BlockX2 + "0000001000" and ScanlineX <= BlockX2 + "0000011100")))or
																												(scanlineY >= BlockY2 + "0000010000" and scanlineY <= BlockY2 + "0000010100" and ScanlineX >= BlockX2 + "0000000100" and ScanlineX <= BlockX2 + "0000011100")or
																												(scanlineY >= BlockY2 + "0000010100" and scanlineY <= BlockY2 + "0000010110" and ScanlineX >= BlockX2 + "0000000110" and ScanlineX <= BlockX2 + "0000011010")or
																												(scanlineY >= BlockY2 + "0000010110" and scanlineY <= BlockY2 + "0000011000" and ScanlineX >= BlockX2 + "0000001000" and ScanlineX <= BlockX2 + "0000011000")or
																												(scanlineY >= BlockY2 + "0000011000" and scanlineY <= BlockY2 + "0000011010" and ScanlineX >= BlockX2 + "0000001010" and ScanlineX <= BlockX2 + "0000010110")or
																												(scanlineY >= BlockY2 + "0000011010" and scanlineY <= BlockY2 + "0000011100" and ScanlineX >= BlockX2 + "0000001100" and ScanlineX <= BlockX2 + "0000010100")or
																												(scanlineY >= BlockY2 + "0000011100" and scanlineY <= BlockY2 + "0000011110" and ScanlineX >= BlockX2 + "0000001100" and ScanlineX <= BlockX2 + "0000010010"))))else
						"111111" when not(finish1 xor finish2) and((ScanlineX > BlockX2 and ScanlineY >= BlockY2 and ScanlineY <= BlockY2 +BLOCKWIDTH and ScanlineX <= BlockX2+"0010"*BLOCKWIDTH and (
																												(ScanlineY >= BlockY2 + "0000001100" and ScanlineY <= BlockY2 + "0000001110" and ScanlineX >= BlockX2 + "0000000110" and ScanlineX <= BlockX2 + "0000001010" )or
																												(ScanlineY >= BlockY2 + "0000001110" and ScanlineY <= BlockY2 + "0000010000" and ScanlineX >= BlockX2 + "0000000110" and ScanlineX <= BlockX2 + "0000001000" ))))else
																												
											
						
						--bat
						"000000" when not(finish1 xor finish2) and((ScanlineX > BlockX1 and ScanlineY >= BlockY1 and ScanlineY <= BlockY1 +BLOCKWIDTH and ScanlineX <= BlockX1+"0010"*BLOCKWIDTH and (
																												(ScanlineY >= BlockY1 + "0000000100" and ScanlineY <= BlockY1 + "0000001000" and ((ScanlineX >= BlockX1 + "0000001010" and ScanlineX <= BlockX1 + "0000001110" )or( ScanlineX >= BlockX1 + "0000010110" and ScanlineX <= BlockX1 + "0000011010")or(ScanlineX >= BlockX1 + "0000100110" and ScanlineX <= BlockX1 + "0000101010" )or( ScanlineX >= BlockX1 + "0000110010" and ScanlineX <= BlockX1 + "0000110110")))or
																												(ScanlineY >= BlockY1 + "0000001000" and ScanlineY <= BlockY1 + "0000001100" and ((ScanlineX >= BlockX1 + "0000001000" and ScanlineX <= BlockX1 + "0000010000" )or( ScanlineX >= BlockX1 + "0000010110" and ScanlineX <= BlockX1 + "0000101010")or(ScanlineX >= BlockX1 + "0000110000" and ScanlineX <= BlockX1 + "0000111000" )))or
																												(ScanlineY >= BlockY1 + "0000001100" and ScanlineY <= BlockY1 + "0000010000" and ((ScanlineX >= BlockX1 + "0000000100" and ScanlineX <= BlockX1 + "0000010100" )or( ScanlineX >= BlockX1 + "0000010110" and ScanlineX <= BlockX1 + "0000011010")or(ScanlineX >= BlockX1 + "0000011110" and ScanlineX <= BlockX1 + "0000100010" )or( ScanlineX >= BlockX1 + "0000100110" and ScanlineX <= BlockX1 + "0000101010")or( ScanlineX >= BlockX1 + "0000101100" and ScanlineX <= BlockX1 + "0000111100")))or
																												(ScanlineY >= BlockY1 + "0000010000" and ScanlineY <= BlockY1 + "0000010100" )or
																												(ScanlineY >= BlockY1 + "0000010100" and ScanlineY <= BlockY1 + "0000011000" and ((ScanlineX <= BlockX1 + "0000001000" )or( ScanlineX >= BlockX1 + "0000001010" and ScanlineX <= BlockX1 + "0000001110")or(ScanlineX >= BlockX1 + "0000010000" and ScanlineX <= BlockX1 + "0000110000" )or( ScanlineX >= BlockX1 + "0000110010" and ScanlineX <= BlockX1 + "0000110110")or( ScanlineX >= BlockX1 + "0000111000")))or
																												(ScanlineY >= BlockY1 + "0000011000" and ScanlineY <= BlockY1 + "0000011100" and ((ScanlineX <= BlockX1 + "0000000100" )or( ScanlineX >= BlockX1 + "0000010100" and ScanlineX <= BlockX1 + "0000101100")or(ScanlineX >= BlockX1 + "0000111100" )))or
																												(ScanlineY >= BlockY1 + "0000011100" and ScanlineY <= BlockY1 + "0000100000" and ((ScanlineX >= BlockX1 + "0000011010" and ScanlineX <= BlockX1 + "0000011110" )or( ScanlineX >= BlockX1 + "0000100010" and ScanlineX <= BlockX1 + "0000100110"))))))else
						"110011" when not(finish1 xor finish2) and((ScanlineX > BlockX1 and ScanlineY >= BlockY1 and ScanlineY <= BlockY1 +BLOCKWIDTH and ScanlineX <= BlockX1+"0010"*BLOCKWIDTH and (
																												(ScanlineY >= BlockY1 + "0000001100" and ScanlineY <= BlockY1 + "0000010000" and ((ScanlineX >= BlockX1 + "0000010110" and ScanlineX <= BlockX1 + "0000011110" )or(ScanlineX >= BlockX1 + "0000100010" and ScanlineX <= BlockX1 + "0000100110"))))))else
						
						--shot
						"110000" when not(finish1 xor finish2) and((ScanlineX >= shotX and ScanlineX <= shotX + "000000100" and ScanlineY >= shotY and ScanlineY <= shotY + "000000100"))	else																			
																												
						--others																							 
						"000011" when not(finish1 xor finish2) else
						
						-- "YOU"
						"000011" when (finish1 or finish2) and (((scanlineY >= "11011000" and scanlineY <= "11100000") and ((scanlineX >= "11000000" and scanlineX <= "11001000")or (scanlineX >= "11100000" and scanlineX <= "11101000") or (scanlineX >= "11111000" and scanlineX <= "100001000") or (scanlineX >= "100011000" and scanlineX <= "100100000") or (scanlineX >= "100110000" and scanlineX <= "100111000")))or
																			((scanlineY >= "11100000" and scanlineY <= "11101000") and ((scanlineX >= "11001000" and scanlineX <= "11010000")or (scanlineX >= "11011000" and scanlineX <= "11100000") or (scanlineX >= "11110000" and scanlineX <= "11111000") or (scanlineX >= "100001000" and scanlineX <= "100010000") or (scanlineX >= "100011000" and scanlineX <= "100100000") or (scanlineX >= "100110000" and scanlineX <= "100111000"))))else
						
						"001111" when (finish1 or finish2) and (((scanlineY >= "11101000" and scanlineY <= "11110000") and ((scanlineX >= "11010000" and scanlineX <= "11011000")or (scanlineX >= "11110000" and scanlineX <= "11111000") or (scanlineX >= "100001000" and scanlineX <= "100010000") or (scanlineX >= "100011000" and scanlineX <= "100100000") or (scanlineX >= "100110000" and scanlineX <= "100111000"))))else
						
						"111111" when (finish1 or finish2) and (((scanlineY >= "11110000" and scanlineY <= "11111000") and ((scanlineX >= "11010000" and scanlineX <= "11011000")or (scanlineX >= "11110000" and scanlineX <= "11111000") or (scanlineX >= "100001000" and scanlineX <= "100010000") or (scanlineX >= "100011000" and scanlineX <= "100100000") or (scanlineX >= "100110000" and scanlineX <= "100111000")))or
																			 ((scanlineY >= "11111000" and scanlineY <= "100000000") and ((scanlineX >= "11010000" and scanlineX <= "11011000")or (scanlineX >= "11111000" and scanlineX <= "100001000") or (scanlineX >= "100100000" and scanlineX <= "100110000"))))else
																			 
						"110011" when (finish1 or finish2) and (((scanlineY >= "11100000" and scanlineY <= "11100100") and ((scanlineX >= "11000000" and scanlineX <= "11001000")or (scanlineX >= "11100000" and scanlineX <= "11101000") or (scanlineX >= "11111000" and scanlineX <= "100001000")))or
																			 ((scanlineY >= "11101000" and scanlineY <= "11101100") and ((scanlineX >= "11001000" and scanlineX <= "11010000")or (scanlineX >= "11011000" and scanlineX <= "11100000")))or
																			 ((scanlineY >= "11111000" and scanlineY <= "11111100") and ((scanlineX >= "11110000" and scanlineX <= "11111000")or (scanlineX >= "100001000" and scanlineX <= "100010000") or (scanlineX >= "100011000" and scanlineX <= "100100000")or (scanlineX >= "100110000" and scanlineX <= "100111000")))or
																			 ((scanlineY >= "100000000" and scanlineY <= "100000100") and ((scanlineX >= "11010000" and scanlineX <= "11011000")or (scanlineX >= "11111000" and scanlineX <= "100001000") or (scanlineX >= "100100000" and scanlineX <= "100110000"))))else
						
						-- "LOSE"
						"000011" when ((finish1 or finish2) and not win) and (((scanlineY >= "11011000" and scanlineY <= "11100000") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101110000" and scanlineX <= "110000000") or (scanlineX >= "110011000" and scanlineX <= "110110000") or (scanlineX >= "110111000" and scanlineX <= "111010000")))or
																								((scanlineY >= "11100000" and scanlineY <= "11101000") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101101000" and scanlineX <= "101110000") or (scanlineX >= "110000000" and scanlineX <= "110001000") or (scanlineX >= "110010000" and scanlineX <= "110011000") or (scanlineX >= "110111000" and scanlineX <= "111000000"))))else
						
						"001111" when ((finish1 or finish2) and not win) and (((scanlineY > "11101000" and scanlineY <= "11110000") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101101000" and scanlineX <= "101110000") or (scanlineX >= "110000000" and scanlineX <= "110001000") or (scanlineX >= "110011000" and scanlineX <= "110101000") or (scanlineX >= "110111000" and scanlineX <= "111010000"))))else
						
						"111111" when ((finish1 or finish2) and not win) and (((scanlineY >= "11110000" and scanlineY <= "11111000") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101101000" and scanlineX <= "101110000") or (scanlineX >= "110000000" and scanlineX <= "110001000") or (scanlineX >= "110101000" and scanlineX <= "110110000") or (scanlineX >= "110111000" and scanlineX <= "111000000")))or
																								((scanlineY >= "11111000" and scanlineY <= "100000000") and ((scanlineX >= "101001000" and scanlineX <= "101100000")or (scanlineX >= "101110000" and scanlineX <= "110000000") or (scanlineX >= "110010000" and scanlineX <= "110101000") or (scanlineX >= "110010000" and scanlineX <= "110101000") or (scanlineX >= "110111000" and scanlineX <= "111010000"))))else
						
						"110011" when ((finish1 or finish2) and not win) and (((scanlineY >= "11100000" and scanlineY <= "11100100") and ((scanlineX >= "101110000" and scanlineX <= "110000000")or (scanlineX >= "110011000" and scanlineX <= "110110000") or (scanlineX >= "111000000" and scanlineX <= "111010000")))or
																			 ((scanlineY >= "11101000" and scanlineY <= "11101100") and ((scanlineX >= "110010000" and scanlineX <= "110011000")))or
																			 ((scanlineY >= "11110000" and scanlineY <= "11110100") and ((scanlineX >= "110011000" and scanlineX <= "110101000")or (scanlineX >= "111000000" and scanlineX <= "111010000")))or
																			 ((scanlineY >= "11111000" and scanlineY <= "11111100") and ((scanlineX >= "101101000" and scanlineX <= "101110000")or (scanlineX >= "110000000" and scanlineX <= "110001000") or (scanlineX >= "110101000" and scanlineX <= "110110000")))or
																			 ((scanlineY >= "100000000" and scanlineY <= "100000100") and ((scanlineX >= "101110000" and scanlineX <= "110000000")or(scanlineX >= "101001000" and scanlineX <= "101100000")or (scanlineX >= "110010000" and scanlineX <= "110101000") or (scanlineX >= "110111000" and scanlineX <= "111010000"))))else
						
						-- "WIN"
						"000011" when ((finish1 or finish2) and win) and (((scanlineY >= "11011000" and scanlineY <= "11100000") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101101000" and scanlineX <= "101110000") or (scanlineX >= "101111000" and scanlineX <= "110000000") or (scanlineX >= "110001000" and scanlineX <= "110010000") or (scanlineX >= "110101000" and scanlineX <= "110110000")))or
																						 ((scanlineY >= "11100000" and scanlineY <= "11101000") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101101000" and scanlineX <= "101110000") or (scanlineX >= "101111000" and scanlineX <= "110000000") or (scanlineX >= "110001000" and scanlineX <= "110011000") or (scanlineX >= "110101000" and scanlineX <= "110110000") or (scanlineX >= "101011000" and scanlineX <= "101100000"))))else
																																															--1                                                                     2                                            3                                                     4                                                       5                                                                 
						"001111" when ((finish1 or finish2) and win) and (((scanlineY > "11101000" and scanlineY <= "11110000") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101101000" and scanlineX <= "101110000") or (scanlineX >= "101111000" and scanlineX <= "110000000") or (scanlineX >= "110001000" and scanlineX <= "110010000") or (scanlineX >= "110101000" and scanlineX <= "110110000") or (scanlineX >= "101011000" and scanlineX <= "101100000") or (scanlineX >= "110011000" and scanlineX <= "110100000"))))else
						
						
						"111111" when ((finish1 or finish2) and win) and (((scanlineY >= "11110000" and scanlineY <= "11111000") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101101000" and scanlineX <= "101110000") or (scanlineX >= "101111000" and scanlineX <= "110000000") or (scanlineX >= "110001000" and scanlineX <= "110010000") or (scanlineX >= "110100000" and scanlineX <= "110110000") or (scanlineX >= "101011000" and scanlineX <= "101100000")))or
																						  ((scanlineY >= "11111000" and scanlineY <= "100000000") and ((scanlineX >= "101010000" and scanlineX <= "101011000")or (scanlineX >= "101100000" and scanlineX <= "101101000") or (scanlineX >= "101111000" and scanlineX <= "110000000") or (scanlineX >= "110001000" and scanlineX <= "110010000") or (scanlineX >= "110101000" and scanlineX <= "110110000"))))else
						
						"110011" when ((finish1 or finish2) and win) and (((scanlineY >= "11101000" and scanlineY <= "11101100") and ((scanlineX >= "110010000" and scanlineX <= "110011000")))or
																						  ((scanlineY >= "11110000" and scanlineY <= "11110100") and ((scanlineX >= "110011000" and scanlineX <= "110100000")))or
																						  ((scanlineY >= "11111000" and scanlineY <= "11111100") and ((scanlineX >= "101001000" and scanlineX <= "101010000")or (scanlineX >= "101011000" and scanlineX <= "101100000") or (scanlineX >= "101101000" and scanlineX <= "101110000")or (scanlineX >= "110100000" and scanlineX <= "110101000")))or
																						  ((scanlineY >= "100000000" and scanlineY <= "100000100") and ((scanlineX >= "101010000" and scanlineX <= "101011000")or (scanlineX >= "101100000" and scanlineX <= "101101000") or (scanlineX >= "101111000" and scanlineX <= "110000000") or (scanlineX >= "110001000" and scanlineX <= "110010000") or (scanlineX >= "110101000" and scanlineX <= "110110000"))))else
						
						
						"000000";


	LED <= "11111111" when  led_tmp2 = "11111111" or led_tmp = "11111111" else
			 "00000000";
	ColorOut <= ColorOutput;
	SquareXmax <= "1000000000" - SquareWidth; -- (640 - SquareWidth)


	
	
end Behavioral;