-- Constructor for the Tile Class
-- param: o is an object, or table of information.
Enemy = {name="Enemy", icon="E", room=1, x=1, y=1}

function Enemy:new(o)
	o = o or {}				-- Set the tile's info to match passed params
	setmetatable(o, self)	-- Inherit methods and stuff from Tile
	self.__index = self		-- Define o as a Tile
	return o				-- Return Tile
end

-- draws the enemy if he's in the right room
function Enemy:draw()
	if(self.room == char.room) then
		love.graphics.print(self.icon, (self.x - offset["x"]-1)*12, (self.y - offset["y"]-1)*12)
	end
end
-- end draw()