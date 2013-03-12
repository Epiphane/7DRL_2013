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

enemies = {}
objects = {}

--how big each frame of the explosion is
sizes1 = {1,1,2,2,4,4,4,6,0}
sizeindex = 1
--how much empty space is present in each iteration of the explosion
--1 is tight explosion, 9 is barely any flames and stuff
dispersion1 = {0,0,0,0,3,5,7,9,0}

--is explosion happening?
exploding = false
explosionTiles = {}
explosion = {x=5, y=5, size=5, friendlyFire = false}



function love.load()
	level = 1
	
	-- Initialize functions that are used for creating the info bar
	dofile("sidebar.lua")
	
	-- Initialize everything Tile
	dofile("tiles.lua")
	
	-- Initialize everything Enemy
	dofile("enemies.lua")
	
	-- Initialize everything that has to do with weaponry
	dofile("weapons.lua")
	
	-- Initialize everything that has to do with objects
	dofile("objects.lua")
	
	-- Set background color black, cause it's a console you stupid bitch
	love.graphics.setBackgroundColor( 0, 0, 0 )
	
	-- Load character/NPC/enemy/active objects (x is the random unassigned stuff)
	mainFont = love.graphics.newImageFont ("arial12x12.png", " !\"#$%&'()*+,-./0123456789:;<=>?@[\\]^_'{|}~"
											.. "xxxxxxxxxxxxxxxxxxxxx"
											.. "xxxxxxxxxxxxOxxxxxxxxxxxx"
											.. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
											.. "abcdefghijklmnopqrstuvwxyz")
	-- Load floor tiles (for theming and shit)
	floorFont = love.graphics.newImageFont ("floorTiles.png", "12345678")
	
	-- Initialize main character and shit
	-- Side note: right now, with sizing and everything, it's looking like strength
	-- and such values will max at 180
	dofile("character.lua")
	-- Character location set in map function
	
	-- Build map
	-- TODO: Make actual level initiation function, this is more of a placeholder
	makeMap()
	
	explosionTiles = {}
    for i=-13,13 do
		explosionTiles[i] = {}     -- initialize multidimensional array
		for j=-13,13 do
			explosionTiles[i][j] = "-1+-1+-1"
		end
    end
	
	-- spawn enemies
	-- TODO: where???
	
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
				row[j] = Wall:new{room={[ROOMNUM]=true}}
			else
				row[j] = Floor:new{room={[ROOMNUM]=true}}
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
			makeRoomAndDoors(i, j, next_i, next_j, ROOMNUM)
			i = next_i
			ROOMNUM = ROOMNUM + 1
		until i == MAPWIDTH
		j = next_j
	until j == MAPHEIGHT
	
	-- Make boss room corridor
	start_i = MAPWIDTH
	CORRIDORWIDTH = 24 + math.random(8)
	end_i = start_i + CORRIDORWIDTH
	start_j = MAPHEIGHT/2
	while(map[start_i-1][start_j].blocker) do -- In case we put corridor against a wall
		start_j = start_j - 1
	end
	k, v = next(map[start_i-1][start_j].room, nil)
	map[start_i][start_j] = CrackedWall:new{room={[998]=true, [k]=true}}
	table.insert(map[start_i][start_j-1].room, {[998]=true})
	table.insert(map[start_i][start_j+1].room, {[998]=true})
	-- JUST FOR FIRST LEVEL: SPAWN BARREL THAT MUST EXPLODE TO GET TO BOSS
	if level == 1 then
		spawnEnemy(start_i-1, start_j, Barrel)
	end
	
	for i = start_i+1,end_i do
		map[i] = {}
		map[i][start_j - 1] = Wall:new{room={[998]=true}}
		map[i][start_j] = Floor:new{room={[998]=true}}
		map[i][start_j + 1] = Wall:new{room={[998]=true}}
	end
	thunderingDoor = ThunderingDoor:new{room={[998]=true}}
	map[end_i][start_j] = thunderingDoor -- Make thundering door
	ROOMNUM = ROOMNUM + 1
	
	-- Make boss room!
	start_i = end_i + 1
	end_i = start_i + 20
	for i=start_i,end_i do map[i] = {} end -- Make rows
	makeRoom(start_i, start_j - 10, end_i, start_j + 10, 999)
	map[start_i][start_j] = DoorSealer:new{room={[999]=true}, door_to_seal={x=start_i-1, y=start_j}} -- Make thundering door lever
	
	-- Set character location
	char["x"] = MAPWIDTH/4 + math.random(MAPWIDTH/2)
	char["y"] = MAPHEIGHT/4 + math.random(MAPHEIGHT/2)
	-- Set screen offset (for scrolling)
	offset = {x=char["x"]-20, y=char["y"]-30}
	while(map[char["x"]][char["y"]].blocker) do
		char["x"] = char["x"] + 1
		char["y"] = char["y"] + 1
	end
	
	-- Put character in the room
	k, v = next(map[char["x"]][char["y"]].room, nil)
	char["room"] = k
	viewed_rooms[k] = true
