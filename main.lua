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
bullet = {x=5, y=5, dx=0, dy=0, over=true, range=5, distance=0, nextmove=0}

enemies = {}
num_enemies = 0

tile_info = {{blocker=false}, 
			{blocker=true, message="You walk headlong into a wall.", awesome_effect=-2}, 
			{blocker=false}, 
			{blocker=true, walk_trans=5, message="You open the door.", awesome_effect=0}, -- Door turns into an opened door
			{blocker=false},
			{blocker=true},
			{blocker=true, walk_trans=5, message="The door thunders open.", awesome_effect=0}}

function love.load()
	-- Set background color black, cause it's a console you stupid bitch
	love.graphics.setBackgroundColor( 0, 0, 0 )
	
	-- Load character/NPC/enemy/active objects (x is the random unassigned stuff)
	mainFont = love.graphics.newImageFont ("arial12x12.png", " !\"#$%&'()*+,-./0123456789:;<=>?@[\\]^_'{|}~"
											.. "xxxxxxxxxxxxxxxxxxxxx"
											.. "xxxxxxxxxxxxxxxxxxxxxxxxx"
											.. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
											.. "abcdefghijklmnopqrstuvwxyz")
	-- Load floor tiles (for theming and shit)
	floorFont = love.graphics.newImageFont ("floorTiles.png", "1234567")
	
	-- Initialize main character and shit
	-- Side note: right now, with sizing and everything, it's looking like strength
	-- and such values will max at 180
	char = {awesome=100}
	-- Character location set in map function
	
	-- Build map
	-- TODO: Make actual level initiation function, this is more of a placeholder
	makeMap()
	
	-- spawn enemies
	-- TODO: where???
	spawnEnemy(10,20,"zombie")
	spawnEnemy(12,12,"robot")
	
	-- Initialize functions that are used for creating the info bar
	dofile("sidebar.lua")
	
	-- Initialize line of sight functions MAYBE
	--dofile("los_functions.lua")
end

-- Temporary values...I'm thinking they'll change dynamically or just not be necessary one day
MAPWIDTH = 24
MAPHEIGHT = 24
ROOMNUM = 1
WALL_NUM = 2 -- Wall num constant
viewed_rooms = {}
function makeMap()
	map = {}
	for i = 1, MAPWIDTH do
		row = {}
		for j = 1, MAPHEIGHT do
			-- Create random thingy. Again - placeholder, we need to create functions
			-- and algorithms and stuff
			if(i == 1 or j == 1 or j == MAPHEIGHT or i == MAPWIDTH) then
				row[j] = {tile=WALL_NUM, room=ROOMNUM}
			else
				row[j] = {tile=3, room=ROOMNUM}
			end
		end
		map[i] = row
	end
	
	-- Create rooms
	j = 1
	repeat
		next_j = j+8+math.random(8)
		-- Boundary check
		if(next_j + 5 > MAPHEIGHT) then 
			next_j = MAPHEIGHT
		end
		
		i = 1
		repeat
			next_i = i+8+math.random(8)
			-- Boundary check
			if(next_i + 5 > MAPWIDTH) then 
				next_i = MAPWIDTH 
			end
			
			-- Make a room with the coordinates as stated
			makeRoom(i, j, next_i, next_j, ROOMNUM)
			i = next_i
			ROOMNUM = ROOMNUM + 1
		until i == MAPWIDTH
		j = next_j
	until j == MAPHEIGHT
	
	-- Make boss room corridor
	start_i = MAPWIDTH
	CORRIDORWIDTH = 13 + math.random(15)
	end_i = start_i + CORRIDORWIDTH
	start_j = MAPHEIGHT/2
	while(tile_info[map[start_i-1][start_j]["tile"]]["blocker"]) do -- In case we put corridor against a wall
		start_j = start_j - 1
	end
	map[start_i][start_j]["tile"] = 3
	for i = start_i+1,end_i do
		map[i] = {}
		map[i][start_j - 1] = {tile=WALL_NUM, room=998}
		map[i][start_j] = {tile=3, room=998}
		map[i][start_j + 1] = {tile=WALL_NUM, room=998}
	end
	map[end_i][start_j]["tile"] = 7
	ROOMNUM = ROOMNUM + 1
	
	-- Set character location
	char["x"] = MAPWIDTH/4 + math.random(MAPWIDTH/2)
	char["y"] = MAPHEIGHT/4 + math.random(MAPHEIGHT/2)
	-- Set screen offset (for scrolling)
	offset = {x=char["x"]-20, y=char["y"]-30}
	while(tile_info[map[char["x"]][char["y"]]["tile"]]["blocker"]) do
		char["x"] = char["x"] + 1
		char["y"] = char["y"] + 1
	end
	char["room"] = map[char["x"]][char["y"]]["room"]
	viewed_rooms[char["room"]] = true
