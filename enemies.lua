-- Constructor for the Tile Class
-- param: o is an object, or table of information.
Enemy = {name="Enemy", icon="E", room=1, x=1, y=1, health=1, forcedMarch = false, alive=true}

function Enemy:new(o)
	o = o or {}				-- Set the tile's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o				-- Return Tile
end

-- draws the enemy if he's in the right room
function Enemy:draw()
	if(self.alive and self.room == char.room) then
		love.graphics.print(self.icon, (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12 + screenshake)
	end
end
-- end draw()

function Enemy:getHit(dmg)
	self.health = self.health - dmg
	if self.health <= 0 then
		self:die()
	end
end

function Enemy:takeTurn()
end

function Enemy:die()
	self.alive = false
end

function Enemy:hitByExplosion()
	char:gainAwesome(7)
	self:getHit(15)
	if not self.alive then
		printSide("The " .. self.name .. " explodes in a shower of blood")
		self:die()
	end
end

function Enemy:moveTowardsCharacter()
	diff_char = math.abs(char.x - self.x) + math.abs(char.y - self.y)
	diff = math.abs(char.prev_x - self.x) + math.abs(char.prev_y - self.y)
	if(diff_char == 1) then
		return
	elseif(diff == 1) then
		self:checkAndMove(char.prev_x, char.prev_y)
		return 
	end
	tileList = {[self.x]={[self.y]={x=self.x, y=self.y, open=true, f=diff, g=0, parent=false}}} -- Initialize with current pos
	
	-- Start stepping around at lowest F cost!
	repeat
		current_min = nil
		current_x, current_y = 0, 0
		for x, row in pairs(tileList) do
			for y, tile in pairs(row) do
				if tile.open then
					if(not current_min or tile.f < current_min.f) then
						current_min = tile
						current_x = x
						current_y = y
					end
				end
			end
		end
		if not current_min then break end
		
		-- Change to closed list
		current_min.open = false
		
		-- Add up, down, left, right to open list
		if(char.dirx > 0 or char.diry > 0) then dir = 1 else dir = -1 end
		if(math.random(10) > 5) then
			addList(dir, 0)
			addList(dir*-1, 0)
			addList(0, dir)
			addList(0, dir*-1)
		else
			addList(0, dir)
			addList(0, dir*-1)
			addList(dir, 0)
			addList(dir*-1, 0)
		end
	until (current_x == char.prev_x and current_y == char.prev_y)
	
	if current_min then
		-- Follow the tree back
		local current_tile = tileList[current_x][current_y]
		while(current_tile.parent.parent) do current_tile = current_tile.parent end
		
		self:checkAndMove(current_tile.x, current_tile.y)
	end
end

function Enemy:checkAndMove(x, y)		
	local enemy_in_space = false
	if(char.x == x and char.y == y) then enemy_in_space = true end
	for i=1,#enemies do
		if(enemies[i].x == x and enemies[i].y == y) then
			enemy_in_space = enemies[i]
			break
		end
	end
	
	if not enemy_in_space then
		self.x = x
		self.y = y
	
		k, v = next(map[self.x][self.y].room,nil)
		self.room = k
	end
	
	if(map[x] == nil or map[x][y]	== nil) then --[[chill]]-- 
	else
		tile = map[x][y]
	end
	
	tile:checkTrap(self)
end

-- Adding stuff to open list
function addList(xo, yo)
	if(map[current_x+xo] and map[current_x+xo][current_y+yo] and not map[current_x+xo][current_y+yo].blocker) then
		if(not tileList[current_x+xo]) then tileList[current_x+xo] = {} end
		diff = math.abs(char.x - (current_x+xo)) + math.abs(char.y - (current_y+yo))
		if(not tileList[current_x+xo][current_y+yo]) then
			tileList[current_x+xo][current_y+yo] = {x=current_x+xo, y=current_y+yo, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
		else
			if(tileList[current_x+xo][current_y+yo].g > current_min.g+1) then
				tileList[current_x+xo][current_y+yo] = {x=current_x+xo, y=current_y+yo, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
			end
		end
	end
end

Barrel = Enemy:new{name="Barrel", icon="O", health=1}
function Barrel:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function Barrel:getHit(dmg)
	if dmg < 25 then return end
	if(self.icon == "O") then
		self.icon = "3"
		printSide("Gas gushes out of the side of the barrel! Sparks fly!")
	end
end

function Barrel:takeTurn()
	if self.icon == "3" then
		self.icon = "2"
	elseif self.icon == "2" then
		self.icon = "1"
	elseif self.icon == "1" then
		self.icon = "0"
	elseif self.icon == "0" then
		makeExplosion(self.x, self.y, 5, true)
		self:die()
	end
end

Rat = Enemy:new{name="Rat", icon="r", health=10}
function Rat:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function Rat:takeTurn()
	if(math.random(4) == 3) then return end
	diff_char = math.abs(char.x - self.x) + math.abs(char.y - self.y)
	if(diff_char == 1) then
		m = math.random(4)
		if(m == 1) then
			printSide("The Rat climbs up into your trowsers.")
		elseif(m == 2) then
			printSide("The Rat claws your face")
		elseif(m == 3) then
			printSide("The Rat rips a small hole in your shirt.")
		elseif(m == 4) then
			printSide("The Rat nibbles your toe.")
		end
		char:loseAwesome(5)
		return
	end
	self:moveTowardsCharacter()
end

GiantRat = Enemy:new{name="Giant Rat", icon="R", health=100}
function GiantRat:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function GiantRat:die()
	self.alive = false
	char:gainAwesome(15)
	map[self.x][self.y] = Staircase:new{room={[999]=true}}
end

function GiantRat:takeTurn()
	if(char.room ~= 999) then return end
	if(math.random(6) == 5) then return end
	diff_char = math.abs(char.x - self.x) + math.abs(char.y - self.y)
	if(diff_char == 1) then
		m = math.random(3)
		if(m == 1) then
			printSide("The Giant Rat lubricates you with its saliva.")
		elseif(m == 2) then
			printSide("The Giant Rat claws your face")
		elseif(m == 3) then
			printSide("The Giant Rat rips your clothes.")
		elseif(m == 4) then
			printSide("The Giant Rat bites your foot.")
		end
		char:loseAwesome(15)
		return
	end
	self:moveTowardsCharacter()
end

Zombie = Enemy:new{name="Zombie", icon="Z", health=100}
function Zombie:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function Zombie:getHit(dmg)
	health = health - dmg
	if health <= 0 then
		self:die()
	end
end

function Zombie:takeTurn()
	
end

function Enemy:setForceMarch(newX, newY)
	self.forcedMarch = true
	self.targetX = newX
	self.targetY = newY
end