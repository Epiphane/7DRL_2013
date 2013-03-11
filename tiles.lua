-- Constructor for the Tile Class
-- param: o is an object, or table of information.
Tile = {tile=1, room=1, blocker=false, awesome_effect=0}

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

function Tile:doAction()
	char['awesome'] = char['awesome'] + self.awesome_effect
	printSide(self.message)
end

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
function DoorSealer:seal()
	self.door_to_seal = Wall:new(self.door_to_seal.room)
end
-- end seal()

Wall = Tile:new{tile=2, blocker=true}
function Wall:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end