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

--where da bullet?
bullet_x, bullet_y, bullet_dx, bullet_dy = 5, 5, 0 ,0
bullet_over = true
bullet_range = 5
bullet_distance, next_bullet_move = 0, 0

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
	
	-- Initialize main character and shit
	-- Side note: right now, with sizing and everything, it's looking like strength
	-- and such values will max at 180
	char = {strength=70, knowledge=180, energy=90, sanity=130}
	-- Character location set in map function
	
	-- Build map
	-- TODO: Make actual level initiation function, this is more of a placeholder
	makeMap()
	
	-- Initialize functions that are used for creating the info bar
	dofile("sidebar.lua")
end

-- Temporary values...I'm thinking they'll change dynamically or just not be necessary one day
MAPWIDTH = 20
MAPHEIGHT = 30
GENERATIONS = 1
function makeMap()
	map = {}
	for i = 1, MAPWIDTH do
		row = {}
		for j = 1, MAPHEIGHT do
			-- Create random thingy. Again - placeholder, we need to create functions
			-- and algorithms and stuff
			if(i == 1 or j == 1 or j == MAPHEIGHT or i == MAPWIDTH) then
				row[j] = 2
			else
				if(math.random(20) > 15) then
					row[j] = 2
				else
					row[j] = 3
				end
			end
		end
		map[i] = row
	end
	
	-- Cavelike not being used right now
	--for ii = 1, GENERATIONS do
	--	generation()
	--end
	
	-- Set screen offset (for scrolling)
	offset = {x=-15, y=-10}
	char["x"] = 10
	char["y"] = 10
end

-- So uh...this should work, I'm feeling like it's not worth our time to fix unless we're
-- sure we want cavelike levels. If we do want to use it and fix later, refer to
-- http://roguebasin.roguelikedevelopment.org/index.php?title=Cellular_Automata_Method_for_Generating_Random_Cave-Like_Levels
-- For the algorithm
r1_cutoff, r2_cutoff = 5, 2;
function generation()
	newmap = {}
	for i = 2, MAPWIDTH-1 do
		newrow = {}
		for j = 2, MAPHEIGHT-1 do
			adjcount_r1, adjcount_r2 = 0, 0
			for ii=-1,1 do
			for jj=-1,1 do
				if(map[i+ii][j+jj] == 2) then
					adjcount_r1 = adjcount_r1 + 1
				end
			end
			end
			
			for ii=i-2,j+2 do
			for jj=j-2,j+2 do
				if(math.abs(ii-i) + math.abs(jj-j) ~= 4) then
				if(ii > 1 and ii < MAPWIDTH and jj > 1 and jj < MAPHEIGHT) then
					if(map[ii][jj] == 2) then
						adjcount_r2 = adjcount_r2 + 1
					end
				end
				end
			end
			end
			
			if(adjcount_r1 > r1_cutoff or adjcount_r2 > r2_cutoff) then
				newrow[j] = 2
			else
				newrow[j] = 3
			end
		end
		newmap[i] = newrow
	end
	
	for i = 1, table.getn(newmap) do
		if(newmap[i]) then
			for j = 1, table.getn(newmap[i]) do
				if(newmap[i][j]) then
					map[i][j] = newmap[i][j]
				end
			end
		end
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
	love.graphics.print("@", ((char["x"]-1)-offset["x"])*12, ((char["y"]-1)-offset["y"])*12)	
	
	--draw a bullet if we shot one
	--print("bullet at " .. bullet_x .. ", " .. bullet_y)
	if(not bullet_over) then
		love.graphics.print("!", bullet_x*12, bullet_y*12)
	end
	-- Draw sidebar starting at x = 600
	drawSidebar(600)
end

currtime = 0

