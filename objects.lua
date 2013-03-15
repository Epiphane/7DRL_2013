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
FZeroSuit = Object:new{name="F Zero Suit", icon=">", cooldown=10}

-- Suit constructor seals a door
function FZeroSuit:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function FZeroSuit:interact()
	char:addActive("Falcon Punch")
	printSide("You pick up the F-Zero Suit")
	self.alive = false
end
-- ******************** END FALCON PUNCH ***************************

-- ******************** BEGIN CLOAK AND DAGGER *********************
CloakAndDagger = Object:new{name="Cloak and Dagger", icon=")", cooldown=10}

function CloakAndDagger:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

function CloakAndDagger:interact()
	char:addActive("Cloak And Dagger")
	printSide("You pick up the Cloak and Dagger")
	self.alive = false
end


-- ******************** END CLOAK AND DAGGER   *********************

-- ******************** BEGIN SPEED BOOTS      *********************
--speed boots!
--wanted to call them "Cocaine" but I decided against it :/
--basically every 3 turns none of the enemies take a turn.
--GOTTA GO FEEEYAAST
-- ^^^^^^^^^^^^^^^^  (must be said out loud + obnoxiously)
SpeedBoots = Object:new{name="Speed Boots", icon="["}
function SpeedBoots:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function SpeedBoots:interact()
	char:addPassive("Speed Boots")
	printSide("You find some speed boots! GOTTA GO FAAAST")
	self.alive = false
end
-- ******************** END SPEED BOOTS		   *********************