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

gameState = 0

--keeps track of keys pressed during suspended-mode
susrightpress, susleftpress, susuppress, susdownpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER

function love.load()
	
	-- Set background color black, cause it's a console you stupid bitch
	love.graphics.setBackgroundColor( 0, 0, 0 )
	
	-- Load character/NPC/enemy/active objects (x is the random unassigned stuff)
	mainFont = love.graphics.newImageFont ("arial12x12test.png", " !\"#$%&'()*+,-./0123456789:;<=>?@[\\]^_'{|}~"
											.. "xxxxxxxxxxxxxxxxxxxxx"
											.. "xxxxxxxxxxxxOxxxxxxxxxxxx"
											.. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
											.. "abcdefghijklmnopqrstuvwxyz")
	-- Load floor tiles (for theming and shit)
	floorFont = love.graphics.newImageFont ("floorTiles.png", "123456789")

	level = 1
end

function initGame()
	sidebarlog = {{message="You wake up.", color={r=100,g=255,b=255}}}
	displayBig = true
	-- Character location set in map function
	
	level = 1
	initLevel()
	
	explosionTiles = {}
    for i=-13,13 do
		explosionTiles[i] = {}     -- initialize multidimensional array
		for j=-13,13 do
			explosionTiles[i][j] = "-1+-1+-1"
		end
    end
end
	
-- Initialize functions that are used for creating the info bar
dofile("sidebar.lua")

-- Initialize everything Tile
dofile("tiles.lua")

-- Initialize everything that has to do with weaponry
dofile("weapons.lua")

-- Initialize main character and shit
-- Side note: right now, with sizing and everything, it's looking like strength
-- and such values will max at 180
dofile("character.lua")

-- Initialize everything Enemy
dofile("enemies.lua")

-- Initialize everything that has to do with objects
dofile("objects.lua")

function initLevel()
	if level == 1 then -- Beginner level. we need specific rooms
		leveltype = "rooms"
		MAPWIDTH = 24
		MAPHEIGHT = 24
		ROOMNUM = 1
		viewed_rooms = {}
		possibleEnemies = {{{enemy=Rat, num=3}}}
		possiblePassives = {Pistol}
		possibleActives = {FZeroSuit, CloakAndDagger}
		Boss = GiantRat
		makeMap(leveltype)
	elseif level == 2 then
		leveltype = "rooms"
		MAPWIDTH = 48
		MAPHEIGHT = 48
		ROOMNUM = 1
		possiblePassives = {Pistol}
		possibleActives = {FZeroSuit}
		possibleEnemies = {{{enemy=Zombie, num=1}}, {{enemy=GiantRat, num=2}}}
		Boss = Skeleton
		viewed_rooms = {}
		makeMap(leveltype)
	elseif level == 3 then
		leveltype = "sewers"
		MAPWIDTH = 100
		MAPHEIGHT = 100
		ROOMNUM = 1
		viewed_rooms = {}
		possiblePassives = {Pistol}
		possibleActives = {FZeroSuit}
		possibleEnemies = {{{enemy=Zombie, num=1}}, {{enemy=GiantRat, num=2}}}
		Boss = Skeleton
		makeMap(leveltype)
	end
	print("get on my level: " .. level)
	
	--if we're in the sewers then the character is already set
	if(leveltype ~= "sewers") then
		-- Set character location
		char["x"] = MAPWIDTH/4 + math.random(MAPWIDTH/2)
		char["y"] = MAPHEIGHT/4 + math.random(MAPHEIGHT/2)
	end

	-- Set screen offset (for scrolling)
	offset = {x=char["x"]-20, y=char["y"]-30}
	while(map[char["x"]][char["y"]].blocker) do
		char["x"] = char["x"] + 1
		char["y"] = char["y"] + 1
	end
	char.prev_x = char.x
	char.prev_y = char.y
	
	-- Put character in the room
	k, v = next(map[char["x"]][char["y"]].room, nil)
	char["room"] = k
	viewed_rooms[k] = true
end