end

-- Automatically add doors to the room
function makeRoomAndDoors(start_i, start_j, end_i, end_j, roomnum)
	makeRoom(start_i, start_j, end_i, end_j, roomnum, true)
end

-- Fill a room with generic wall/floor
function makeRoom(start_i, start_j, end_i, end_j, roomnum, makeDoors)
	for i = start_i, end_i do
		if not map[i] then map[i] = {} end
		for j = start_j, end_j do
			if(i == start_i or j == start_j or j == end_j or i == end_i) then
				map[i][j] = Wall:new{room={[roomnum]=true}} -- Wall
			else
				map[i][j] = Floor:new{room={[roomnum]=true}} -- Floor
			end
			
			-- if its the top or left of a room we need to make special...modifications
			-- so that it shows
			if(i == start_i and i > 1) then
				if map[i-1][j] then
					for k, v in pairs(map[i-1][j].room) do 
						map[i][j].room[k] = true
					end
				end
			end
			if(j == start_j and j > 1) then
				if map[i][j-1] then
					for k, v in pairs(map[i][j-1].room) do 
						map[i][j].room[k] = true
					end
				end
			end
		end
	end
	
	if makeDoors then
		if(start_i ~= 1) then -- Put a doorway!
			j_val = start_j+2 + math.random(end_j-start_j-4)
			k,v = next(map[start_i-1][j_val].room,nil)
			map[start_i][j_val] = Door:new{room={[roomnum]=true, [k]=true}} -- Floor
		end
		
		if(start_j ~= 1) then -- Put top doorways!
			walk_start_i = start_i -- "Walk" along the top wall and find good doorway walls
			for walk_end_i = walk_start_i + 1,end_i do
				if(map[walk_end_i][start_j-1].blocker
					or map[walk_end_i][start_j+1].blocker) then
					diff = walk_end_i - walk_start_i
					if(diff > 3) then
						i_val = walk_start_i+2+math.random(diff-3)
						k,v = next(map[i_val][start_j-1].room,nil)
						map[i_val][start_j] = Door:new{room={[roomnum]=true, [k]=true}}
					end
					walk_start_i = walk_end_i + 1
					walk_end_i = walk_start_i + 1
				end
			end
		end
	end
	
	-- TIME TO CUSTOMIZE THE ROOMS. THIS IS WHERE SHIT GETS REAL
	-- SO WATCH OUT
	if(level == 1) then -- Beginner level. we need specific rooms
		if(roomnum == 1) then
			spawnObject(start_i + 2 + math.random(end_i-start_i-4), start_j + 2 + math.random(end_j-start_j-4), Pistol)
		elseif(roomnum == 2) then
			spawnEnemy(5, 5, Rat)
		elseif(roomnum == 3) then
		elseif(roomnum == 4) then
		end
	end
end

-- Amount of tiles to display (proportional to display size / 12)
DISPLAYWIDTH = 40
DISPLAYHEIGHT = 50

--how much offset to have for the screenshake
screenshake = 0

