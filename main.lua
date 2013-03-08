--        ________
--				 |       |
--				 |       |
--		  _______|_______|
--       |       |
--       |       |
--       |       |_______
--
-- 	COMMENT YOUR CODE
--
--	OR YOU'RE WORSE THAN HITLER

-- handy constants
REAL_BIG_NUMBER = 999999999999

--where da bullet?
bullet_x, bullet_y, bullet_dx, bullet_dy = 5, 5, 0 ,0
bullet_over = true
bullet_range = 5
bullet_distance, next_bullet_move = 0, 0

function love.load()
	-- Set background color black, cause it's a console you stupid bitch
	love.graphics.setBackgroundColor( 0, 0, 0 )
	
	-- Load character/NPC/enemy/active objects (x is the random unassigned stuff)
	mainFont = love.graphics.newImageFont ("arial12x12.png", "_!\"#$%&'()*+,-./0123456789:;<=>?@[\\]^_'{|}~"
											.. "xxxxxxxxxxxxxxxxxxxxx"
											.. "xxxxxxxxxxxxxxxxxxxxxxxxx"
											.. "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
											.. "abcdefghijklmnopqrstuvwxyz")
	-- Load floor tiles (for theming and shit)
	floorFont = love.graphics.newImageFont ("floorTiles.png", "1234")
	
	-- Build map
	-- TODO: Make actual level initiation function, this is more of a placeholder
	makeMap()
	
	-- ANOTHER PLACEHOLDER: the level should initiate the character position
	char_x = 20
	char_y = 20
end

-- Temporary values...I'm thinking they'll change dynamically or just not be necessary one day
MAPWIDTH = 120
MAPHEIGHT = 90
function makeMap()
	map = {}
	for i = 1, MAPWIDTH do
		row = {}
		for j = 1, MAPHEIGHT do
			-- Create random tile for the map. Again - placeholder, we need to create functions
			-- and algorithms and shit
			row[j] = math.random(4)
		end
		map[i] = row
	end
end

-- Amount of tiles to display (proportional to display size / 12)
DISPLAYWIDTH = 50
DISPLAYHEIGHT = 50
function love.draw()
	love.graphics.setFont(floorFont)
	for i = 1, DISPLAYWIDTH do
		for j = 1, DISPLAYHEIGHT do
			love.graphics.print(map[i][j], (i-1)*12, (j-1)*12)
		end
	end
	
	love.graphics.setFont(mainFont)
	love.graphics.print("@", char_x*12, char_y*12)	
	
	--draw a bullet if we shot one
	--print("bullet at " .. bullet_x .. ", " .. bullet_y)
	if(not bullet_over) then
		love.graphics.print("!", bullet_x*12, bullet_y*12)
	end
end

currtime = 0

function love.update(dt)
	--We need this timer here so that all timers are standardized.  Otherwise it's crazy
	--crazy crazy god knows what time it is.
	currtime = love.timer.getMicroTime()
	
	--If any button timers have been held down for a certain amt of time
	--(e.g. their timer "expired" in a sense)
	--press the button again and move the timer forward

	if(currtime > rightpress) then 
		checkThenMove(char_x + 1, char_y)
		rightpress = currtime + .1
	end
	if(currtime > leftpress) then 
		checkThenMove(char_x - 1, char_y)
		leftpress = currtime + .1
	end
	if(currtime > uppress) then
		checkThenMove(char_x, char_y - 1)
		uppress = currtime + .1
	end
	if(currtime > downpress) then
		checkThenMove(char_x, char_y + 1)
		downpress = currtime + .1
	end
	
	if(currtime > next_bullet_move and not bullet_over)	then
	
		--did we hit something?
		if(map[bullet_x + 1 + bullet_dx][bullet_y + 1 + bullet_dy] == 2) then
			bullet_over = true
			suspended = false
		end
		
		bullet_x = bullet_x + bullet_dx
		bullet_y = bullet_y + bullet_dy
		
		
		
		bullet_distance = bullet_distance + 1
		next_bullet_move = currtime + .1
		
		if(bullet_distance >= bullet_range) then
			bullet_over = true
			suspended = false
			bullet_distance = 9999
		end
	end
	
	--make sure bullet stops if it reaches its maximum range.
	if(bullet_distance >= bullet_range) then
		bullet_over = true
		suspended = false
		bullet_distance = 9999
	end
end

function love.focus(bool)
end

