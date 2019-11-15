--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY hw_image_generator IS
	PORT(
		switch0		:	IN		STD_LOGIC;
		switch1		:	IN		STD_LOGIC;
		lbutton		:	IN		STD_LOGIC;
		rbutton		:	IN		STD_LOGIC;
		clk			:	IN		STD_LOGIC;
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
	TYPE		STATE_TYPE IS(STANDBY, OVER, EASY, MEDIUM, HARD);
	SIGNAL	state			: STATE_TYPE;
	SIGNAL 	gameover			: BOOLEAN;
	
	SIGNAL 	speedx, speedy: INTEGER;
	SIGNAL	x	: INTEGER RANGE 300 TO 1220:= 600;
	SIGNAL 	y	: INTEGER RANGE -50 TO 1080:= 200;
	SIGNAL	speed: INTEGER;
	SIGNAL 	x1	: INTEGER RANGE 300 TO 1220:= 300;
	SIGNAL 	y1	: INTEGER RANGE -60 TO 1200:= 0;
	SIGNAL 	x2	: INTEGER RANGE 300 TO 1220:= 500;
	SIGNAL 	y2	: INTEGER RANGE -60 TO 1200:= 300;
	SIGNAL 	x3	: INTEGER RANGE 300 TO 1220:= 700;
	SIGNAL 	y3	: INTEGER RANGE -60 TO 1200:= 600;
	SIGNAL 	x4	: INTEGER RANGE 300 TO 1220:= 900;
	SIGNAL 	y4	: INTEGER RANGE -60 TO 1200:= 900;
	
	SIGNAL clk50:	STD_LOGIC_VECTOR(24 DOWNTO 0);
	SIGNAL rand:	INTEGER RANGE 0 TO 920 := 920;
BEGIN
	
	DRAW: PROCESS(disp_ena, row, column, clk)
	BEGIN
		IF(disp_ena = '1') THEN		--display time
			IF row > 300 AND row < 1620 AND column > 0 AND column < 1080 THEN		-- Draw the frame where the game takes place
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			ELSE
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			END IF;
			
			IF row > x1 AND row < x1 + 400 AND column > y1 AND column < y1 + 40 THEN		-- Draw the first bar
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			END IF;
			
			IF row > x2 AND row < x2 + 400 AND column > y2 AND column < y2 + 40 THEN		-- Draw the second bar
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			END IF;
			
			IF row > x3 AND row < x3 + 400 AND column > y3 AND column < y3 + 40 THEN		-- Draw the third bar
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			END IF;
			
			IF row > x4 AND row < x4 + 400 AND column > y4 AND column < y4 + 40 THEN		-- Draw the fourth bar
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			END IF;
			
			IF row > x AND row < x + 50 AND column > y AND column < y + 50 THEN		-- Draw the box representing the player
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			END IF;
			
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	END PROCESS DRAW;
	
	SWITCH: PROCESS(switch0, switch1, state)
	BEGIN
		IF gameover = FALSE THEN
			IF switch1 = '0' AND switch0 = '1' THEN
				state <= EASY;
			ELSIF switch1 = '1' AND switch0 = '0' THEN
				state <= MEDIUM;
			ELSIF switch1 = '1' AND switch0 = '1' THEN
				state <= HARD;
			ELSE
				state <= STANDBY;
			END IF;
		ELSE
			state <= OVER;
		END IF;
	END PROCESS SWITCH;
	
	SPEED_CONTROL: PROCESS(state)
	BEGIN
		CASE state IS
			WHEN STANDBY =>
				speed <= 0;
				speedx <= 0;
				speedy <= 0;
			WHEN OVER =>
				speed <= 0;
				speedx <= 0;
				speedy <= 0;
			WHEN EASY =>
				speed <= 3;
				speedx <= 10;
				speedy <= 7;
			WHEN MEDIUM =>
				speed <= 5;
				speedx <= 10;
				speedy <= 10;
			WHEN HARD =>
				speed <= 8;
				speedx <= 10;
				speedy <= 14;
		END CASE;
	END PROCESS SPEED_CONTROL;
	
	GAME: PROCESS(clk)
	BEGIN
		IF clk'event AND clk = '1' THEN
			IF clk50 < "11110100001001000000" THEN
				clk50 <= clk50 + 1;
			ELSE
				IF y1 > -60 THEN		-- Move bars upward
					y1 <= y1 - speed;
				ELSE
					y1 <= y4 + 300;
				END IF;
				
				IF y2 > -60 THEN		-- Move bars upward
					y2 <= y2 - speed;
				ELSE
					y2 <= y1 + 300;
				END IF;
				
				IF y3 > -60 THEN		-- Move bars upward
					y3 <= y3 - speed;
				ELSE
					y3 <= y2 + 300;
				END IF;
				
				IF y4 > -60 THEN		-- Move bars upward
					y4 <= y4 - speed;
				ELSE
					y4 <= y3 + 300;
				END IF;
				
				IF y = y1 - 50 THEN									-- Move the box with the bars when the box is on the bars
					IF x >= x1 AND x <= x1 + 350 THEN
						y <= y1 - 50;
					END IF;
				ELSIF y = y2 - 50 THEN
					IF x >= x2 AND x <= x2 + 350 THEN
						y <= y2 - 50;
					END IF;
				ELSIF y = y3 - 50 THEN
					IF x >= x3 AND x <= x3 + 350 THEN
						y <= y3 - 50;
					END IF;
				ELSIF y = y4 - 50 THEN
					IF x >= x4 AND x <= x4 + 350 THEN
						y <= y4 - 50;
					END IF;
				ELSE												-- Let the box fall when it does not touch any bar
					y <= y + 0;
				END IF;
				
				IF y <= 0 THEN				-- The box cannot move outside the frame
					y <= 0;
--					gameover <= true;
				ELSIF y >= 1030 THEN
					y <= 1030;
--					gameover <= true;
				END IF;
				
				clk50 <= (others => '0');
			END IF;
			
			IF rand > 0 THEN
				rand <= rand - 10;
			ELSE
				rand <= 920;
			END IF;
		END IF;
	END PROCESS GAME;
	
	RANDOMX: PROCESS(state)
	BEGIN
		IF state /= OVER AND state /= STANDBY THEN
			IF y1 = -60 THEN
				x1 <= 300 + rand;
			END IF;
			
			IF y2 = -60 THEN
				x2 <= 300 + rand;
			END IF;
			
			IF y3 = -60 THEN
				x3 <= 300 + rand;
			END IF;
			
			IF y4 = -60 THEN
				x4 <= 300 + rand;
			END IF;
		END IF;
	END PROCESS RANDOMX;
	
	CONTROL: PROCESS(lbutton, rbutton)
	BEGIN
		IF state /= OVER AND state /= STANDBY THEN
			IF lbutton = '0' AND rbutton = '1' THEN
				x <= x - speedx;
			END IF;
			IF lbutton = '1' AND rbutton = '0' THEN
				x <= x + speedx;
			END IF;
		END IF;
	END PROCESS CONTROL;
END behavior;