function love.draw()
	-- Draw the map
	love.graphics.setFont(floorFont)
	for i = 1, DISPLAYWIDTH do
		for j = 1, DISPLAYHEIGHT do
			-- Do null checks first: add offset["x"] and offset["y"] to show right part of map
			if(map[i+offset["x"]] and map[i+offset["x"]][j+offset["y"]]) then
				-- Tint is how bright to make it
				map[i+offset["x"]][j+offset["y"]]:setColor(char["room"])
				love.graphics.print(map[i+offset["x"]][j+offset["y"]].tile, (i-1)*12, (j-1)*12 + screenshake)
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
	love.graphics.print("@", ((char["x"]-1)-offset["x"])*12, ((char["y"]-1)-offset["y"])*12 + screenshake)	
	
	--draw a bullet if we shot one
	--print("bullet at " .. bullet["x"] .. ", " .. bullet["y"])
	char.weapon:draw()
	
	--draw objects
	for i = 1, # objects do
		objects[i]:draw()
	end
	
	--draw enemies
	for i = 1, # enemies do
		enemies[i]:draw()
	end
	
	--drawsplosion if we're sploding
	if(exploding) then
		iterateExplosion()
	
		love.graphics.setColor(255,255,0)
		love.graphics.rectangle("fill",0,0,24,24)
		for explosionX = -13, 13 do
			for explosionY = -13, 13 do
				
				rindex = string.find(explosionTiles[explosionX][explosionY], "+")
				
				--pull out the r, g, and b index values
				r = tonumber(string.sub(explosionTiles[explosionX][explosionY], 0, rindex - 1))
				
				gindex = string.find(explosionTiles[explosionX][explosionY], "+", rindex + 1) 
				
				g = tonumber(string.sub(explosionTiles[explosionX][explosionY], 
					rindex + 1, gindex - 1))
				
				bindex = string.find(explosionTiles[explosionX][explosionY], "+", gindex) 
				
				b = tonumber(string.sub(explosionTiles[explosionX][explosionY], 
					bindex + 1))
				
				local drawX = explosion["x"] + explosionX
				local drawY = explosion["y"] + explosionY
				if map[drawX] and map[drawX][drawY] then
					tile = map[drawX][drawY]
					--check to see if the square is empty, and can thus receive splosions.
					if(r~= -1 and not tile.blocker and tile.room[char.room]) then
						love.graphics.setColor(r, g, b)
						love.graphics.rectangle( "fill", (drawX-offset["x"]-1) * 12, (drawY-offset["y"]-1) * 12 + screenshake, 12, 12)
					end
				end
			end
		end
	end
	
	-- Draw sidebar starting at x = 600
	drawSidebar(480)
end

