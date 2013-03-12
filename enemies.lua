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
	if(self.room == char.room) then
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
	health = health - dmg
	if health <= 0 then
		self:die()
	end
end

function Rat:takeTurn()
	
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