rightpress = REAL_BIG_NUMBER
leftpress = REAL_BIG_NUMBER
uppress = REAL_BIG_NUMBER
downpress = REAL_BIG_NUMBER

suspended = false
function love.keypressed(key, unicode)
	--print("You pressed " .. key .. ", unicode: " .. unicode)
	
	--don't let the user make input if we're showing an animation or something
	if(not suspended) then
		
		if(key == "right") then
			checkThenMove(char_x + 1, char_y)
			rightpress = currtime + .55
			
			--make sure only the LAST thing pressed counts
			leftpress, uppress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
		elseif(key == "left") then
			checkThenMove(char_x - 1, char_y)
			leftpress = currtime + .55
			
			rightpress, uppress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
		elseif(key == "up") then
			checkThenMove(char_x, char_y - 1)
			uppress = currtime + .55
			
			leftpress, rightpress, downpress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
		elseif(key == "down") then
			checkThenMove(char_x, char_y + 1)
			downpress = currtime + .55
			
			leftpress, rightpress, uppress = REAL_BIG_NUMBER, REAL_BIG_NUMBER, REAL_BIG_NUMBER
		end
		
		--handle numpad keypresses, it's for shooooting.
		--numpad code is formatted as "kp#"
		if(string.sub(key,0,2) == "kp") then
			shoot(string.sub(key,3))
		end
	else
		print("user trying to move while suspended.")
		if(bullet_over) then
			print("bullet IS over...")
		else
			print("bullet is NOT over!")
		end
		print("bullet range is " .. bullet_range .. " bullet distance is " .. bullet_distance)
	end
end

function love.keyreleased(key, unicode)
	-- if a key is released, make sure it doesn't trigger 
	-- the if's up there!
	if(key == "right") then
		rightpress = REAL_BIG_NUMBER
	end
	if(key == "left") then
		leftpress = REAL_BIG_NUMBER
	end
	if(key == "up") then
		uppress = REAL_BIG_NUMBER
	end
	if(key == "down") then
		downpress = REAL_BIG_NUMBER
	end

end

function love.mousepressed(x, y, button)
	print("Current time: " .. currtime)
end

function love.mousereleased(x, y, button)
end

function love.quit()
end

--First, see if there's any obstacles/monsters
--on the designated square.  If there's none,
--move the player character there.

--If there is a monster there, attack it!
--If there's a wall there, just don't do nuffin.
function checkThenMove(x, y)
	--for now I'm pretending "2" is a wall
	--...for some reason the map is offset by a little bit.  Go figure.
	if(map[x+1][y+1] == 2) then
		--do nuffin
	elseif(false) then -- checks for monsters, etc. go here
	
	else-- empty square! we cool.
		char_x, char_y = x, y
	end
end

--Just a little thing I maaaade.
--Direction is:

-- 7   8   9
--
-- 4  you  6
-- 
-- 1   2   3

--Fire bullets with the numpad, scoob.

function shoot(direction)
	bullet_x = char_x
	bullet_y = char_y
	print("shootin in " .. direction .. " bullet starts at " .. bullet_x .. ", " .. bullet_y)
	
	bullet_dx = 0
	bullet_dy = 0
	
	if(direction == "7") then
		bullet_dx = -1
		bullet_dy = -1
	elseif(direction == "8") then
		bullet_dx = 0
		bullet_dy = -1
	elseif(direction == "9") then
		bullet_dx = 1
		bullet_dy = -1
	elseif(direction == "4") then
		bullet_dx = -1
		bullet_dy = 0
	elseif(direction == "6") then
		bullet_dx = 1
		bullet_dy = 0
	elseif(direction == "1") then
		bullet_dx = -1
		bullet_dy = 1
	elseif(direction == "2") then
		bullet_dx = 0
		bullet_dy = 1
	elseif(direction == "3") then
		bullet_dx = 1
		bullet_dy = 1
	end
	
	--now, animate the bullet shootin.
	--suspend user input
	suspended = true
	
	--move bullet once so it's not on top of our character
	bullet_x = bullet_x + bullet_dx
	bullet_y = bullet_y + bullet_dy
	
	bullet_over = false
	bullet_distance = 0
	bullet_range = 5
	
	next_bullet_move = currtime + .08
	
	--are we shooting at a wall?
	if(map[bullet_x + 1][bullet_y + 1] == 2) then
		bullet_over = true
		suspended = false
	end
end
--end shoot()
