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
	
	-- Initialize main character and shit
	-- Side note: right now, with sizing and everything, it's looking like strength
	-- and such values will max at 180
	char = {strength=70, knowledge=180, energy=90, sanity=130}
	-- ANOTHER PLACEHOLDER: the level should initiate the character position
	char["x"] = 20
	char["y"] = 20
	
	-- Initialize functions that are used for creating the info bar
	dofile("sidebar.lua")
end

-- Temporary values...I'm thinking they'll change dynamically or just not be necessary one day
MAPWIDTH = 100
MAPHEIGHT = 100
function makeMap()
	map = {}
	for i = 1, MAPWIDTH do
		row = {}
		for j = 1, MAPHEIGHT do
			-- Create random thingy. Again - placeholder, we need to create functions
			-- and algorithms and stuff
			if i*j < 400 then
				row[j] = 2
			elseif i*j < 1600 then
				row[j] = 3
			else
				row[j] = 4
			end
		end
		map[i] = row
	end
	
	-- Set screen offset (for scrolling)
	offset = {x=0, y=0}
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
			-- Do null checks first: add offset["x"] and offset["y"] to show right part of map
			if(map[i+offset["x"]] and map[i+offset["x"]][j+offset["y"]]) then
				love.graphics.print(map[i+offset["x"]][j+offset["y"]], (i-1)*12, (j-1)*12)
			else
				love.graphics.print(1, (i-1)*12, (j-1)*12)
			end
		end
	end
	
	-- Draw characters and shit!
	love.graphics.setFont(mainFont)
	
	-- Main Character
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("@", (char["x"]-offset["x"])*12, (char["y"]-offset["y"])*12)	
	
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
		checkThenMove(char["x"] + 1, char["y"])
		rightpress = currtime + .1
	end
	if(currtime > leftpress) then 
		checkThenMove(char["x"] - 1, char["y"])
		leftpress = currtime + .1
	end
	if(currtime > uppress) then
		checkThenMove(char["x"], char["y"] - 1)
		uppress = currtime + .1
	end
	if(currtime > downpress) then
		checkThenMove(char["x"], char["y"] + 1)
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
		checkThenMove(char["x"] + 1, char["y"])
		rightpress = currtime + .55
		
		--make sure only the LAST thing pressed counts
		leftpress, uppress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
	elseif(key == "left") then
		checkThenMove(char["x"] - 1, char["y"])
		leftpress = currtime + .55
		
		rightpress, uppress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
	elseif(key == "up") then
		checkThenMove(char["x"], char["y"] - 1)
		uppress = currtime + .55
		
		leftpress, rightpress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
	elseif(key == "down") then
		checkThenMove(char["x"], char["y"] + 1)
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
		char["x"], char["y"] = x, y
		
		-- And lets do some fancy scrolling stuff
		if(char["x"] - offset["x"] > 40) then -- Moving right
			offset["x"] = char["x"] - 40
		elseif(char["x"] - offset["x"] < 20) then -- Moving left
			offset["x"] = char["x"] - 20
		end
		
		if(char["y"] - offset["y"] > 40) then -- Moving down
			offset["y"] = char["y"] - 40
		elseif(char["y"] - offset["y"] < 20) then -- Moving up
			offset["y"] = char["y"] - 20
		end
	end
end