currtime = 0
fpdirection = {}

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

	char.weapon:update()
	
	--are we in a forced march?
	if(char['forcedMarch']) then
		if(char['nextForcedMove'] < currtime) then
			--print("you gettin moved boiii from " .. char.y .. " to " .. char.fy)
			local newPosX, newPosY = char.x, char.y
		
			if(char['fx'] < char["x"]) then newPosX = char["x"] - 1
			elseif(char['fx'] > char["x"]) then newPosX = char["x"] + 1 end
			
			if(char['fy'] < char["y"]) then newPosY = char["y"] - 1
			elseif(char['fy'] > char["y"]) then newPosY = char["y"] + 1 end
			
			
			if(map[newPosX]) then
				tile = map[newPosX][newPosY]
				--check if we've hit a wall.
				if(tile.blocker) then
					printSide("You slam into a wall!")
					char['forcedMarch'] = false
				elseif(newPosX == char.fx and newPosY == char.fy) then
					--check if we've hit the target
					char['forcedMarch'] = false
					char["x"], char["y"] = newPosX, newPosY
				else --guess we're good to move the character here!
					char["x"], char["y"] = newPosX, newPosY
				end
				
				char.nextForcedMove = currtime + 0.05
			
			else
				char['forcedMarch'] = false
			end
		end
	end
	
	--wait for directional input here
	if(explosion["falcon"]) then --or a number of other flags
		if(rightpress < REAL_BIG_NUMBER) then
			fpdirection.x, fpdirection.y = 1, 0
			falconPAWNCH(fpdirection)
		elseif(leftpress < REAL_BIG_NUMBER) then
			fpdirection.x, fpdirection.y = -1, 0
			falconPAWNCH(fpdirection)
		elseif(uppress < REAL_BIG_NUMBER) then
			fpdirection.x, fpdirection.y = 0, -1
			falconPAWNCH(fpdirection)
		elseif(downpress < REAL_BIG_NUMBER) then
			fpdirection.x, fpdirection.y = 0, 1
			falconPAWNCH(fpdirection)
		end
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
			char.weapon:shoot(string.sub(key,3))
			doTurn()
		end
		
		--press E for Explosion
		if(key == "e") then
			makeExplosion(char["x"], char["y"], 5, false)
			char:forceMarch(char["x"], char["y"] + 5)
		end
		
		--press P for some PAWWWNCH
		if(key == "p") then
			if(fpcooldown == 0) then
				suspended = true
				--this flag indicates we're gonna wait for the user to input a direction
				explosion["falcon"] = true
				
				printSide("FALCOOOOON...\n(choose a direction)")
			end
		end
	else	
		--supension also is kicked in when the user has to choose a direction/location for something.
		--pass the directional keys to any function that might want 'em.
		if(key == "right") then rightpress = currtime
		elseif(key == "left") then leftpress = currtime
		elseif(key == "up") then uppress = currtime
		elseif(key == "down") then downpress = currtime
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
	
	tile = map[x][y]	
	local enemy_in_space = nil
	for i=1,#enemies do
		if(enemies[i].x == x and enemies[i].y == y) then
			enemy_in_space = enemies[i]
			break
		end
	end
	
	if tile.blocker then
	elseif(enemy_in_space) then -- checks for monsters, etc. go here
	else
		-- empty square! we cool.
		if(map[x][y]["tile"] == 8 and map[char["x"]][char["y"]]["tile"] == 5) then -- If this is the boss room lever
			printSide("The door thunders closed.")
			map[char["x"]][char["y"]]["tile"] = 2
		end
		
		-- In case we're entering a new room soon
		viewed_rooms[map[x-1][y]["room"]] = true
		viewed_rooms[map[x][y-1]["room"]] = true
		
		char["x"], char["y"] = x, y
		k, v = next(map[char["x"]][char["y"]].room, nil)
		char["room"] = k
		viewed_rooms[k] = true
		
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
		
		-- Look for objects in your spot
		for i=1,#objects do
			if(objects[i].x == x and objects[i].y == y) then
				objects[i]:interact()
				if not objects[i].alive then
					table.remove(objects, i)
					i = i - 1
				end
			end
		end
	end
	tile:doAction()
	doTurn()
end

--spawns an enemy @ x, y
function spawnEnemy(x, y, which_enemy)
	k, v = next(map[x][y].room, nil)
	table.insert(enemies, which_enemy:new{x=x, y=y, room=k})
end
--end spawnEnemy

--spawns an object @ x, y
function spawnObject(x, y, which_object)
	k, v = next(map[x][y].room, nil)
	table.insert(objects, which_object:new{x=x, y=y, room=k})
end
--end spawnEnemy

--called whenever player shoots/moves/pulls lever/whatever.
--all enemies get to move, bombs go off, fires spread, whatever.
function doTurn()
	--decrement all cooldowns by one
	if(fpcooldown > 0) then
		fpcooldown = fpcooldown - 1
		print("fpcooldown: " .. fpcooldown)
	end

	for i = 1, # enemies do
		if enemies[i] then
			if not enemies[i].alive then
				table.remove(enemies, i)
			else
				enemies[i]:takeTurn()
			end
		end
	end
end
--end doTurn()

--controls enemy movement/attack patterns.
function enemyTurn(id)
	for i=1,#enemies do
		enemies[i]:takeTurn()
	end
end
--end enemyTurn()

--spawns an explosion at the specified x and y.
--if "Friendly Fire" is set to TRUE, it CAN hurt the player.
function makeExplosion(x, y, size, friendlyFire)
	-- Hit environment
	for i=math.ceil(x-size/2),math.ceil(x+size/2) do
	for j=math.ceil(y-size/2),math.ceil(y+size/2) do
		if(map[i] and map[i][j]) then
			map[i][j]:greatForce()
		end
	end
	end
	
	--initialize dat screenshake
	screenshake = size * 5
	
	-- Hit enemies
	for i = 1, # enemies do
		if not enemies[i].alive then
			table.remove(enemies, i)
		end
	end
	
	-- Hit self
	if(char.x > x-size/2 and char.x < x+size/2 and friendlyFire) then
		if(char.y > y-size/2 and char.y < y+size/2) then
			char:hitByExplosion()
			
			local newX, newY = char.x, char.y
			
			--figure out where to push you
			if(char.x > x) then
				newX = char.x + 5
			elseif(char.x < x) then
				newX = char.x - 5
			end
			
			if(char.y > y) then
				newY = char.y + 5
			elseif(char.y < y) then
				newY = char.y - 5
			end
			
			char:forceMarch(newX, newY)
		end
	end

	--1 second long explosions
	endsplosion = currtime + 0.6
	nextiteration = currtime

	explosion["x"] = x
	explosion["y"] = y
	explosion["size"] = size
	explosion["friendlyFire"] = friendlyFire
	
	suspended = true --suspend user until explosion is over
	exploding = true -- duh

	starttime = love.timer.getMicroTime()
	--while(love.timer.getMicroTime() - starttime < 0.5) do --1 second long splosion
	print("endsplosion: " .. endsplosion .. " and currtime " .. currtime)

