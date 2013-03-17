--Table info about all the weapons (functions to come later
bullet = {x=5, y=5, dx=0, dy=0, over=true, range=5, distance=0, nextmove=0}
lightsaber = {over=true, sweep=1, sweepdist=3, nextmove=0, damage=45}
shotgun = {x=5, y=5, dx=0, dy=0, over=true, range=3, distance=0, nextmove=0}
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


--Fire bullets with the numpad, scoob.

function bullet:shoot(direction)
	self.x = char.x
	self.y = char.y
	
	self.dx, self.dy = getDirectionByKey(direction)
	
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
		love.graphics.print(".", (self.x - offset["x"] - 1)*12, (self.y - offset["y"] - 1)*12 + screenshake)
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
					if(enemies[i] ~= nil) then
						enemies[i]:getHit(pistolDamage)
					end
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

-- **************************** END SHOTGUN *****************

function shotgun:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

--Just a little thing I maaaade.
--Direction is:


--Fire bullets with the numpad, scoob.

function shotgun:shoot(direction)
	self.x = char.x
	self.y = char.y
	
	self.dx, self.dy = getDirectionByKey(direction)
	
	--now, animate the bullet shootin.
	--suspend user input
	stackPause = stackPause + 1
	
	--move bullet once so it's not on top of our character
	self.x = self.x + self.dx
	self.y = self.y + self.dy
	
	self.over = false
	self.distance = 0
	self.range = 5
	
	self.spreadLeft = {x=0, y=self.dy*-1, dx=0, dy=self.dy*-0.5}
	self.spreadRight = {x=self.dx*-1,y=0, dx=self.dx*-0.5, dy=0}
	
	if(self.dx == 0) then
		self.spreadLeft = {x=1, y=0, dx=0.5, dy=0}
		self.spreadRight = {x=-1, y=0, dx=-0.5, dy=0}
	elseif(self.dy == 0) then
		self.spreadLeft = {x=0, y=1, dx=0, dy=0.5}
		self.spreadRight = {x=0, y=-1, dx=0, dy=-0.5}
	end
	
	self.nextmove = currtime + .08
	
	--are we shooting at a wall?
	if(map[self.x][self.y].blocker) then
		self.over = true
		stackPause = stackPause - 1
	end
end
--end shoot()

function shotgun:die()
	if not self.over then
		self.over = true
		stackPause = stackPause - 1
	end
end

function shotgun:draw()
	if(not self.over) then -- Dont wanna unpause three times!
		love.graphics.print(".", (self.x - offset["x"] - 1)*12, (self.y - offset["y"] - 1)*12 + screenshake)
		love.graphics.print(".", (self.x - offset["x"] - 1 + self.spreadLeft.x)*12, (self.y - offset["y"] - 1 + self.spreadLeft.y)*12 + screenshake)
		love.graphics.print(".", (self.x - offset["x"] - 1 + self.spreadRight.x)*12, (self.y - offset["y"] - 1 + self.spreadRight.y)*12 + screenshake)
	end
end

function shotgun:update()
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
		
		self.spreadLeft.x = self.spreadLeft.x + self.spreadLeft.dx
		self.spreadLeft.y = self.spreadLeft.y + self.spreadLeft.dy
		self.spreadRight.x = self.spreadRight.x + self.spreadRight.dx
		self.spreadRight.y = self.spreadRight.y + self.spreadRight.dy
		
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

-- **************************** END SHOTGUN *****************

-- ************************* BEGIN LIGHTSABER **************
function lightsaber:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function lightsaber:shoot(direction)
	self.x = char.x
	self.y = char.y
	
	self.sweep=1
	
	self.dx, self.dy = getDirectionByKey(direction)
	if(self.dx == self.dy) then
		self.icon = "|"
		self.dx = 0
	elseif(self.dx == 0) then
		self.icon = "/"
		self.dx = self.dy * -1
	elseif(self.dx == self.dy * -1) then
		self.icon = "-"
		self.dy = 0
	elseif(self.dy == 0) then
		self.icon = "\\"
		self.dy = self.dx
	end
	
	--now, animate the bullet shootin.
	--suspend user input
	stackPause = stackPause + 1
	
	self.nextmove = currtime + .08
	self.over = false
end
--end shoot()

function lightsaber:die()
	if not self.over then
		self.over = true
		stackPause = stackPause - 1
	end
end

function lightsaber:draw()
	if(not self.over) then -- Dont wanna unpause three times!
		love.graphics.setColor( 0, 100, 255 )
		love.graphics.print(self.icon, (self.x - offset["x"] - 1+self.dx)*12, (self.y - offset["y"] - 1+self.dy)*12 + screenshake)
		love.graphics.setColor( 255, 255, 255 )
	end
end

function lightsaber:update()
	if(currtime > self.nextmove and not self.over)	then
		for i = 1, # enemies do
			if(self.x+self.dx == enemies[i]["x"] and self.y+self.dy == enemies[i]["y"]) then
				enemies[i]:getHit(self.damage)
			end
		end
		
		self.sweep = self.sweep + 1
		self.nextmove = currtime + .1
		
		-- Mooooooove
		if(self.dx == self.dy) then
			self.icon = "-"
			self.dy = 0
		elseif(self.dx == 0) then
			self.icon = "\\"
			self.dx = self.dy
		elseif(self.dx == self.dy * -1) then
			self.icon = "|"
			self.dx = 0
		elseif(self.dy == 0) then
			self.icon = "/"
			self.dy = self.dx * -1
		end
	end
	
	if(self.sweep > self.sweepdist) then
		self:die()
	end
end
-- *************************** END LIGHTSABER ***************

-- *************************** BEGIN SWORD OF DEMACIA ***************
swordOfDemacia = lightsaber:new{over=true, sweep=1, sweepdist=8, damage=30}
function swordOfDemacia:new(o)
	o = o or {}				-- Set the Barrel's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Barrel
	self.__index = self		-- Define o as a Barrel
	return o				-- Return Barrel
end

function swordOfDemacia:draw()
	if(not self.over) then -- Dont wanna unpause three times!
		love.graphics.print(self.icon, (self.x - offset["x"] - 1+self.dx)*12, (self.y - offset["y"] - 1+self.dy)*12 + screenshake)
	end
end
-- *************************** END SWORD OF DEMACIA ***************

-- SHOOTIN WITH YOUR HANDS
function hands:shoot(direction)
	self.x = char.x
	self.y = char.y
	
	self.dx, self.dy = getDirectionByKey(direction)
	
	for i = 1, # enemies do
		if(self.x + self.dx == enemies[i]["x"] and self.y + self.dy == enemies[i]["y"]) then
			if(char.invisible > 0) then
				enemies[i]:getHit(30)
				printSide("You strike from the shadows, backstabbing the " .. string.lower(enemies[i].name) .."!")
				char.invisible = 0
			else
				if(#char.weapon == 1) then printSide("You punch the "..enemies[i].name) end
				enemies[i]:getHit(10)
			end
			return
		end
	end
	if(#char.weapon == 1) then printSide("You swing at the air...") end
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
				enemies[i]:forceMarch(enemies[i].x - self.dx*math.ceil(self.distance/2), enemies[i].y - self.dy*math.ceil(self.distance/2))
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

-- ****************************** BEGIN SPARTAN BOOTS
SpartanBootsWeapon = {}
function SpartanBootsWeapon:shoot(dx, dy)
	self.x = char.x
	self.y = char.y
	
	self.dx, self.dy = getDirectionByKey(dx, dy)
	
	for i = 1, # enemies do
		print("trying to kick x="..enemies[i]["x"].."y="..enemies[i]["y"].." when we are at "..self.x+self.dx..", "..self.y+self.dy)
		if(self.x + self.dx == enemies[i]["x"] and self.y + self.dy == enemies[i]["y"]) then
			if(enemies[i].health <= 15) then
				enemies[i]:getHit(15)
				printSide("SPARTAAAAA!!!!!!!! The " .. enemies[i].name .. " is reduced to a sticky puddle.")
			else
				enemies[i]:getHit(15)
				
				enemies[i]:forceMarch(self.x+self.dx*10,self.y+self.dy*10)
				printSide("SPARTAAAAA!!!!!!!!")
			end
			return
		end
	end
	
	printSide("You kick at the air and fall over like Charlie Brown")
	char:loseAwesome(10)
end
-- *************************** END SPARTAN BOOTS

-- ****************************** BEGIN PULSEFIRE BOOTS
PulsefireBootsWeapon = {}
function PulsefireBootsWeapon:shoot(dx, dy)
	self.x = char.x
	self.y = char.y
	
	self.dx, self.dy = getDirectionByKey(dx, dy)
	
	char:forceMarch(char.x+self.dx,char.y+self.dy)
end
-- *************************** END PULSEFIRE BOOTS

-- ****************************** BEGIN GRENADESACK
GrenadeWeapon = {}
function GrenadeWeapon:shoot(dx, dy)
	spawnEnemy(char.x, char.y, Grenade)
	--push grenade
	for i=1,#enemies do
		if(enemies[i].name == "Grenade") then
			enemies[i]:getThrown(dx, dy)
			break
		end
	end
end
-- *************************** END GRENADESACK

-- ****************************** BEGIN MINEBAG
MineDropper = {}
function MineDropper:shoot()
	spawnEnemy(char.x, char.y, Mine)
end
-- *************************** END MINEBAG
