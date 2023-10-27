library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity CAD971Test is
	Port(
		--//////////// CLOCK //////////
		CLOCK_24 	: in std_logic;
		
		--//////////// KEY //////////
		RESET_N	: in std_logic;
		
		
		--/////////// LED //////////
		
		LED : out std_logic_vector(7 downto 0);
		
		
		--//////////// VGA //////////
		VGA_B		: out std_logic_vector(1 downto 0);
		VGA_G		: out std_logic_vector(1 downto 0);
		VGA_HS	: out std_logic;
		VGA_R		: out std_logic_vector(1 downto 0);
		VGA_VS	: out std_logic;
		
		--//////////// KEYS //////////
		Key : in std_logic_vector(3 downto 0);
		SW : in std_logic_vector(7 downto 0);
		
		--/////////// 7seg ///////////
		EN     			: out STD_LOGIC_VECTOR(3 downto 0);
		SEVENSEGO  		: out  STD_LOGIC_VECTOR(7 downto 0)
	);
end CAD971Test;

--}} End of automatically maintained section

architecture CAD971Test of CAD971Test is

Component VGA_controller
	port (  
			CLK_24MHz		: in std_logic;
         VS				: out std_logic;
			HS					: out std_logic;
			RED				: out std_logic_vector(1 downto 0);
			GREEN				: out std_logic_vector(1 downto 0);
			BLUE				: out std_logic_vector(1 downto 0);
			RESET				: in std_logic;
			ColorIN			: in std_logic_vector(5 downto 0);
			ScanlineX		: out std_logic_vector(10 downto 0);
			ScanlineY		: out std_logic_vector(10 downto 0)
  );
end component;

Component VGA_Square
	port (  
			CLK_24MHz		: in std_logic;
			RESET				: in std_logic;
			ColorOut			: out std_logic_vector(5 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			BLOCKWIDTH		: in std_logic_vector(7 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0);
			LED 				: out std_logic_vector(7 downto 0);
			en      			: out STD_LOGIC_VECTOR(3 downto 0);
			sevensegO  		: out  STD_LOGIC_VECTOR(7 downto 0);
			KEY            : in std_logic_vector(3 downto 0) -- buttons
  );
end component;

signal ScanlineX,ScanlineY	: std_logic_vector(10 downto 0);
signal ColorTable	: std_logic_vector(5 downto 0);

begin

	 --------- VGA Controller -----------
	 VGA_Control: vga_controller
			port map(
				CLK_24MHz	=> CLOCK_24,
				VS			=> VGA_VS,
				HS			=> VGA_HS,
				RED			=> VGA_R,
				GREEN		=> VGA_G,
				BLUE		=> VGA_B,
				RESET		=> not RESET_N,
				ColorIN		=> ColorTable,
				ScanlineX	=> ScanlineX,
				ScanlineY	=> ScanlineY
			);
		
		--------- Moving Square -----------
		VGA_SQ: VGA_Square
			port map(
				CLK_24MHz		=> CLOCK_24,
				RESET				=> not RESET_N,
				ColorOut			=> ColorTable,
				SQUAREWIDTH		=> "00011100", -- 28
				BLOCKWIDTH		=> "00100000", -- 32
				ScanlineX		=> ScanlineX,
				ScanlineY		=> ScanlineY,
				LED            => LED,
				key            => key,
				sevensegO      => sevensegO,
				en             => en
			);
	 

	 
end CAD971Test;