end

--if enough time has passed, make the explosion different-looking
function iterateExplosion()
	--see if we're actually secretly done
	--[[if(endsplosion < currtime) then
		print("done exploding!")
		exploding = false
		suspended = false
	end]]--

	--draw a bunch of yellow/red/orange rectangles, centered at x, y
	--goes all the way to radius specified by "size"

	--is all randomized and shit.
	if(nextiteration < currtime) then
	
		--gimme dat screen shakery
		if(screenshake > 0) then
			screenshake = -(screenshake-2)
		elseif(screenshake < 0) then
			screenshake = -(screenshake+2)
		end
	
		explosion["size"] = sizes1[sizeindex]
		local dispersalness = dispersion1[sizeindex]
	
		for radius = 0, explosion["size"] do
			for i = 0, explosion["size"] * 2 do
				
				--make the color reddish orangish yellowish
				
				r = math.random(150,255)
				
				g = math.random(1,120)
				
				b = 27
				
				--consider dispersion
				local rand = math.random(0,101)
				if(rand < dispersalness * 10) then r = -1 end
				
				--polar coordinates ftw
				angle = math.random() * math.pi * 2
				
				--hold up! if it's falcon-splosion mode make it vaguely directional.
				--restrict angle to be moderately behind the player.
				if(explosion["falcon"]) then
					--print("direction.x: " .. fpdirection.x .. " and direction.y: " .. fpdirection.y)
					--basically, "shorten" radius if it is directly in front of the player's pawnch.
					if(fpdirection.y == -1 and not (angle < 3 / 2 * math.pi + 0.2 and angle > 3 / 2 * math.pi - 0.2 )) then
						radius = 1.5
					end
					if(fpdirection.y == 1 and not (angle < 1 / 2 * math.pi + 0.2 and angle > 1 / 2 * math.pi - 0.2 )) then
						radius = 1.5
					end
					if(fpdirection.x == -1 and not (angle < math.pi + 0.2 and angle > math.pi - 0.2 )) then
						radius = 1.5
					end
					if(fpdirection.x == 1 and not (angle < 0.2 or angle > 2 * math.pi - 0.2 )) then
						radius = 1.5
					end
				end
			
				exx = math.ceil(math.sin(angle) * radius)
				exy = math.ceil(math.cos(angle) * radius)
			
				--print(math.ceil(math.sin(angle) * radius + size/2) .. " and " .. math.ceil(math.cos(angle) * radius + size/2))
				explosionTiles[exx][exy] = r .. "+" .. g .. "+" .. b
			end
		end
	
		nextiteration = currtime + .02
		sizeindex = sizeindex + 1
		--print("splosion size index: " .. sizeindex .. " splosion size: " .. explosion["size"])
	end
	--currtime = love.timer.getMicroTime()
	
	--we reached the end of the size array! reset everything
	if(explosion["size"] == 0) then
		exploding = false
		suspended = false
		sizeindex = 1
		
		--wipe explosion tiles
		for i=-13, 13 do
			for j=-13, 13 do
				explosionTiles[i][j] = "-1+-1+-1"
			end
		end
		
		screenshake = 0
		
		--make sure falcon mode is deactivated
		explosion["falcon"] = false
	end
	
	
end

--wheredja get this?
--I STOOOLED IT
function string.explode(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
 --print(o[0] .. " and " .. o[1] .. " AND " .. o[2])
    return o
end
