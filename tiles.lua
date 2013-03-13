-- Constructor for the Tile Class
-- param: o is an object, or table of information.
Tile = {tile=1, room=1, blocker=false, awesome_effect=0}

-- Generic tile constructor. Doesn't do much
function Tile:new(o)
	o = o or {}				-- Set the tile's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o				-- Return Tile
end

-- setColor(char_room, currentTint) takes what room the character is in,
-- decides what color to make itself, and then returns that lighting.
-- Added currentTint for efficiency
function Tile:setColor(char_room)
	love.graphics.setColor( 0, 0, 0 )
	k, v = next(self.room, nil)
	while k do
		if(char_room == k) then
			love.graphics.setColor( 255, 255, 255 )
			return
		elseif(viewed_rooms[k]) then
			love.graphics.setColor( 100, 100, 100 )
		end
		k, v = next(self.room, k)
	end
end
-- end setColor()

-- Do an action whenever you walk on a space
function Tile:doAction()
	char:gainAwesome(self.awesome_effect)
	printSide(self.message)
end
-- end doAction()

--checktraps: both enemies AND the player do this.
function Tile:checkTrap(victim)
	--uhh just chill for now
end

-- greatForce() is called for big changing effects
-- such as explosions or kicking enemies
-- It doesn't do anything in most cases.
function Tile:greatForce()
end
-- end greatForce()

-- SUBCLASSES. THIS IS HOW INHERITANCE WORKS. IT'S WEIRD BUT GOOD
Floor = Tile:new{tile=3} -- In other words, it inherits everything. It is a Tile, but 3, not 1
function Floor:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

Door = Tile:new{tile=4, blocker=true}
function Door:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

-- doAction(): sets the door tile to open, and passibility to passible
function Door:doAction()
	Tile.doAction(self)
	if(self.tile ~= 5) then printSide("You open the door.") end
	self.tile = 5
	self.blocker = false
end

ThunderingDoor = Door:new{tile=7, blocker=true}
function ThunderingDoor:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

function ThunderingDoor:doAction()
	Tile.doAction(self)
	if(self.tile ~= 5) then
		char:gainAwesome(10)
		printSide("The door thunders open.")
	end
	self.tile = 5
	self.blocker = false
end

-- DoorSealer constructor seals a door
DoorSealer = Floor:new()
function DoorSealer:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

-- seal() closes the door, turning it into a wall
function DoorSealer:doAction()
	if(self.door_to_seal.x) then
		door_room = {}
		for k,v in pairs(map[self.door_to_seal.x][self.door_to_seal.y].room, nil) do door_room[k] = v end
		map[self.door_to_seal.x][self.door_to_seal.y] = Wall:new{room=door_room}
		self.door_to_seal.x = nil -- Can't seal again
		printSide("The door shudders closed behind you.")
	end
end
-- end seal()

Wall = Tile:new{tile=2, blocker=true, awesome_effect=-1, message="You walk headlong\n  into a wall..."}
function Wall:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

CrackedWall = Wall:new{tile=6, awesome_effect=0}
function CrackedWall:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

function CrackedWall:greatForce()
	Tile.doAction(self)
	if(self.tile ~= 8) then printSide("The wall splits open.") end
	self.tile = 8
	self.blocker = false
end

--**********BEGIN STAIRCASE***********************
Staircase = Tile:new{tile=7, blocker=false, awesome_effect=-10}
function Staircase:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

function Staircase:doAction()
	level = level + 1
	initLevel()
end
--************END STAIRCASE**************************

--**********BEGIN TRAPS***********************
SpikeTrap = Tile:new{tile=7, blocker=false, awesome_effect=-10}
function SpikeTrap:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

-- doAction(): hurts whoever walked over the trap.
function SpikeTrap:checkTrap(victim)
	Tile.doAction(self)
	
	if(victim == "you") then
		printSide("Spikes shoot out of the ground and stab you in the shins!")
	else
		printSide("Spikes shoot out of the ground and stab the " .. victim.name .. "!")
		victim:getHit(10)
	end
end
--************END TRAPS**************************