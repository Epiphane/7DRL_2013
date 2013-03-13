--Table info about all the weapons (functions to come later
bullet = {x=5, y=5, dx=0, dy=0, over=true, range=5, distance=0, nextmove=0}
hands = {}

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
	suspended = true
	
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
		suspended = false
	end
end
--end shoot()

function bullet:draw()
	if(not self.over) then
		love.graphics.print("!", (self.x - offset["x"] - 1)*12, (self.y - offset["y"] - 1)*12 + screenshake)
	end
end

function bullet:update()
	if(currtime > self.nextmove and not self.over)	then
	
		--did we hit something?
		if(map[self.x + self.dx][self.y + self.dy].blocker) then
			self.over = true
			suspended = false
		end
		for i = 1, # enemies do
			if(self.x == enemies[i]["x"] and self.y == enemies[i]["y"]) then
				enemies[i]:getHit(25)
				self.over = true
				suspended = false
			end
		end
		
		self.x = self.x + self.dx
		self.y = self.y + self.dy
		
		self.distance = self.distance + 1
		self.nextmove = currtime + .1
		
		if(self.distance >= self.range) then
			self.over = true
			suspended = false
			self.distance = 9999
		end
	end
	
	--make sure bullet stops if it reaches its maximum range.
	if(self.distance >= self.range) then
		self.over = true
		suspended = false
		bullet_distance = 9999
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
			enemies[i]:getHit(10)
			printSide("You punch the "..enemies[i].name)
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
	fpcooldown = 10
end