char = {awesome=100, weapon=hands, forcedMarch = false, fx = 0, fy = 0, dirx=0, diry=0, nextForcedMove = 0, inAPit = false}
-- For directions, 0 is neutral, 1 is positive, -1 is negative

function char:hitByExplosion()
	printSideWithColor("You get hit by a fiery explosion!", 255, 0, 0)
	self:loseAwesome(15)
end

function char:getHit(dmg)
	loseAwesome(dmg)
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

