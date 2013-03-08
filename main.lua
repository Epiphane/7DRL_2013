--        ________
--				 |       |
--				 |       |
--		  _______|_______|
--       |       |
--       |       |
--       |       |_______
--
-- 	COMMENT YOUR CODE
--
--	OR YOU'RE WORSE THAN HITLER

-- handy constants
REAL_BIG_NUMBER = 999999999999

function love.load()
	-- Set background color black, cause it's a console you stupid bitch
	love.graphics.setBackgroundColor( 0, 0, 0 )
	
	-- Load character/NPC/enemy/active objects (x is the random unassigned stuff)
	mainFont = love.graphics.newImageFont ("arial12x12.png", "_!\"#$%&'()*+,-./0123456789:;<=>?@[\\]^_'{|}~"
											.. "xxxxxxxxxxxxxxxxxxxxx"
											.. "xxxxxxxxxxxxxxxxxxxxxxxxx"
											.. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
											.. "abcdefghijklmnopqrstuvwxyz")
	-- Load floor tiles (for theming and shit)
	floorFont = love.graphics.newImageFont ("floorTiles.png", "1234")
	
	-- Build map
	-- TODO: Make actual level initiation function, this is more of a placeholder
	makeMap()
	
	-- ANOTHER PLACEHOLDER: the level should initiate the character position
	char_x = 20
	char_y = 20
	
	-- Initialize functions that are used for creating the info bar
	dofile("sidebar.lua")
end

-- Temporary values...I'm thinking they'll change dynamically or just not be necessary one day
MAPWIDTH = 120
MAPHEIGHT = 90
function makeMap()
	map = {}
	for i = 1, MAPWIDTH do
		row = {}
		for j = 1, MAPHEIGHT do
			-- Create random thingy. Again - placeholder, we need to create functions
			-- and algorithms and shit
			row[j] = math.random(4)
		end
		map[i] = row
	end
end

-- Amount of tiles to display (proportional to display size / 12)
DISPLAYWIDTH = 50
DISPLAYHEIGHT = 50
function love.draw()
	love.graphics.setColor( 128, 128, 128 )
	-- Draw the map
	love.graphics.setFont(floorFont)
	for i = 1, DISPLAYWIDTH do
		for j = 1, DISPLAYHEIGHT do
			love.graphics.print(map[i][j], (i-1)*12, (j-1)*12)
		end
	end
	
	-- Draw characters and shit!
	love.graphics.setFont(mainFont)
	
	-- Main Character
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("@", char_x*12, char_y*12)	
	
	-- Draw sidebar starting at x = 600
	drawSidebar(600)
end

currtime = 0

function love.update(dt)
	--We need this timer here so that all timers are standardized.  Otherwise it's crazy
	--crazy crazy god knows what time it is.
	currtime = love.timer.getTime()
	
	--If any button timers have been held down for a certain amt of time
	--(e.g. their timer "expired" in a sense)
	--press the button again and move the timer forward

	if(currtime > rightpress) then 
		checkThenMove(char_x + 1, char_y)
		rightpress = currtime + .1
	end
	if(currtime > leftpress) then 
		checkThenMove(char_x - 1, char_y)
		leftpress = currtime + .1
	end
	if(currtime > uppress) then
		checkThenMove(char_x, char_y - 1)
		uppress = currtime + .1
	end
	if(currtime > downpress) then
		checkThenMove(char_x, char_y + 1)
		downpress = currtime + .1
	end

end

function love.focus(bool)
end

rightpress = REAL_BIG_NUMBER
leftpress = REAL_BIG_NUMBER
uppress = REAL_BIG_NUMBER
downpress = REAL_BIG_NUMBER
function love.keypressed(key, unicode)
	--print("You pressed " .. key .. ", unicode: " .. unicode)
	if(key == "right") then
		checkThenMove(char_x + 1, char_y)
		rightpress = currtime + .55
		
		--make sure only the LAST thing pressed counts
		leftpress, uppress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
	elseif(key == "left") then
		checkThenMove(char_x - 1, char_y)
		leftpress = currtime + .55
		
		rightpress, uppress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
	elseif(key == "up") then
		checkThenMove(char_x, char_y - 1)
		uppress = currtime + .55
		
		leftpress, rightpress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
	elseif(key == "down") then
		checkThenMove(char_x, char_y + 1)
		downpress = currtime + .55
		
		leftpress, rightpress, uppress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
	end
end

function love.keyreleased(key, unicode)
	-- if a key is released, make sure it doesn't trigger 
	-- the if's up there!
	if(key == "right") then
		rightpress = REAL_BIG_NUMBER
	end
	if(key == "left") then
		leftpress = REAL_BIG_NUMBER
	end
	if(key == "up") then
		uppress = REAL_BIG_NUMBER
	end
	if(key == "down") then
		downpress = REAL_BIG_NUMBER
	end

end

function love.mousepressed(x, y, button)
	print("Current time: " .. currtime)
end

function love.mousereleased(x, y, button)
end

function love.quit()
end

--First, see if there's any obstacles/monsters
--on the designated square.  If there's none,
--move the player character there.

--If there is a monster there, attack it!
--If there's a wall there, just don't do nuffin.
function checkThenMove(x, y)
	--for now I'm pretending "2" is a wall
	--...for some reason the map is offset by a little bit.  Go figure.
	if(map[x+1][y+1] == 2) then
		--do nuffin
	elseif(false) then -- checks for monsters, etc. go here
	
	else-- empty square! we cool.
		char_x, char_y = x, y
	end
end

