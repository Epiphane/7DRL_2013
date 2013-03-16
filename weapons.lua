--Table info about all the weapons (functions to come later
bullet = {x=5, y=5, dx=0, dy=0, over=true, range=5, distance=0, nextmove=0}
hands = {}

pistolDamage = 25

function bullet:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

--Just a little thing I maaaade.
--Direction is:

-- 7   8   9
--
-- 4  you  6
-- 
-- 1   2   3

--Fire bullets with the numpad, scoob.

function bullet:shoot(direction)
	self.x = char.x
	self.y = char.y
	
	self.dx = 0
	self.dy = 0
	
	if(direction == "7") then
		self.dx = -1
		self.dy = -1
	elseif(direction == "8") then
		self.dx = 0
		self.dy = -1
	elseif(direction == "9") then
		self.dx = 1
		self.dy = -1
	elseif(direction == "4") then
		self.dx = -1
		self.dy = 0
	elseif(direction == "6") then
		self.dx = 1
		self.dy = 0
	elseif(direction == "1") then
		self.dx = -1
		self.dy = 1
	elseif(direction == "2") then
		self.dx = 0
		self.dy = 1
	elseif(direction == "3") then
		self.dx = 1
		self.dy = 1
	end
	
	--now, animate the bullet shootin.
	--suspend user input
	stackPause = stackPause + 1
	
	--move bullet once so it's not on top of our character
	self.x = self.x + self.dx
	self.y = self.y + self.dy
	
	self.over = false
	self.distance = 0
	self.range = 5
	
	self.nextmove = currtime + .08
	
	--are we shooting at a wall?
	if(map[self.x][self.y].blocker) then
		self.over = true
		stackPause = stackPause - 1
	end
end
--end shoot()

function bullet:shoot_nonChar(direction, origin)
	self.x = origin.x
	self.y = origin.y
	
	self.dx = direction.x
	self.dy = direction.y
	
	--now, animate the bullet shootin.
	--suspend user input
	stackPause = stackPause + 1
	
	--move bullet once so it's not on top of our character
	self.x = self.x + self.dx
	self.y = self.y + self.dy
	
	self.over = false
	self.distance = 0
	self.range = 5
	
	self.nextmove = currtime + .08
	
	--are we shooting at a wall?
	if(map[self.x][self.y].blocker) then
		self.over = true
		stackPause = stackPause - 1
	end
end

function bullet:die()
	if not self.over then
		self.over = true
		stackPause = stackPause - 1
	end
end

function bullet:draw()
	if(not self.over) then -- Dont wanna unpause three times!
		love.graphics.print("!", (self.x - offset["x"] - 1)*12, (self.y - offset["y"] - 1)*12 + screenshake)
	end
end

function bullet:update()
	if(currtime > self.nextmove and not self.over)	then
		--did we hit something?
		if(not map[self.x + self.dx] or not map[self.x + self.dx][self.y + self.dy] or map[self.x + self.dx][self.y + self.dy].blocker) then
			self:die()
		end
		
		if not self.target then -- Hitting enemies
			for i = 1, # enemies do
				if(self.x == enemies[i]["x"] and self.y == enemies[i]["y"]) then
					enemies[i]:getHit(pistolDamage)
					self:die()
				end
			end
		else
			if(self.x == self.target.x and self.y == self.target.y) then
				self.target:getHit(25)
				self.over = true
				stackPause = stackPause - 1
			end
		end
		
		self.x = self.x + self.dx
		self.y = self.y + self.dy
		
		self.distance = self.distance + 1
		self.nextmove = currtime + .1
		
		if(self.distance >= self.range) then
			self:die()
		end
	end
	
	--make sure bullet stops if it reaches its maximum range.
	if(self.distance >= self.range) then
		self:die()
	end
end

-- SHOOTIN WITH YOUR HANDS
function hands:shoot(direction)
	self.x = char.x
	self.y = char.y
	
	self.dx = 0
	self.dy = 0
	
	if(direction == "7") then
		self.dx = -1
		self.dy = -1
	elseif(direction == "8") then
		self.dx = 0
		self.dy = -1
	elseif(direction == "9") then
		self.dx = 1
		self.dy = -1
	elseif(direction == "4") then
		self.dx = -1
		self.dy = 0
	elseif(direction == "6") then
		self.dx = 1
		self.dy = 0
	elseif(direction == "1") then
		self.dx = -1
		self.dy = 1
	elseif(direction == "2") then
		self.dx = 0
		self.dy = 1
	elseif(direction == "3") then
		self.dx = 1
		self.dy = 1
	end
	
	for i = 1, # enemies do
		if(self.x + self.dx == enemies[i]["x"] and self.y + self.dy == enemies[i]["y"]) then
			if(char.invisible > 0) then
				enemies[i]:getHit(30)
				printSide("You strike from the shadows, backstabbing the " .. string.lower(enemies[i].name) .."!")
				char.invisible = 0
			else
				enemies[i]:getHit(10)
				printSide("You punch the "..enemies[i].name)
			end
			return
		end
	end
	
	printSide("You swing at the empty air...")
end
--end hands.shoot()

function hands:draw()
end

function hands:update()
end

--initiate FALCOOOONNEEE....   PAWWWWWWNNNCH!
FalconPunch = {direction={}, cooldown=0}

function FalconPunch:useSkill()
	if(self.cooldown ~= 0) then return end
	printSide("PAAAWWWWWWWWWWNCH!!!!!")
	makeExplosion(char.x, char.y, 5, false)
	char:forceMarch(char.x + self.direction.x, char.y + self.direction.y)
	self.cooldown = 10
end

-- **************************************** BEGIN WHIP ********************
WhipWeapon = {icon=".", x=5, y=5, dx=0, dy=0, over=true, range=7, distance=0, nextmove=0, pullDist=2, start_x=1, start_y=1}
function WhipWeapon:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function WhipWeapon:shoot(dx, dy)
	self.x = char.x
	self.y = char.y
	
	self.start_x = char.x
	self.start_y = char.y
	
	self.dx = dx
	self.dy = dy
	
	if(self.dx < 0) then
		if(self.dy < 0) then
			self.icon = "\\"
		elseif(self.dy > 0) then
			self.icon = "/"
		else
			self.icon = "-"
		end
	elseif(self.dx == 0) then
		self.icon = "|"
	else
		if(self.dy < 0) then
			self.icon = "/"
		elseif(self.dy > 0) then
			self.icon = "\\"
		else
			self.icon = "-"
		end
	end
	
	--now, animate the WhipWeapon shootin.
	--suspend user input
	stackPause = stackPause + 1
	
	--move WhipWeapon once so it's not on top of our character
	self.x = self.x + self.dx
	self.y = self.y + self.dy
	
	self.over = false
	self.distance = 0
	self.range = 5
	
	self.nextmove = currtime + .08
	
	--are we shooting at a wall?
	if(map[self.x][self.y].blocker) then
		self.over = true
		stackPause = stackPause - 1
	end
	
	print("Shwoop starting")
end
--end shoot()

function WhipWeapon:die()
	if not self.over then
		self.over = true
		stackPause = stackPause - 1
		if(waitingOn == "whip") then waitingOn = nil end
	end
end

function WhipWeapon:draw()
	if(not self.over) then -- Dont wanna unpause three times!
		for i=1,self.distance do
			love.graphics.print(self.icon, (self.start_x - offset["x"] - 1 + self.dx*i)*12, (self.start_y - offset["y"] - 1 + self.dy*i)*12 + screenshake)
		end
	end
end

function WhipWeapon:update()
	if(currtime > self.nextmove and not self.over)	then
		--did we hit something?
		if(not map[self.x + self.dx] or not map[self.x + self.dx][self.y + self.dy] or map[self.x + self.dx][self.y + self.dy].blocker) then
			self:die()
		end
		
		for i = 1, # enemies do
			if(self.x == enemies[i]["x"] and self.y == enemies[i]["y"]) then
				enemies[i]:forceMarch(enemies[i].x + self.dx*-1, enemies[i].y + self.dy*-1)
				self:die()
			end	
		end
		
		self.x = self.x + self.dx
		self.y = self.y + self.dy
		
		self.distance = self.distance + 1
		self.nextmove = currtime + .1
		
		if(self.distance >= self.range) then
			self:die()
		end
	end
	
	--make sure WhipWeapon stops if it reaches its maximum range.
	if(self.distance >= self.range) then
		self:die()
	end
end
-- ********************************** END WHIP ****************************