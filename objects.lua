Pistol = {name="Pistol", icon=";", room=1, x=1, y=1, alive=true}

-- Pistol constructor seals a door
function Pistol:new(o)
	o = o or {}
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o
end
-- end constructor

function Pistol:interact()
	char.weapon = bullet
	printSide("You pick up the Pistol")
	self.alive = false
end

-- draws the enemy if he's in the right room
function Pistol:draw()
	if(self.room == char.room) then
		love.graphics.print(self.icon, (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12 + screenshake)
	end
end
-- end draw()