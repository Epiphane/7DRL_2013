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

sizes1 = {1,3,5,5,5,3,3,2,1,0}

--is explosion happening?
exploding = false
explosionTiles = {}
explosion = {x=5, y=5, size=5, friendlyFire = false}

tile_info = {{blocker=false}, 
			{blocker=true, message="You walk into a wall...", awesome_effect=-2}, 
			{blocker=false}, 
			{blocker=true, walk_trans=5, message="You open the door.", awesome_effect=1}, -- Door turns into an opened door
			{blocker=false},
			{blocker=true},
			{blocker=true, walk_trans=5, message="The door thunders open.", awesome_effect=5},
			{blocker=false}}

function love.load()
	-- Initialize functions that are used for creating the info bar
	dofile("sidebar.lua")
	
	-- Initialize everything Tile
	dofile("tiles.lua")
	
	-- Set background color black, cause it's a console you stupid bitch
	love.graphics.setBackgroundColor( 0, 0, 0 )
	
	-- Load character/NPC/enemy/active objects (x is the random unassigned stuff)
	mainFont = love.graphics.newImageFont ("arial12x12.png", " !\"#$%&'()*+,-./0123456789:;<=>?@[\\]^_'{|}~"
											.. "xxxxxxxxxxxxxxxxxxxxx"
											.. "xxxxxxxxxxxxxxxxxxxxxxxxx"
											.. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
											.. "abcdefghijklmnopqrstuvwxyz")
	-- Load floor tiles (for theming and shit)
	floorFont = love.graphics.newImageFont ("floorTiles.png", "12345678")
	
	-- Initialize main character and shit
	-- Side note: right now, with sizing and everything, it's looking like strength
	-- and such values will max at 180
	char = {awesome=100}
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
	spawnEnemy(10,20,"zombie")
	spawnEnemy(12,12,"robot")
	
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
				row[j] = Wall:new{room=ROOMNUM}
			else
				row[j] = Floor:new{room=ROOMNUM}
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
	while(tile_info[map[start_i-1][start_j]["tile"]]["blocker"]) do -- In case we put corridor against a wall
		start_j = start_j - 1
	end
	map[start_i][start_j]["tile"] = 6
	-- JUST FOR FIRST LEVEL: SPAWN BARREL THAT MUST EXPLODE TO GET TO BOSS
	spawnEnemy(start_i-1, start_j, "barrel")
	for i = start_i+1,end_i do
		map[i] = {}
		map[i][start_j - 1] = Wall:new{room=998}
		map[i][start_j] = Floor:new{room=998}
		map[i][start_j + 1] = Wall:new{room=998}
	end
	thunderingDoor = ThunderingDoor:new{room=998}
	map[end_i][start_j] = thunderingDoor -- Make thundering door
	ROOMNUM = ROOMNUM + 1
	
	-- Make boss room!
	start_i = end_i + 1
	end_i = start_i + 20
	for i=start_i,end_i do map[i] = {} end -- Make rows
	makeRoom(start_i, start_j - 10, end_i, start_j + 10, 999)
	map[start_i][start_j] = DoorSealer:new{room=999, door_to_seal=thunderingDoor} -- Make thundering door lever
	
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
				map[i][j] = Wall:new{room=romnum} -- Wall
			else
				map[i][j] = Floor:new{room=romnum} -- Floor
			end
		end
	end
	
	if makeDoors then
		if(start_i ~= 1) then -- Put a doorway!
			map[start_i][start_j+2 + math.random(end_j-start_j-4)] = Door:new{room=roomnum} -- Floor
		end
		
		if(start_j ~= 1) then -- Put top doorways!
			walk_start_i = start_i -- "Walk" along the top wall and find good doorway walls
			for walk_end_i = walk_start_i + 1,end_i do
				if(map[walk_end_i][start_j-1].blocker
					or map[walk_end_i][start_j+1].blocker) then
					diff = walk_end_i - walk_start_i
					if(diff > 3) then
						map[walk_start_i+2+math.random(diff-3)][start_j] = Door:new{room=roomnum}
					end
					walk_start_i = walk_end_i + 1
					walk_end_i = walk_start_i + 1
				end
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
				map[i+offset["x"]][j+offset["y"]]:setColor(char["room"], 0)
				--for x_o=-1,0 do	-- This is for walls: if the top-left is in your room,
				--for y_o=-1,0 do -- Light this up for aesthetics
					--if(map[i+offset["x"]+x_o] and map[i+offset["x"]+x_o][j+offset["y"]+y_o]) then
						--roomnum = map[i+offset["x"]+x_o][j+offset["y"]+y_o]["room"]
						--if roomnum == char["room"] then
							--love.graphics.setColor( 255, 255, 255 ) -- LIGHT 'ER UP
						--elseif viewed_rooms[roomnum] then
						--	-- TODO: Smarter way to figure out if its 255, 255, 255
						--	r, g, b, a = love.graphics.getColor()
						--	if(r ~= 255) then
						--		if(char["room"] == 998) then -- Corridor: Tint darker the farther you get
						--			tint = (MAPWIDTH - char["x"])*255/CORRIDORWIDTH
						--			love.graphics.setColor( tint, tint, tint )
						--		else
						--			love.graphics.setColor( 100, 100, 100 )
						--		end
						--	end
						--end
					--end
				--end
				--end
				love.graphics.print(map[i+offset["x"]][j+offset["y"]].tile, (i-1)*12, (j-1)*12)
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
		
		if(which == "barrel") then
			love.graphics.print("B", (ex - offset["x"]) * 12, (ey - offset["y"])*12)
		end
	end
	
	--drawsplosion if we're sploding
	if(exploding) then
		iterateExplosion()
	
		love.graphics.setColor(255,255,0)
		love.graphics.rectangle("fill",0,0,24,24)
		for explosionX = 0, explosion["size"] * 2 do
			for explosionY = 0, explosion["size"] * 2 do
				
				rindex = string.find(explosionTiles[explosionX][explosionY], "+")
				
				--pull out the r, g, and b index values
				r = tonumber(string.sub(explosionTiles[explosionX][explosionY], 0, rindex - 1))
				
				gindex = string.find(explosionTiles[explosionX][explosionY], "+", rindex + 1) 
				
				g = tonumber(string.sub(explosionTiles[explosionX][explosionY], 
					rindex + 1, gindex - 1))
				
				bindex = string.find(explosionTiles[explosionX][explosionY], "+", gindex) 
				
				b = tonumber(string.sub(explosionTiles[explosionX][explosionY], 
					bindex + 1))
				
				if(r ~= -1) then
					love.graphics.setColor(r, g, b)
					love.graphics.rectangle( "fill", (explosion["x"] + explosionX - offset["x"] - 5) * 12, 
						(explosion["y"] + explosionY - offset["y"] - 5) * 12, 12, 12)
					print("well I'm just tryinta draw this shit")
				end
			end
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
		
		--press E for Explosion
		if(key == "e") then
			makeExplosion(char["x"], char["y"], 5, false)
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
	-- Random stuff that sends a message
	tile:doAction()
	
	if tile.blocker then
	elseif(false) then -- checks for monsters, etc. go here
	
	else-- empty square! we cool.
		if(map[x][y]["tile"] == 8 and map[char["x"]][char["y"]]["tile"] == 5) then -- If this is the boss room lever
			printSide("The door thunders closed.")
			map[char["x"]][char["y"]]["tile"] = 2
		end
		
		-- In case we're entering a new room soon
		viewed_rooms[map[x-1][y]["room"]] = true
		viewed_rooms[map[x][y-1]["room"]] = true
		
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
	enemies[enemystring .. "hp"] = y
	
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
	--if an enemy can't see the player it just wanders around randomly.
	--weight it so that the enemy moves vaguely forward.
	rand = math.random(101)
	
	if(rand < 70) then --don't move at all
	
	elseif(rand < 80) then -- move forward
		
	elseif(rand < 86) then -- forward-right
	
	elseif(rand < 92) then -- foward-left
	
	elseif(rand < 95) then -- left
	
	elseif(rand < 98) then -- right
	
	else --backwards
	
	end
	