function love.update(dt)
	--We need this timer here so that all timers are standardized.  Otherwise it's crazy
	--crazy crazy god knows what time it is.
	currtime = love.timer.getMicroTime()
	
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
	
	if(currtime > next_bullet_move and not bullet_over)	then
	
		--did we hit something?
		if(map[bullet_x + 1 + bullet_dx][bullet_y + 1 + bullet_dy] == 2) then
			bullet_over = true
			suspended = false
		end
		
		bullet_x = bullet_x + bullet_dx
		bullet_y = bullet_y + bullet_dy
		
		
		
		bullet_distance = bullet_distance + 1
		next_bullet_move = currtime + .1
		
		if(bullet_distance >= bullet_range) then
			bullet_over = true
			suspended = false
			bullet_distance = 9999
		end
	end
	
	--make sure bullet stops if it reaches its maximum range.
	if(bullet_distance >= bullet_range) then
		bullet_over = true
		suspended = false
		bullet_distance = 9999
	end
end

function love.focus(bool)
end

rightpress = REAL_BIG_NUMBER
leftpress = REAL_BIG_NUMBER
uppress = REAL_BIG_NUMBER
downpress = REAL_BIG_NUMBER

suspended = false
function love.keypressed(key, unicode)
	--print("You pressed " .. key .. ", unicode: " .. unicode)
	--don't let the user make input if we're showing an animation or something
	if(not suspended) then
		
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
		
		--handle numpad keypresses, it's for shooooting.
		--numpad code is formatted as "kp#"
		if(string.sub(key,0,2) == "kp") then
			shoot(string.sub(key,3))
		end
	else
		print("user trying to move while suspended.")
		if(bullet_over) then
			print("bullet IS over...")
		else
			print("bullet is NOT over!")
		end
		print("bullet range is " .. bullet_range .. " bullet distance is " .. bullet_distance)
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
	-- Get outta here if its the edge of the world
	if(map[x] == nil or map[x][y]	== nil) then return end
	
	--for now I'm pretending "2" is a wall
	if(map[x][y] == 2) then
		--do nuffin
	elseif(false) then -- checks for monsters, etc. go here
	
	else-- empty square! we cool.
		char["x"], char["y"] = x, y
		
		-- And lets do some fancy scrolling stuff
		if(table.getn(map[1]) > DISPLAYWIDTH) then -- Only scroll if the map is wide enough
			if(char["x"] - offset["x"] > 40) then -- Moving right
				offset["x"] = char["x"] - 40
			elseif(char["x"] - offset["x"] < 20) then -- Moving left
				offset["x"] = char["x"] - 20
			end
		end
		
		if(table.getn(map) > DISPLAYHEIGHT) then -- Only scroll if the map is tall enough
			if(char["y"] - offset["y"] > 40) then -- Moving down
				offset["y"] = char["y"] - 40
			elseif(char["y"] - offset["y"] < 20) then -- Moving up
				offset["y"] = char["y"] - 20
			end
		end
	end
end

--Just a little thing I maaaade.
--Direction is:

-- 7   8   9
--
-- 4  you  6
-- 
-- 1   2   3

--Fire bullets with the numpad, scoob.

function shoot(direction)
	bullet_x = char_x
	bullet_y = char_y
	print("shootin in " .. direction .. " bullet starts at " .. bullet_x .. ", " .. bullet_y)
	
	bullet_dx = 0
	bullet_dy = 0
	
	if(direction == "7") then
		bullet_dx = -1
		bullet_dy = -1
	elseif(direction == "8") then
		bullet_dx = 0
		bullet_dy = -1
	elseif(direction == "9") then
		bullet_dx = 1
		bullet_dy = -1
	elseif(direction == "4") then
		bullet_dx = -1
		bullet_dy = 0
	elseif(direction == "6") then
		bullet_dx = 1
		bullet_dy = 0
	elseif(direction == "1") then
		bullet_dx = -1
		bullet_dy = 1
	elseif(direction == "2") then
		bullet_dx = 0
		bullet_dy = 1
	elseif(direction == "3") then
		bullet_dx = 1
		bullet_dy = 1
	end
	
	--now, animate the bullet shootin.
	--suspend user input
	suspended = true
	
	--move bullet once so it's not on top of our character
	bullet_x = bullet_x + bullet_dx
	bullet_y = bullet_y + bullet_dy
	
	bullet_over = false
	bullet_distance = 0
	bullet_range = 5
	
	next_bullet_move = currtime + .08
	
	--are we shooting at a wall?
	if(map[bullet_x + 1][bullet_y + 1] == 2) then
		bullet_over = true
		suspended = false
	end
end
--end shoot()
