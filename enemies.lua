-- Constructor for the Tile Class
-- param: o is an object, or table of information.
Enemy = {name="Enemy", icon="E", room=1, x=1, y=1, health=1, forcedMarch = false, alive=true, possiblePath=true}

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
		if(self.weapon) then
			self.weapon:draw()
		end
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
	
	if( not (self.name == "Barrel" or self.name == "Grenade" or self.name == "Mine")) then
		printSide("The " .. string.lower(self.name) .. " has been slain!")
	end
	
	if self.boss then
		spawnObject(self.x, self.y, table.remove(possibleActives, math.random(#possibleActives)))
		map[doorSealer.x][doorSealer.y] = Staircase:new{room={[999]=true}}
	end
end

function Enemy:hitByExplosion(size)
	char:gainAwesome(7)
	self:getHit(size*5)
	if not self.alive then
		printSide("The " .. self.name .. " explodes in a shower of blood!")
		self:die()
	end
end

function Enemy:moveTowardsCharacter(dir_influence)
	--I decided to implement the "invisible" check here!
	--15% chance of moving randomly. Won't fall into traps.
	if(char.invisible > 0) then
		willMove = math.random(0,100)
		if(willMove < 15) then
			dx, dy = math.random(-1,1), math.random(-1,1)
			if(map[self.x + dx] ~= nil) then
				if(map[self.x + dx][self.y + dy]) then
					tile = map[self.x + dx][self.y + dy]
					if(tile.trap) then
						--don't move into a trap, silly
					else
						self:checkAndMove(self.x + dx, self.y + dy)
					end
				end
			end
		end
		return
	end

	if not self.possiblePath then return end
	
	if(dir_influence) then -- Directional influence if you want to be offset from the character
		goal = {x=dir_influence.x + char.x, y=dir_influence.y + char.y}
	else -- OR just chase the char
		goal = {x=char.prev_x, y=char.prev_y}
	end
	
	diff_char = math.abs(char.x - self.x) + math.abs(char.y - self.y)
	diff = math.abs(goal.x - self.x) + math.abs(goal.y - self.y)
	
	if(diff_char > 20 and leveltype == "sewers") then
		--fuck it, too far.
		return
	end
	
	if(diff_char == 1) then
		return
	elseif(diff <= 1) then
		self:checkAndMove(goal.x, goal.y)
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
	until (current_x == goal.x and current_y == goal.y)
	
	if current_min then
		-- Follow the tree back
		local current_tile = tileList[current_x][current_y]
		while(current_tile.parent.parent) do current_tile = current_tile.parent end
		
		self:checkAndMove(current_tile.x, current_tile.y)
	else
		self.possiblePath = false
	end
end

function Enemy:checkAndMove(x, y)	

	if(map[x] == nil or map[x][y] == nil or map[x][y].blocker or map[x][y].trap) then --[[chill]]-- 
		return
	end
	local enemy_in_space = nil
	if(char.x == x and char.y == y) then enemy_in_space = true end
	for i=1,#enemies do
		if(enemies[i].x == x and enemies[i].y == y and enemies[i].name ~= "Mine") then
			enemy_in_space = enemies[i]
			break
		end
	end
	
	if not enemy_in_space then
		self.x = x
		self.y = y
	
		k, v = next(map[self.x][self.y].room,nil)
		self.room = k
	else
		if(self.forcedMarch) then
			dx = x - self.x
			dy = y - self.y
			enemy_in_space:forceMarch(x+dx, y+dy)
			self["x"], self["y"] = x, y
		end
	end
	
	tile = map[x][y]
	
	tile:checkTrap(self)
end

-- Adding stuff to open list
function addList(xo, yo) -- global goal
	if(map[current_x+xo] and map[current_x+xo][current_y+yo] and not map[current_x+xo][current_y+yo].blocker) then
		if(not tileList[current_x+xo]) then tileList[current_x+xo] = {} end
		diff = math.abs(goal.x - (current_x+xo)) + math.abs(goal.y - (current_y+yo))
		if(not tileList[current_x+xo][current_y+yo]) then
			tileList[current_x+xo][current_y+yo] = {x=current_x+xo, y=current_y+yo, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
		else
			if(tileList[current_x+xo][current_y+yo].g > current_min.g+1) then
				tileList[current_x+xo][current_y+yo] = {x=current_x+xo, y=current_y+yo, open=true, f=diff+current_min.g+1, g=current_min.g+1, parent=current_min}
			end
		end
	end
end

function Enemy:update()
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

function Barrel:hitByExplosion()
	char:gainAwesome(15)
	self:getHit(25)
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

Grenade = Enemy:new{name="Grenade", icon="o", health=1}
function Grenade:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Grenade:getHit(dmg)
	return
end

function Grenade:getThrown(dx, dy)
	print("char.x: " .. char.x .. " char.y: " .. char.y)
	self:forceMarch(char.x + dx * 5, char.y + dy * 5)
	self.icon = "3"
end

function Grenade:takeTurn()
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

Mine = Enemy:new{name="Mine", icon="X", health=1}
function Mine:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Mine:getHit(dmg)
	return
end

function Mine:takeTurn()
	if(char.x == self.x and char.y == self.y) then
		makeExplosion(self.x, self.y, 5, true)
		self:die()
		return
	end
	for i=1,#enemies do
		if(enemies[i].x == self.x and enemies[i].y == self.y and enemies[i] ~= self) then
			makeExplosion(self.x, self.y, 5, true)
			self:die()
		end
	end
end

Rat = Enemy:new{name="Rat", icon="r", health=20}
function Rat:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function Rat:takeTurn()
	if(math.random(4) == 3) then return end
	diff_char = math.abs(char.x - self.x) + math.abs(char.y - self.y)
	if(diff_char == 1 and char.invisible == 0) then
		m = math.random(4)
		if(m == 1) then
			printSide("The Rat climbs up into your trousers.")
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

GiantRat = Enemy:new{name="Giant Rat", icon="R", health=100, boss=false}
function GiantRat:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function GiantRat:takeTurn()
	if(math.random(6) == 5) then return end
	diff_char = math.abs(char.x - self.x) + math.abs(char.y - self.y)
	if(diff_char == 1  and char.invisible == 0) then
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

Zombie = Enemy:new{name="Zombie", icon="Z", health=200}
function Zombie:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function Zombie:takeTurn()
	if(math.random(3) ~= 3) then return end
	self:moveTowardsCharacter()
	diff_char = math.abs(char.x - self.x) + math.abs(char.y - self.y)
	if(diff_char == 1  and char.invisible == 0) then
		m = math.random(3)
		if(m == 1) then
			printSide("The Zombie grabs your neck.")
		elseif(m == 2) then
			printSide("The Zombie hugs you longingly")
		elseif(m == 3) then
			printSide("The Zombie feels you up.")
		end
		char:loseAwesome(10)
		return
	end
end

Skeleton = Enemy:new{name="Skeleton", icon="S", health=75, weapon=bullet:new{target=char}}
function Skeleton:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

-- Skeleton tries to get to the o's depending on where it's closer to
-- o | o | o
-- \ \ | / /
-- o - x - o
-- / / | \ \
-- o | o | o

function Skeleton:takeTurn()
	if(math.random(6) == 5) then return end
	d_i = {x=0, y=0}
	if(self.x > char.x) then d_i.x = 3
	elseif(self.x < char.x) then d_i.x = -3 end
	if(self.y > char.y) then d_i.y = 3
	elseif(self.y < char.y) then d_i.y = -3 end
	self:moveTowardsCharacter(d_i)
	
	local dx = math.abs(char.x- self.x)
	local dy = math.abs(char.y- self.y)
	local m = 0
	if(math.random(6) >= 3 and dx <= 3 and dy <= 3) then
		self.weapon:shoot_nonChar({x=d_i.x/-3, y=d_i.y/-3}, self)
		m = math.random(3)
	end
	if(m == 1) then
		printSide("The Skeleton chucks a pelvis at you.")
	elseif(m == 2) then
		printSide("The Skeleton chucks a humorous bone at you. HA.")
	elseif(m == 3) then
		printSide("The Skeleton chucks a skull at you.")
	end
end

function Skeleton:update()
	self.weapon:update()
end

-- BEGIN EVIL WIZARD ******************************
wizLaserTiles = {} --keeps track of where the wizard lazer tiles show up
wizLaserMode = "idle"
EvilWizard = Enemy:new{name="Evil Wizard", icon="W", health=300}
function EvilWizard:new(o)
	self.name = randomName()
	self.icon = "W"
	self.health = 300
	return self
	--o = o or {}				-- Set the Barrel's info to match passed params
	--setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	--self.__index = self		-- Define o as a Barrel
	--return o				-- Return Barrel
	--Have a randomly generated name for the wizard
end


function EvilWizard:takeTurn()
	wizardChoice = math.random(0,100)
	--Wizard has a 1/10 chance of making an explosion randomly near you...
	if(wizardChoice < 10) then
		printSideWithColor(self.name .. " waves his hand and the ground around you erupts in flame!", 237, 121, 26)
		
		makeExplosion(char.x + math.random(-5,5), char.y + math.random(-5,5), 4, true)
		
	--1/10 of spawning a random enemy...
	elseif(wizardChoice < 20) then
		whichEnemy = math.random(1,4)
		if(whichEnemy == 1) then
			whichEnemy = Skeleton
		elseif(whichEnemy == 2) then
			whichEnemy = Rat
		elseif(whichEnemy == 3) then
			whichEnemy = GiantRat
		elseif(whichEnemy == 4) then
			whichEnemy = Zombie
		end
		
		printSideWithColor(self.name .. " vomits out a " .. whichEnemy.name .."!", 84, 196, 20)
		spawnEnemy(self.x + 1, self.y + 1, whichEnemy)
		
	--1/10 chance of mocking you...
	elseif(wizardChoice < 30) then
		whichMessage = math.random(1,4)
		if(whichMessage == 1) then
			printSideWithColor("\"Your torment shall be unending!\" shouts " .. self.name, 196, 23, 20)
		elseif(whichMessage == 2) then
			printSideWithColor("\"Just stand still and accept your fate!\" screams " .. self.name, 196, 20, 185)
		elseif(whichMessage == 3) then
			printSideWithColor("\"Yo I'mma really screw you up!\" yells " .. self.name, 20, 164, 196)
		elseif(whichMessage == 4) then
			printSideWithColor("\"ALLAN PLEASE WRITE A WIZARD TAUNT\" " .. self.name .. " yells", 	40, 196, 20)
		end
	
	--1/10 chance of doin dat lazar
	elseif(wizardChoice < 40) then
		printSide(self.name .. " fires a powerful beam of energy!")
		self:doLaser()
	end

end

--do a sweet laser aimed at the player
ldx, ldy = 0, 0 --stores direction of laser


--for some reason EvilWizard forgets where he is, the Alzheimeristic bastard.
--gotta save that value here.
evilWizX, evilWizY = 0, 0
function EvilWizard:doLaser()
	--figure out which direction we gonn do it
	diffX = char.x - self.x
	diffY = char.x - self.y
	
	evilWizX, evilWizY = self.x, self.y
	
	ldx, ldy = 0, 0
	
	if(math.abs(diffY) > math.abs(diffX)) then --must be either up/down
		if(diffY > 0) then
			ldy = 1
		else
			ldy = -1
		end
	else -- must be horizontal
		if(diffX > 0) then
			ldx = -1
		else
			ldx = 1
		end
	end
	
	--hold up a second mr. user
	stackPause = stackPause + 1
	
	--wipe the old lazer table
	for k in pairs (wizLaserTiles) do
		wizLaserTiles [k] = nil
	end
	
	--"tracking" lazer
	--is a straight line from the wizard in the direction he chose
	print("well why the fuck is self.x, self.y " .. self.x .. ", " .. self.y .. " here then?")
	if(ldx ~= 0) then
		ly = self.y
		lx = self.x
		while(lx ~= self.x + ldx * 40) do
			table.insert(wizLaserTiles, {x=lx, y=ly})
			--print("So we just put " .. wizLaserTiles[#wizLaserTiles].x .. " as x, " .. wizLaserTiles[#wizLaserTiles].y .. " as y, in tracking")
			lx = lx + ldx
		end
	else
		lx = self.x
		ly = self.y
		while(ly ~= self.y + ldy * 40) do
			table.insert(wizLaserTiles, {x=lx, y=ly})
			ly = ly + ldy
		end
	end
	
	wizLaserMode = "tracking"
	fireLaserTime = currtime + 0.5 --when do we switch from track mode to firing mode?
	waitingOn = "wizLaser"
end

doneLaserTime = 0
function EvilWizard:updateLaser()
	if(wizLaserMode == "tracking") then
		if(currtime > fireLaserTime) then
			--FIIIARRRRRR
			wizLaserMode = "firing"
			
			--figure out where the laser thingies should be
			--generally looks like this:
			--[[
			      ------------------------->
			   ---------------------------->
			W------------------------------> BLLEAAARGH
			   ---------------------------->
			      ------------------------->
			]]--
			
			print("self.x: " .. evilWizX .. " self.y: " .. evilWizY)
			lx = evilWizX
			ly = evilWizY
			if(ldx ~= 0) then
				while(lx ~= evilWizX + ldx * 40) do
					ly = evilWizY + 1
					table.insert(wizLaserTiles, {x=lx, y=ly})
					ly = evilWizY - 1
					table.insert(wizLaserTiles, {x=lx, y=ly})
					
					ly = evilWizY + 2
					row2x = lx + 2 * ldx
					table.insert(wizLaserTiles, {x=row2x, y=ly})
					ly = evilWizY - 2
					table.insert(wizLaserTiles, {x=row2x, y=ly})
					--print("But in the big cahoots, it's called lx: " .. lx .. ", ly: " .. ly)
					lx = lx + ldx
				end
			end
			
			if(ldy ~= 0) then
				while(ly ~= evilWizY + ldy * 40) do
					lx = evilWizX + 1
					table.insert(wizLaserTiles, {x=lx, y=ly})
					lx = evilWizX - 1
					table.insert(wizLaserTiles, {x=lx, y=ly})
					
					lx = evilWizX + 2
					row2y = ly + 2 * ldy
					table.insert(wizLaserTiles, {x=lx, y=row2y})
					lx = evilWizX - 2
					table.insert(wizLaserTiles, {x=lx, y=row2y})
					
					ly = ly + ldy
				end
			end
		end
		
		doneLaserTime = currtime + 0.5
	end
	
	if(wizLaserMode == "firing") then
		if(currtime > doneLaserTime) then
			--no moar lazer
			for k in pairs (wizLaserTiles) do
				wizLaserTiles [k] = nil
			end
			
			--we done here
			stackPause = stackPause - 1
			if(waitingOn == "wizLaser") then
				waitingOn = nil
			end
		end
	end
end

-- END EVIL WIZARD   ******************************

function Enemy:forceMarch(newX, newY)
	self.forcedMarch = true
	self.targetX = newX
	self.targetY = newY
end