end

-- Fill a room with generic wall/floor
function makeRoom(start_i, start_j, end_i, end_j, roomnum)
	for i = start_i, end_i do
		for j = start_j, end_j do
			if(i == start_i or j == start_j or j == end_j or i == end_i) then
				map[i][j] = {tile=WALL_NUM, room=roomnum} -- Wall
			else
				map[i][j] = {tile=3, room=roomnum} -- Floor
			end
		end
	end
	
	if(start_i ~= 1) then -- Put a doorway!
		map[start_i][start_j+2 + math.random(end_j-start_j-4)] = {tile=4, room=roomnum} -- Floor
	end
	
	if(start_j ~= 1) then -- Put top doorways!
		walk_start_i = start_i -- "Walk" along the top wall and find good doorway walls
		for walk_end_i = walk_start_i + 1,end_i do
			if(map[walk_end_i][start_j-1]["tile"] == WALL_NUM 
				or map[walk_end_i][start_j+1]["tile"] == WALL_NUM) then
				diff = walk_end_i - walk_start_i
				if(diff > 3) then
					map[walk_start_i+2+math.random(diff-3)][start_j]["tile"] = 4
				end
				walk_start_i = walk_end_i + 1
				walk_end_i = walk_start_i + 1
			end
		end
	end
end

