-- Constructor for the Tile Class
-- param: o is an object, or table of information.
Enemy = {name="Enemy", icon="E", room=1, x=1, y=1, health=1, alive=true}

function Enemy:new(o)
	o = o or {}				-- Set the tile's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o				-- Return Tile
end

-- draws the enemy if he's in the right room
function Enemy:draw()
	if(self.alive and self.room == char.room) then
		love.graphics.print(self.icon, (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12)
	end
end
-- end draw()

function Enemy:getHit()
	health = health-1
end

function Enemy:takeTurn()
end

function Enemy:die()
	self.alive = false
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

function Rat:getHit(dmg)
	self.health = self.health - dmg
	if self.health <= 0 then
		self:die()
	end
end

function Rat:takeTurn()
	diff = math.abs(char.x - self.x) + math.abs(char.y - self.y)
	if(diff == 1) then
		return
	end
	local tileList = {[self.x]={[self.y]={x=self.x, y=self.y, open=true, f=diff, g=0, parent=false}}} -- Initialize with current pos
	
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
		if(map[current_x-1] and map[current_x-1][current_y] and not map[current_x-1][current_y].blocker) then
			if(not tileList[current_x-1]) then tileList[current_x-1] = {} end
			diff = math.abs(char.x - (current_x - 1)) + math.abs(char.y - current_y)
			if(not tileList[current_x-1][current_y]) then
				tileList[current_x-1][current_y] = {x=current_x-1, y=current_y, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
			else
				if(tileList[current_x-1][current_y].g > current_min.g+1) then
					tileList[current_x-1][current_y] = {x=current_x-1, y=current_y, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
				end
			end
		end
		if(map[current_x+1] and map[current_x+1][current_y] and not map[current_x+1][current_y].blocker) then
			if(not tileList[current_x+1]) then tileList[current_x+1] = {} end
			diff = math.abs(char.x - (current_x + 1)) + math.abs(char.y - current_y)
			if(not tileList[current_x+1][current_y]) then
				tileList[current_x+1][current_y] = {x=current_x+1, y=current_y, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
			else
				if(tileList[current_x+1][current_y].g > current_min.g+1) then
					tileList[current_x+1][current_y] = {x=current_x+1, y=current_y, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
				end
			end
		end
		if(map[current_x] and map[current_x][current_y-1] and not map[current_x][current_y-1].blocker) then
			if(not tileList[current_x]) then tileList[current_x] = {} end
			diff = math.abs(char.x - (current_x)) + math.abs(char.y - (current_y-1))
			if(not tileList[current_x][current_y-1]) then
				tileList[current_x][current_y-1] = {x=current_x, y=current_y-1, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
			else
				if(tileList[current_x][current_y-1].g > current_min.g+1) then
					tileList[current_x][current_y-1] = {x=current_x, y=current_y-1, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
				end
			end
		end
		if(map[current_x] and map[current_x][current_y+1] and not map[current_x][current_y+1].blocker) then
			if(not tileList[current_x]) then tileList[current_x] = {} end
			diff = math.abs(char.x - (current_x)) + math.abs(char.y - (current_y-1))
			if(not tileList[current_x][current_y+1]) then
				tileList[current_x][current_y+1] = {x=current_x, y=current_y+1, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
			else
				if(tileList[current_x][current_y+1].g > current_min.g+1) then
					tileList[current_x][current_y+1] = {x=current_x, y=current_y+1, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
				end
			end
		end
	until (current_x == char.x and current_y == char.y)
	
	if current_min then
		-- Follow the tree back
		local current_tile = tileList[current_x][current_y]
		while(current_tile.parent.parent) do current_tile = current_tile.parent end
		self.x = current_tile.x
		self.y = current_tile.y
	
		k, v = next(map[self.x][self.y].room,nil)
		self.room = k
	end
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