end
--end enemyTurn()

--checks if an enemy can in fact move to a place, then does it
--if it can!
function moveEnemy(id, x, y)

end

--spawns an explosion at the specified x and y.
--if "Friendly Fire" is set to TRUE, it CAN hurt the player.
function makeExplosion(x, y, size, friendlyFire)

	--1 second long explosions
	endsplosion = currtime + 0.6
	nextiteration = currtime

	--print("hi " .. explosionTiles[-0][2])
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
	if(endsplosion < currtime) then
		print("done exploding!")
		exploding = false
		suspended = false
	end

	--draw a bunch of yellow/red/orange rectangles, centered at x, y
	--goes all the way to radius specified by "size"

	--is all randomized and shit.  Also decreases in size over lifespan.
	if(nextiteration < currtime) then
		print("this is happening now")
		for radius = 0, explosion["size"], 1 do 
			for angle = 0, 2 * math.pi, math.pi / 7 do 
				r,g,b = -1,-1,-1
				--First, choose a random color or choose to not have a splosion tile there at all
				rando = math.random(5)
				if(rando == 1) then
					--negative one indicates explosion-less square.
					r, g, b = -1, -1, -1
				elseif(rando == 2) then
					--a nice oaky orange
					r, g, b = 230, 193, 30
				elseif(rando == 3) then
					--a vibrant yellow
					r, g, b = 255, 255, 0
				elseif(rando == 4) then
					--a sultry, hot red
					r, g, b = 255, 55, 0
				end
			
				--dat polar coordinate system :D
				--print(math.ceil(math.sin(angle) * radius + size/2) .. " and " .. math.ceil(math.cos(angle) * radius + size/2))
				explosionTiles[math.ceil(math.sin(angle) * radius + explosion["size"]/2)][math.ceil(math.cos(angle) * radius + explosion["size"]/2)] = r .. "+" .. g .. "+" .. b
			end
		end
	
		nextiteration = currtime + .04
		end
	--currtime = love.timer.getMicroTime()
	
	--explosion["size"] = next(sizes1,explosion["size"])
end

--wheredja get this?
-- I STOOOLED IT
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
	print(o[0] .. " and " .. o[1] .. " AND " .. o[2])
    return o
end
