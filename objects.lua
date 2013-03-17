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
	love.graphics.setColor( 200, 200, 0)
	if(self.room == char.room) then
		love.graphics.print(self.icon, (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12 + screenshake)
	elseif viewed_rooms[self.room] then
		love.graphics.print(self.icon, (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12 + screenshake)
	else
		love.graphics.print("?", (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12 + screenshake)
	end
	love.graphics.setColor( 255, 255, 255)
end
-- end draw()

-- ******************** BEGIN PISTOL ***************************
Pistol = Object:new{name="Pistol", icon="p"}

-- Pistol constructor seals a door
function Pistol:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function Pistol:interact()
	table.insert(char.weapon,bullet)
	printSide("You pick up the Pistol")
	self.alive = false
end
-- ******************** END PISTOL ***************************

-- ******************** BEGIN SHOTGUN ***************************
Shotgun = Object:new{name="Shotgun", icon="g"}

-- Pistol constructor seals a door
function Shotgun:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function Shotgun:interact()
	table.insert(char.weapon,shotgun)
	printSide("You pick up the Shotgun")
	self.alive = false
end
-- ******************** END SHOTGUN ***************************

-- ******************** BEGIN LIGHTSABER ***************************
Lightsaber = Object:new{name="Lightsaber", icon="!"}

-- Pistol constructor seals a door
function Lightsaber:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function Lightsaber:interact()
	table.insert(char.weapon,lightsaber)
	printSide("You pick up the Lightsaber")
	self.alive = false
end
-- ******************** END LIGHTSABER ***************************

-- ******************** BEGIN SWORD OF DEMACIA ***************************
SwordOfDemacia = Object:new{name="Sword of Demacia", icon="t"}

-- Pistol constructor seals a door
function SwordOfDemacia:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function SwordOfDemacia:interact()
	table.insert(char.weapon,swordOfDemacia)
	printSide("You pick up the Sword of Demacia")
	self.alive = false
end
-- ******************** END SWORD OF DEMACIA ***************************

-- *********************** GENERIC ACTIVE *************************
ActiveItem = Object:new{name="No Name", icon=" ", cooldown=10}

-- Suit constructor seals a door
function ActiveItem:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function ActiveItem:interact()
	char:addActive(self.name)
	printSide("You pick up the "..self.name)
	self.alive = false
end
-- *********************** END GENERIC ACTIVE *************************

-- ******************** BEGIN FALCON PUNCH ***************************
FZeroSuit = ActiveItem:new{name="F Zero Suit", icon=">", cooldown=10}
-- ******************** END FALCON PUNCH ***************************

-- ******************** BEGIN CLOAK AND DAGGER *********************
CloakAndDagger = ActiveItem:new{name="Cloak and Dagger", icon=")", cooldown=10}
-- ******************** END CLOAK AND DAGGER   *********************

-- ******************** BEGIN WHIP *********************
Whip = ActiveItem:new{name="Whip", icon="j", cooldown=10}
-- ******************** END WHIP   *********************

-- ******************** BEGIN SPARTAN BOOTS *********************
SpartanBoots = ActiveItem:new{name="Spartan Boots", icon="L", cooldown=10}
-- ******************** END SPARTAN BOOTS   *********************

-- ******************** BEGIN PULSEFIRE BOOTS *********************
PulsefireBoots = ActiveItem:new{name="Pulsefire Boots", icon="%", cooldown=10}
-- ******************** END PULSEFIRE BOOTS   *********************

SackOGrenades = ActiveItem:new{name="Sack O' Grenades", icon="B", cooldown=10}
BagOMines = ActiveItem:new{name="Bag O' Mines", icon="M", cooldown=10}

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