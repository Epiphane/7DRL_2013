-- Constructor for the Tile Class
-- param: o is an object, or table of information.
Tile = {tile=1, room={[1]=false}, blocker=false, awesome_effect=0}

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
	if(self.tile ~= 5) then 
		printSide("You open the door.")
		self.tile = 5
		self.blocker = false
		for i=1,#enemies do
			enemies[i].possiblePath = true
		end
	end
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
		map[self.door_to_seal.x][self.door_to_seal.y] = Wall:new{room={[door_room]=true}}
		self.door_to_seal.x = nil -- Can't seal again
		printSide("The door shudders closed behind you.")
		for i=1,#enemies do
			enemies[i].possiblePath = true
		end
	end
end
-- end seal()

Wall = Tile:new{tile=2, blocker=true, awesome_effect=-1, message="You walk headlong into a wall...", trap = false}
function Wall:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end

CrackedWall = Wall:new{tile=3, awesome_effect=0, trap = false, blocker = false}
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
Staircase = Tile:new{tile=9, blocker=false, trap = false}
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
SpikeTrap = Tile:new{tile=7, blocker=false, awesome_effect=-10, trap = true}
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
		if(char.forcedMarch) then
			printSide("As you fly through the air, a spike trap stabs your butt!")
		else
			printSide("Spikes shoot out of the ground and stab you in the shins!")
		end
	else
		if(victim.forcedMarch) then --enemy hit a spike trap while flying: AWEZZZOMMEE
			printSide("The " .. string.lower(victim.name) .. " is shot full of spikes as it flies across the room!")
			char:gainAwesome(15)
		else
			printSide("Spikes shoot out of the ground and stab the " .. string.lower(victim.name) .. "!")
			char:gainAwesome(5)
		end
		victim:getHit(50)
	end
end

CatapultTrap = Tile:new{tile="u", blocker=false, awesome_effect=0, direction = 1, trap = true}
function CatapultTrap:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.direction = math.random(1,4)
	
	--1=up  2=right  3=down  4=left
	if(self.direction == 1) then
		self.tile="u"
	elseif(self.direction == 2) then
		self.tile="r"
	elseif(self.direction == 3) then
		self.tile="d"
	elseif(self.direction == 4) then
		self.tile="l"
	else
		print("well SOMEthing screwed up in CatapultTrap...")
	end
	return o
end

function CatapultTrap:checkTrap(victim)
	Tile.doAction(self)
	
	if(victim == "you") then
		if(char.forcedMarch) then
			printSide("You land on a catapult, and are thrown across the air!")
		else
			printSide("A hidden catapult springs out of the ground and flings you across the room!")
		end
		
		resultx, resulty = char.x, char.y
		if(self.direction == 1) then
			resulty = resulty - 5
		elseif(self.direction == 2) then
			resultx = resultx + 5
		elseif(self.direction == 3) then
			resulty = resulty + 5
		elseif(self.direction == 4) then
			resultx = resultx - 5
		end
		print("you are at " .. char.x .. ", " .. char.y .. ", punting you to " .. resultx .. ", " .. resulty)
		
		char:forceMarch(resultx,resulty)
	else
		if(victim.forcedMarch) then --enemy hit a trap while flying: AWEZZZOMMEE
			printSide("The " .. string.lower(victim.name) .. " lands on a catapult trap and is sent hurtling across the room!")
			victim:getHit(5)
			char:gainAwesome(15)
			--just in case they get caught in the wall-loop, which I never really figured out :I
		else
			printSide("A hidden catapult springs out of the ground and flings the " .. string.lower(victim.name) .. "across the room!")
		end
		resultx, resulty = victim.x, victim.y
		if(direction == 1) then
			resulty = resulty - 5
		elseif(direction == 2) then
			resultx = resultx + 5
		elseif(direction == 3) then
			resulty = resulty + 5
		elseif(direction == 4) then
			resultx = resultx - 5
		end
		
		victim:forceMarch(resultx, resulty)
	end
end

--pits are special, they don't affect you if you're flyin' over them.
--Also they constitute most of the "Bridge" style level so in that sense they're not really even a trap.
Pit = Tile:new{tile=1, blocker = false, awesome_effect = -10, trap = true}
function Pit:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Pit:checkTrap(victim)
	--don't "doAction" in case we're just passing over
	
	if(victim == "you") then
		if(char.forcedMarch) then
			printSide("You soar over a pit!")
			char:gainAwesome(10)
		else
			printSide("You fall into a deep, dank pit! (Press Enter to Continue)")
			char:loseAwesome(15)
			
			waitingOn = "pit"
			stackPause = stackPause + 1
		end
	else
		printSide("The " .. string.lower(victim.name) .. " falls screaming into the abyss!")
		victim:die()
	end
end
--************END TRAPS**************************