function makeMap(levelType)
	map = {}
	filledRooms = {}
	print(#filledRooms)
	for i = 1, MAPWIDTH do
		row = {}
		for j = 1, MAPHEIGHT do
			if(i == 1 or j == 1 or j == MAPHEIGHT or i == MAPWIDTH) then
				row[j] = Wall:new{room={[ROOMNUM]=true}}
			else
				row[j] = Floor:new{room={[ROOMNUM]=true}}
			end
		end
		map[i] = row
	end
	
	if(levelType == "rooms") then
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
				next_i = i+8+math.random(8)				-- Boundary check
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
		CORRIDORWIDTH = 24 + math.random(8)
		
		orient = math.random(4)
		if(orient == 2 or orient == 4) then orient = orient -1 end
		if(orient == 1 or orient == 3) then
			start_i = MAPWIDTH * (orient - 1) / 2 + (3 - orient) / 2
			end_i = start_i + CORRIDORWIDTH * (orient - 2)
			start_j = MAPHEIGHT/2
			while(map[start_i-(orient-2)][start_j].blocker) do -- In case we put corridor against a wall
				start_j = start_j + 1
			end
			k, v = next(map[start_i-(orient-2)][start_j].room, nil)
			map[start_i][start_j] = CrackedWall:new{room={[998]=true, [k]=true}}
			table.insert(map[start_i][start_j-1].room, {[998]=true})
			table.insert(map[start_i][start_j+1].room, {[998]=true})
			-- JUST FOR FIRST LEVEL: SPAWN BARREL THAT MUST EXPLODE TO GET TO BOSS
			if level == 1 then
				spawnEnemy(start_i-(orient-2), start_j, Barrel)
			end
			
			for i = start_i+(orient-2),end_i,(orient-2) do
				map[i] = {}
				map[i][start_j - 1] = Wall:new{room={[998]=true}}
				map[i][start_j] = Floor:new{room={[998]=true}}
				map[i][start_j + 1] = Wall:new{room={[998]=true}}
			end
			thunderingDoor = ThunderingDoor:new{room={[998]=true}}
			map[end_i][start_j] = thunderingDoor -- Make thundering door
			ROOMNUM = ROOMNUM + 1
			
			print("213")
			
			-- Make boss room!
			start_i = end_i + (orient - 2)
			end_i = start_i + 20 * (orient - 2)
			for i=start_i,end_i,(orient-2) do map[i] = {} end -- Make rows
			if(orient == 1) then
				makeRoom(end_i, start_j - 10, start_i, start_j + 10, 999)
			else
				makeRoom(start_i, start_j - 10, end_i, start_j + 10, 999)
			end
			map[start_i][start_j] = DoorSealer:new{room={[999]=true}, door_to_seal={x=start_i-(orient-2), y=start_j}} -- Make thundering door lever
		end
	elseif(levelType == "sewers") then
	
		--[[for i = 1, MAPWIDTH do
			row = {}
			for j = 1, MAPHEIGHT do
				if(i == 1 or j == 1 or j == MAPHEIGHT or i == MAPWIDTH) then
					row[j] = Wall:new{room={[ROOMNUM]=true}}
				else
					row[j] = Pit:new{room={[ROOMNUM]=true}}
				end
			end
			map[i] = row
		end]]--
	
		--first off.  We got 8 "nodes," 2 for each of the walls around the bigass room.
		NUMNODES = 8
		
		nodes = {}
		for i = 1, NUMNODES + 1 do
			nodes[i] = {}
		end
		
		--establish position of the nodes
		local mapWthird = math.ceil(MAPWIDTH/3)
		local mapHthird = math.ceil(MAPHEIGHT/3)
		nodes[1]["x"], nodes[1]["y"] = mapWthird, 2
		nodes[2]["x"], nodes[2]["y"] = 2 * mapWthird, 2
		nodes[3]["x"], nodes[3]["y"] = MAPWIDTH - 2, mapHthird
		nodes[4]["x"], nodes[4]["y"] = MAPWIDTH - 2, 2 * mapHthird   ---~~~~~~~~~~~~~~~~~~
		nodes[5]["x"], nodes[5]["y"] = 2 * mapWthird, mapHthird   ---~~~~~~~~~~~~~~~~~~~ lol it's a penis
		nodes[6]["x"], nodes[6]["y"] = mapWthird, MAPHEIGHT - 2
		nodes[7]["x"], nodes[7]["y"] = 2, 2 * mapHthird
		nodes[8]["x"], nodes[8]["y"] = 2, mapHthird
		
		for i = 1, NUMNODES do
			nodes[i]["friend"] = false
		end
		
		--match two of each of the "nodes" together
		--don't match adjacent nodes (no incest plz)
		--just kind of go around haphazardly matching nodes until all of them have a pair.
		done = false
		while(not done) do
			for i = 1, NUMNODES do
				done = true
				if(nodes[i].friend == false) then
					newFriend = ( math.random(1,6) + i ) % NUMNODES + 1 --math enough for ya??
					for j = 1, NUMNODES do
						--here, check 'em all to see if we're done.
						if(not nodes[j].friend) then
							done = false
						end
					end
					
					if done then break end
					
					for j = 1, NUMNODES do
						--here, make sure if "i" or "newFriend" had a pair that guy is TERMINATED
						if(nodes[j].friend == i) then nodes[j].friend = false end
						if(nodes[j].friend == newFriend) then nodes[j].friend = false end
					end
					
					--give 'em their newfriends :D
					nodes[newFriend].friend = i
					nodes[i].friend = newFriend
					
					--print("matched " .. newFriend .. " and " .. i)
				end
			end
			for j = 1, NUMNODES do
				--here, check 'em all to see if we're done.
				if(not nodes[j].friend) then
					done = false
				end
			end
		end
		
		for i = 1, NUMNODES do
			if(nodes[i].friend) then
				print("oh boy! " .. i .. " is friends with " .. nodes[i].friend .. "!!")
			else
				print("OH GOD " .. i .. " I AM SO ALONE")
			end
		end
			
		--create a "walker" for each of the matched nodes that will move towards each other, leaving
		--a trail of floor tiles.
		for i = 1, NUMNODES do
			if(nodes[nodes[i].friend].walker == nil) then
				nodes[i].walker = {} --spawn a walker at the current location, only if your friend doesn't already have one
				nodes[i].walker.x, nodes[i].walker.y = nodes[i].x, nodes[i].y
				nodes[i].walker.targetX, nodes[i].walker.targetY = nodes[nodes[i].friend].x, nodes[nodes[i].friend].y
			end
		end
		
		--walk da walkers until dey done walkin
		done = false
		while(not done) do
			done = true
			for i = 1, NUMNODES do
				currWalker = nodes[i].walker
				if(currWalker) then --ensures the walker exists
					--walker shits out a floorseed where it's at
					map[currWalker.x][currWalker.y].tile=7
					
					local deltaX = math.sign(currWalker.targetX - currWalker.x)
					local deltaY = math.sign(currWalker.targetY - currWalker.y)
					
					--halfhearted randomization
					randoCommando = math.random(0,100)
					if(randoCommando > 40) then
						currWalker.x = currWalker.x + deltaX
					end
					randoCommando = math.random(0,100)
					if(randoCommando > 40) then
						currWalker.y = currWalker.y + deltaY
					end
					
					if(currWalker.x ~= currWalker.targetX or currWalker.y ~= currWalker.targetY) then
						done = false
					end
				end
			end
		end
		
		--finally, for each floorseed, add tiles to the 3x3 area around it.
		for mx = 1, MAPWIDTH do
			for my = 1, MAPHEIGHT do
				if(map[mx][my].tile == 7) then
					--for dx = math.random(-4,-2), math.random(1,3) do
						--for dy = math.random(-4,-2), math.random(1,3) do
					for dx = -2, 2 do
						for dy = -2, 2 do
							if(map[mx + dx] and map[mx + dx][my + dy] and map[mx + dx][my + dy].tile ~= 2) then 
							--make sure tile exists and is not a wall
								map[mx + dx][my + dy] = Floor:new{room={[ROOMNUM]=true}}
							end
						end
					end
					
					map[mx][my].tile = 9
				end
			end
		end
		
		--plop the character down on a random node
		charNode = math.random(1,NUMNODES)
		char.x, char.y = nodes[charNode].x, nodes[charNode].y
	end
	map[start_i][start_j] = DoorSealer:new{room={[999]=true}, door_to_seal={x=start_i-(orient-2)*2, y=start_j}} -- Make thundering door lever
end

-- Automatically add doors to the room
function makeRoomAndDoors(start_i, start_j, end_i, end_j, roomnum)
	makeRoom(start_i, start_j, end_i, end_j, roomnum, true)
end

-- Fill a room with generic wall/floor
function makeRoom(start_i, start_j, end_i, end_j, roomnum, makeDoors)

	--each room gets 1 trap.
	local trapX, trapY = math.random(start_i + 1, end_i - 1), math.random(start_j + 1, end_j - 1)

	for i = start_i, end_i do
		if not map[i] then map[i] = {} end
		for j = start_j, end_j do
			if(i == start_i or j == start_j or j == end_j or i == end_i) then
				map[i][j] = Wall:new{room={[roomnum]=true}} -- Wall
			else
				map[i][j] = Floor:new{room={[roomnum]=true}} -- Floor
			end
			if(i == trapX and j == trapY) then
				--[[whichTrap = math.random(1,2)
				if(whichTrap == 1) then
					map[i][j] = SpikeTrap:new{room={[roomnum]=true}}
				elseif(whichTrap == 2) then
					cxdir = math.random(-6,6)
					cydir = math.random(-6,6)
					map[i][j] = CatapultTrap:new{room={[roomnum]=true}}
				end]]--
				map[i][j] = Pit:new{room={[roomnum]=true}}
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
	if(roomnum == 999) then -- Boss room
		spawnEnemy(end_i - 3, start_j + (end_j - start_j) / 2, Boss:new{boss=true})
	end
	-- Determine types
	roomType = math.random(3)
	while(filledRooms[roomType]) do
		roomType = roomType + 1
		if(roomType > 3) then roomType = 1 end
	end
	if(roomType ~= 3) then filledRooms[roomType] = true end

	if(roomType == 1) then
		o = possiblePassives[math.random(#possiblePassives)]
		spawnObject(start_i + 2 + math.random(end_i-start_i-4), start_j + 2 + math.random(end_j-start_j-4), o)
	elseif(roomType == 2) then
		o = possibleActives[math.random(#possibleActives)]
		spawnObject(start_i + 2 + math.random(end_i-start_i-4), start_j + 2 + math.random(end_j-start_j-4), o)
	else
		e = possibleEnemies[math.random(#possibleEnemies)]
		for k, e_table in pairs(e) do
			for e_num=1,e_table.num do
				spawnEnemy(start_i + 2 + math.random(end_i-start_i-4), start_j + 2 + math.random(end_j-start_j-4), e_table.enemy:new())
			end
		end
	end
end

--put a trap in the specified locale
function makeTrap(i, j)
	whichTrap = math.random(1,2)
	if(whichTrap == 1) then
		map[i][j] = SpikeTrap:new{room={[roomnum]=true}}
	elseif(whichTrap == 2) then
		map[i][j] = CatapultTrap:new{room={[roomnum]=true}}
	end
end

-- Amount of tiles to display (proportional to display size / 12)
DISPLAYWIDTH = 40
DISPLAYHEIGHT = 50

--how much offset to have for the screenshake
screenshake = 0

function love.draw()
	if(gameState == 0) then
		drawWelcome()
	elseif(gameState == 1) then
		drawGame()
	elseif(gameState == 2) then
		drawYouSuck()
	end
end

function drawWelcome()
	love.graphics.setFont(mainFont)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Welcome to AwesomeRogue.\n\nPress enter to be awesome", 100, 250)
end

function drawYouSuck()
	love.graphics.setFont(mainFont)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("You suck", 200, 250)
end

function drawGame()
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
--this is for Falcon Punch** (TODO: organize diz betta)
fpdirection = {}

function love.update(dt)
	if(gameState == 0) then
		updateWelcome()
	elseif(gameState == 1) then
		updateGame()
	end
end

function updateWelcome()
end

function updateGame()
	
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
			
			--move character
			if(map[newPosX]) then
				tile = map[newPosX][newPosY]
				--check if we've hit a wall.
				
				--check if we hit a trap during our flight pattern
				tile:checkTrap("you")
				
				if(tile.blocker) then
					printSide("You slam into a wall!")
					char['forcedMarch'] = false
				elseif(newPosX == char.fx and newPosY == char.fy) then
					--check if we've hit the target
					char['forcedMarch'] = false
					--being the last one, do a regular check'n'move
					checkThenMove(newPosX, newPosY)
				else --guess we're good to move the character here!
					char["x"], char["y"] = newPosX, newPosY
				end
				
				char.nextForcedMove = currtime + 0.05
			
			else
				char['forcedMarch'] = false
			end
		end
		
		
	end
	
	--hey, while we're here, let's move enemies that need to be moved.
	for i=1,#enemies do
		enemies[i]:update()
		if(enemies[i].forcedMarch) then
			newEnemyX, newEnemyY = enemies[i].x, enemies[i].y
		
			if(enemies[i].targetX < enemies[i].x) then newEnemyX = enemies[i].x - 1
			elseif(enemies[i].targetX > enemies[i].x) then newEnemyX = enemies[i].x + 1 end
			
			if(enemies[i].targetY < enemies[i].y) then newEnemyY = enemies[i].y - 1
			elseif(enemies[i].targetY > enemies[i].y) then newEnemyY = enemies[i].y + 1 end
			
			if(map[newEnemyX] and enemies[i].alive) then
				tile = map[newEnemyX][newEnemyY]
				
				--check if there are traps that should go off (this is awesome btw)
				tile:checkTrap(enemies[i])
				
				--check if the enemy hit a wall
				if(tile.blocker) then
					printSide("The " .. string.lower(enemies[i].name) .. " slams into a wall!")
					enemies[i].forcedMarch = false
				--check if the enemy ended up where it's supposed to get to
				elseif(enemies[i].targetX == newEnemyX and enemies[i].targetY == newEnemyY) then
					enemies[i]:checkAndMove(newEnemyX, newEnemyY)
				else --guess it's safe to move the enemy to a place
					enemies[i].x, enemies[i].y = newEnemyX, newEnemyY
				end
			end
		end
	end
	
	--wait for directional input here
	if(explosion["falcon"]) then --or a number of other flags
		if(susrightpress < REAL_BIG_NUMBER) then
			char:falconPunch(1,0)
		elseif(susleftpress < REAL_BIG_NUMBER) then
			char:falconPunch(-1,0)
		elseif(susuppress < REAL_BIG_NUMBER) then
			char:falconPunch(0,-1)
		elseif(susdownpress < REAL_BIG_NUMBER) then
			char:falconPunch(0,1)
		end
		
		susrightpress, susleftpress, susuppress, susdownpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
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
	if(gameState == 0 or gameState == 2) then
		keyPressWelcome(key, unicode)
	elseif(gameState == 1) then
		keyPressGame(key, unicode)
	end
end
	
function keyPressWelcome(key, unicode)
	if(key == "return") then
		gameState = 1
		initGame()
	end
	--print("You pressed " .. key .. ", unicode: " .. unicode)
end
	
function keyPressGame(key, unicode)
	--print("You pressed " .. key .. ", unicode: " .. unicode)
	--don't let the user make input if we're showing an animation or something
	if(not suspended) then
		displayBig = false
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
		
		--press "Z" for first active item
		if(char.activeNum >= 1) then
			if(key == "z" and char.actives[1].cooldown == 0) then
				if(char.actives[1].cooldown == 0) then 
					--do whatever active this is
					print(char.actives[1].name)
					char:doActive(char.actives[1].name)
					char.actives[1].cooldown = char.actives[1].maxcooldown
				else
					printSide("That skill is on cooldown!")
				end
			end
		end
		
		--press "X" for the second active item
		if(char.activeNum >= 2) then
			if(key == "x" and char.actives[2].cooldown == 0) then
				print(char.actives[2].name)
				char:doActive(char.actives[2].name)
			end
		end
		
		--press "C" for the third active item
		if(char.activeNum >= 3) then
			if(key == "c" and char.actives[3].cooldown == 0) then
				print(char.actives[3].name)
				char:doActive(char.actives[3].name)
			end
		end
		
		--press P for some PAWWWNCH (debug: you can now paunch whenever you want with P)
		if(key == "p") then
			suspended = true
			--this flag indicates we're gonna wait for the user to input a direction
			explosion["falcon"] = true
			
			printSide("FALCOOOOON... (choose a direction)")
		end
	else	
		--supension also is kicked in when the user has to choose a direction/location for something.
		--pass the directional keys to any function that might want 'em.
		if(key == "right") then susrightpress = currtime
		elseif(key == "left") then susleftpress = currtime
		elseif(key == "up") then susuppress = currtime
		elseif(key == "down") then susdownpress = currtime
		end
	end
	
	if(key=="q") then
		gameState = "MAPDEBUG lol"
	end
	
	--if the user hit "enter" and he or she is in a pit we should let him (or her) out
	if(char.inAPit and key == "return") then
		searchDistance = 1
		escaped = false
		while(not escaped) do 
			px, py = 0, 0
			--run a search using increasingly large squares.
			for px = -searchDistance, searchDistance do
				for py = -searchDistance, searchDistance do
					--print("Are YOU the problem? px = " .. px .. " py = " .. py .. " searchD is " .. searchDistance)
					myTile = checkTile(px + char.x, py + char.y)
					if(myTile.tile == 3) then
						--we did it!
						escaped = true
						checkThenMove(px + char.x, py + char.y)
						printSide("You crawl out of the pit.")
						
						--escape from the forloop!
						char.inAPit = false
						suspended = false
						susrightpress, susleftpress, susuppress, susdownpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
						return
					end
					--didn't find a valid square to move to.  Increment search distance.
				end
			end
			searchDistance = searchDistance + 1
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
	print(suspended)
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
		-- In case we're entering a new room soon
		viewed_rooms[map[x-1][y]["room"]] = true
		viewed_rooms[map[x][y-1]["room"]] = true
		
		char["prev_x"], char["prev_y"] = char["x"], char["y"]
		char["x"], char["y"] = x, y
		char.dirx=0
		char.diry=0
		if (char.x-char.prev_x) > 0 then
			char.dirx = 1
		else
			char.dirx = -1
		end
		if (char.y-char.prev_y) > 0 then
			char.diry = 1
		else
			char.diry = -1
		end
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
		for i=#objects,1,-1 do
			--print(objects[i].y .."=" .. y .. "? " .. objects[i].x .. "=" .. x .. "?")
			if(objects[i].x == x and objects[i].y == y) then
				objects[i]:interact()
				if not objects[i].alive then
					table.remove(objects, i)
				end
			end
		end
	end
	tile:doAction()
	tile:checkTrap("you")
	doTurn()
end

--handy function to grab a tile from x, y on map.
--does the null-check for you.
function checkTile(x, y)
	if(map[x] == nil or map[x][y]	== nil) then 
		--print("oh crap, tried to access a null tile!")
		return "null" --** run a check to see if tile=="null" to avoid exceptions.
	end
	
	tile = map[x][y]
	
	return tile
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
	for i = 1, char.activeNum do
		if(char.actives[i].cooldown > 0) then
			char.actives[i].cooldown = char.actives[i].cooldown - 1
		end
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
		if enemies[i] and enemies[i].alive then
			if(enemies[i].x > x-size/2 and enemies[i].x < x+size/2) then
				if(enemies[i].y > y-size/2 and enemies[i].y < y+size/2) then
					enemies[i]:hitByExplosion()
					
					local newX, newY = enemies[i].x, enemies[i].y
			
					--figure out where to push you
					if(enemies[i].x > x) then
						newX = enemies[i].x + 5
					elseif(enemies[i].x < x) then
						newX = enemies[i].x - 5
					end
					
					if(enemies[i].y > y) then
						newY = enemies[i].y + 5
					elseif(enemies[i].y < y) then
						newY = enemies[i].y - 5
					end
					
					enemies[i]:forceMarch(newX, newY)
					
				end
			end
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
					--print("direction.x: " .. char.active.direction.x .. " and direction.y: " .. char.active.direction.y)
					--basically, "shorten" radius if it is directly in front of the player's pawnch.
					if(explosion.direction.y == -1 and not (angle < 3 / 2 * math.pi + 0.2 and angle > 3 / 2 * math.pi - 0.2 )) then
						radius = 1.5
					end
					if(explosion.direction.y == 1 and not (angle < 1 / 2 * math.pi + 0.2 and angle > 1 / 2 * math.pi - 0.2 )) then
						radius = 1.5
					end
					if(explosion.direction.x == -1 and not (angle < math.pi + 0.2 and angle > math.pi - 0.2 )) then
						radius = 1.5
					end
					if(explosion.direction.x == 1 and not (angle < 0.2 or angle > 2 * math.pi - 0.2 )) then
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

--put this in util.lua eventually I guess

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
    return o
end

function math.sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end
