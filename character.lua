char = {awesome=100, weapon=hands, forcedMarch = false, fx = 0, fy = 0, dirx=0, diry=0, nextForcedMove = 0, inAPit = false, passiveNum = 0,
		actives = {}, passives = {}, activeNum = 0, invisible = 0}
-- For directions, 0 is neutral, 1 is positive, -1 is negative

function char:hitByExplosion()
	printSideWithColor("You get hit by a fiery explosion!", 255, 0, 0)
	self:loseAwesome(15)
end

function char:getHit(dmg)
	self:loseAwesome(dmg)
end

function char:loseAwesome(amt)
	self.awesome = self.awesome - amt
	if(self.awesome <= 0) then
		gameState = 2
	end
end

function char:gainAwesome(amt)
	self.awesome = self.awesome + amt
end

--this function forces you to move multiple tiles in one frame.
--maybe you WANTED to (i.e. dash attack)
--or maybe you are being knocked on your ass by an explosion.

--It syncs up with the enemy's forcedMarch in case of, for instance,
--an explosion that knocks both you and an enemy away.
function char:forceMarch(newx, newy)
	self.forcedMarch = true
	
	print("newy is " .. newy)
	self.fx = newx
	self.fy = newy
	--print("fy is " .. self.fy .. " ...fyi!")
	
	self.nextForcedMove = currtime + 0.05
	--print("nfm is " .. self.nextForcedMove .. " ...fyi!")
end

char.passives.gottagofast = false
function char:addPassive(name)
	if(name == "Speed Boots") then
		self.passives.gottagofast = true
		self.passiveNum = self.passiveNum + 1
		--keeps track of the last time we skipped an enemy turn
		self.passives.speedincrement = 0
	end
end

function char:addActive(name)
	if(name == "Falcon Punch") then
		self.activeNum = self.activeNum + 1
		self.actives[self.activeNum] = {}
		self.actives[self.activeNum].name = "Falcon Punch"
		self.actives[self.activeNum].maxcooldown = 10
		self.actives[self.activeNum].cooldown = 0
	elseif(name == "Cloak And Dagger") then
		self.activeNum = self.activeNum + 1
		print("addin dat cloak and dagga")
		self.actives[self.activeNum] = {}
		self.actives[self.activeNum].name = "Cloak And Dagger"
		self.actives[self.activeNum].maxcooldown = 10
		self.actives[self.activeNum].cooldown = 0
	end
end

function char:doActive(name)
	print("we got into doactive at least")
	if(name == "Falcon Punch") then
		stackPause = stackPause + 1
		--this flag indicates we're gonna wait for the user to input a direction
		explosion["falcon"] = true
		
		printSide("FALCOOOOON... (choose a direction)")
	elseif(name == "Cloak And Dagger") then
		print("doin dat cloak and dagga")
		printSide("You fade from view! Your next attack will critically strike.")
		char.invisible = 50
	end
end

function char:falconPunch(dx, dy)
	printSide("PAWWWNNCHH!!!")
	makeExplosion(self.x, self.y, 5, false)
	explosion["direction"] = {}
	explosion.direction.x = dx
	explosion.direction.y = dy
	self:forceMarch(char.x + dx*2, char.y + dy*2)
	
	stackPause = stackPause - 1
end


