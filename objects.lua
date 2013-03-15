Object = {name="Object", icon="-", room=1, x=1, y=1, alive=true}

-- Object constructor
function Object:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
-- end constructor

function Object:interact()
end

-- draws the enemy if he's in the right room
function Object:draw()
	if(self.room == char.room) then
		love.graphics.print(self.icon, (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12 + screenshake)
	elseif viewed_rooms[self.room] then
		love.graphics.print(self.icon, (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12 + screenshake)
	else
		love.graphics.print("?", (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12 + screenshake)
	end
end
-- end draw()

-- ******************** BEGIN PISTOL ***************************
Pistol = Object:new{name="Pistol", icon=";"}

-- Pistol constructor seals a door
function Pistol:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function Pistol:interact()
	char.weapon = bullet
	printSide("You pick up the Pistol")
	self.alive = false
end
-- ******************** END PISTOL ***************************

-- ******************** BEGIN FALCON PUNCH ***************************
FZeroSuit = Object:new{name="F Zero Suit", icon=">"}

-- Pistol constructor seals a door
function FZeroSuit:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function FZeroSuit:interact()
	char.active = FalconPunch
	printSide("You pick up the F-Zero Suit")
	self.alive = false
end
-- ******************** END FALCON PUNCH ***************************