-- Amount of tiles to display (proportional to display size / 12)
DISPLAYWIDTH = 40
DISPLAYHEIGHT = 50
function love.draw()
	-- Draw the map
	love.graphics.setFont(floorFont)
	for i = 1, DISPLAYWIDTH do
		for j = 1, DISPLAYHEIGHT do
			-- Do null checks first: add offset["x"] and offset["y"] to show right part of map
			if(map[i+offset["x"]] and map[i+offset["x"]][j+offset["y"]]) then
				-- Tint is how bright to make it
				love.graphics.setColor( 0, 0, 0 ) -- Dim for not in room
				for x_o=-1,0 do	-- This is for walls: if the top-left is in your room,
				for y_o=-1,0 do -- Light this up for aesthetics
					if(map[i+offset["x"]+x_o] and map[i+offset["x"]+x_o][j+offset["y"]+y_o]) then
						roomnum = map[i+offset["x"]+x_o][j+offset["y"]+y_o]["room"]
						if roomnum == char["room"] then
							love.graphics.setColor( 255, 255, 255 ) -- LIGHT 'ER UP
						elseif viewed_rooms[roomnum] then
							-- TODO: Smarter way to figure out if its 255, 255, 255
							r, g, b, a = love.graphics.getColor()
							if(r ~= 255) then
								if(char["room"] == 998) then -- Corridor: Tint darker the farther you get
									tint = (MAPWIDTH - char["x"])*255/CORRIDORWIDTH
									love.graphics.setColor( tint, tint, tint )
								else
									love.graphics.setColor( 100, 100, 100 )
								end
							end
						end
					end
				end
				end
				love.graphics.print(map[i+offset["x"]][j+offset["y"]]["tile"], (i-1)*12, (j-1)*12)
			else
				love.graphics.print(1, (i-1)*12, (j-1)*12)
			end
		end
	end
	
	-- Set color back to gray
	love.graphics.setColor( 128, 128, 128 )
	
	-- Draw characters and shit!
	love.graphics.setFont(mainFont)
	
	-- Main Character
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("@", ((char["x"]-1)-offset["x"])*12, ((char["y"]-1)-offset["y"])*12)	
	
	--draw a bullet if we shot one
	--print("bullet at " .. bullet["x"] .. ", " .. bullet["y"])
	if(not bullet["over"]) then
		love.graphics.print("!", (bullet["x"] - offset["x"])*12, (bullet["y"] - offset["y"])*12)
	end
	
	--draw enemies
	for i = 0, num_enemies do
		ex = enemies["enemy" .. i .. "x"]
		ey = enemies["enemy" .. i .. "y"]
		which = enemies["enemy" .. i .. "whichEnemy"]
		--print("ex: " .. ex .. " and ey " .. ey)
		
		if(which == "zombie") then
			love.graphics.print("Z", (ex - offset["x"]) * 12, (ey - offset["y"])*12)
		end
		
		if(which == "robot") then
			love.graphics.print("R", (ex - offset["x"]) * 12, (ey - offset["y"])*12)
		end
	end
	
	-- Draw sidebar starting at x = 600
	drawSidebar(480)
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
	
	if(currtime > bullet["nextmove"] and not bullet["over"])	then
	
		--did we hit something?
		if(tile_info[map[bullet["x"] + 1 + bullet["dx"]][bullet["y"] + 1 + bullet["dy"]]["tile"]]["blocker"]) then
			bullet["over"] = true
			suspended = false
		end
		
		bullet["x"] = bullet["x"] + bullet["dx"]
		bullet["y"] = bullet["y"] + bullet["dy"]
		
		bullet["distance"] = bullet["distance"] + 1
		bullet["nextmove"] = currtime + .1
		
		if(bullet["distance"] >= bullet["range"]) then
			bullet["over"] = true
			suspended = false
			bullet["distance"] = 9999
		end
	end
	
	--make sure bullet stops if it reaches its maximum range.
	if(bullet["distance"] >= bullet["range"]) then
		bullet["over"] = true
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
		
		--handle numpad keypresses, it's for shooooting.
		--numpad code is formatted as "kp#"
		if(string.sub(key,0,2) == "kp") then
			shoot(string.sub(key,3))
		end
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
	
	tile = map[x][y]["tile"]
	--for now I'm pretending "2" is a wall
	if(tile_info[tile]["blocker"]) then
		-- Random stuff that sends a message
		printSide(tile_info[tile]["message"])
		-- Or adds/subtracts awesome
		char['awesome'] = char['awesome'] + tile_info[tile]["awesome_effect"]
		if(tile_info[tile]["walk_trans"]) then
			map[x][y]["tile"] = tile_info[tile]["walk_trans"]
		end
	elseif(false) then -- checks for monsters, etc. go here
	
	else-- empty square! we cool.
		char["x"], char["y"] = x, y
		char["room"] = map[char["x"]][char["y"]]["room"]
		viewed_rooms[char["room"]] = true
		
		-- And lets do some fancy scrolling stuff
		--if(table.getn(map) > DISPLAYWIDTH) then -- Only scroll if the map is wide enough
			if(char["x"] - offset["x"] > 30) then -- Moving right
				offset["x"] = char["x"] - 30
			elseif(char["x"] - offset["x"] < 20) then -- Moving left
				offset["x"] = char["x"] - 20
			end
		--end
		
		--if(table.getn(map[1]) > DISPLAYHEIGHT) then -- Only scroll if the map is tall enough
			if(char["y"] - offset["y"] > 40) then -- Moving down
				offset["y"] = char["y"] - 40
			elseif(char["y"] - offset["y"] < 20) then -- Moving up
				offset["y"] = char["y"] - 20
			end
		--	end
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
	bullet["x"] = char["x"] - 1
	bullet["y"] = char["y"] - 1
	
	bullet["dx"] = 0
	bullet["dy"] = 0
	
	if(direction == "7") then
		bullet["dx"] = -1
		bullet["dy"] = -1
	elseif(direction == "8") then
		bullet["dx"] = 0
		bullet["dy"] = -1
	elseif(direction == "9") then
		bullet["dx"] = 1
		bullet["dy"] = -1
	elseif(direction == "4") then
		bullet["dx"] = -1
		bullet["dy"] = 0
	elseif(direction == "6") then
		bullet["dx"] = 1
		bullet["dy"] = 0
	elseif(direction == "1") then
		bullet["dx"] = -1
		bullet["dy"] = 1
	elseif(direction == "2") then
		bullet["dx"] = 0
		bullet["dy"] = 1
	elseif(direction == "3") then
		bullet["dx"] = 1
		bullet["dy"] = 1
	end
	
	--now, animate the bullet shootin.
	--suspend user input
	suspended = true
	
	--move bullet once so it's not on top of our character
	bullet["x"] = bullet["x"] + bullet["dx"]
	bullet["y"] = bullet["y"] + bullet["dy"]
	
	bullet["over"] = false
	bullet["distance"] = 0
	bullet["range"] = 5
	
	bullet["nextmove"] = currtime + .08
	
	--are we shooting at a wall?
	if(tile_info[map[bullet["x"] + 1][bullet["y"] + 1]["tile"]]["blocker"]) then
		bullet["over"] = true
		suspended = false
	end
end
--end shoot()

--spawns an enemy @ x, y
function spawnEnemy(x, y, which_enemy)
	--look at the length, go +1
	num_enemies = num_enemies + 1
	
	print(#enemies .. " hmm")
	
	enemystring = "enemy" .. (num_enemies)
	
	enemies[enemystring .. "x"] = x
	enemies[enemystring .. "y"] = y
	
	enemies[enemystring .. "whichEnemy"] = which_enemy
	
	print("added enemy! ex at " .. enemystring .."x is " .. enemies[enemystring .. "x"] .."!")

end
--end spawnEnemy

--called whenever player shoots/moves/pulls lever/whatever.
--all enemies get to move, bombs go off, fires spread, whatever.
function doTurn()
	for i = 0, num_enemies do
		enemyTurn(i)
	end
end
--end doTurn()

--controls enemy movement/attack patterns.
function enemyTurn(id)
	


end
--end enemyTurn()
