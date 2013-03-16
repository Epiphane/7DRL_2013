
sidebarlog = {{message="You wake up.", color={r=100,g=255,b=255}}}
displayBig = true

--number of characters that we can fit on one line.
CHARS_PER_LINE = 24

function drawSidebar(start_x)
	love.graphics.setFont(mainFont) -- Just in case
	
	love.graphics.setColor( 0, 0, 0 ) -- Set color to black for the terminalish feel
	love.graphics.rectangle("fill", start_x, 0, 200, 600) -- Fill sidebar
	
	-- White is write!
	love.graphics.setColor( 255, 255, 255 )
	
	-- Draw strength and corresponding health
	love.graphics.print("Awesome Levels:", 100, 600)
	
	-- And the health bars
	love.graphics.setColor( 129, 129, 129 )
	love.graphics.rectangle("fill", start_x+10, 30, char['awesome'], 10)
	
	-- Draw important message
	for i=1,#sidebarlog do
		love.graphics.setColor( sidebarlog[i].color.r, sidebarlog[i].color.g, sidebarlog[i].color.b )
		love.graphics.print(sidebarlog[i].message, 25, 25+i*15)
		if(sidebarlog[i].message == "break") then
			break
		end
	end
	
	-- Draw message log
	love.graphics.setColor( 255, 255, 255 )
	fade = 255
	for i = 1,#sidebarlog do
		if fade <= 0 then break end
		love.graphics.setColor( sidebarlog[i].color.r*fade/255, sidebarlog[i].color.g*fade/255, sidebarlog[i].color.b*fade/255 )
		love.graphics.print(sidebarlog[i].message, start_x+10, 100+i*15)
		if(sidebarlog[i].message == "break") then
			fade = fade - 30
		end
	end
	
	love.graphics.setColor( 255, 255, 255)
	for i = 1, #(char.actives) do
		love.graphics.print(char.actives[i].name, 20 + 200 * (i-1), 500)
		if(char.actives[i].cooldown > 0) then
			love.graphics.setColor(200,200,200)
			love.graphics.print("[" .. char.actives[i].cooldown .. "]", 100 + 200 * (i - 1), 512)
		end
	end
	if(char.activeNum > 0) then
		love.graphics.print("Z:", 100 + 200 * (0), 488)
	end
	if(char.activeNum > 1) then
		love.graphics.print("Z:", 100 + 200 * (1), 488)
	end
	if(char.activeNum > 2) then
		love.graphics.print("Z:", 100 + 200 * (2), 488)
	end
end

function printSideWithColor(message, r, g, b)
	if message then
		table.insert(sidebarlog, 1, {message="break", color={r=0,g=0,b=0}})
		m = string.explode(message, "\n")
		for i = #m,1,-1 do
			table.insert(sidebarlog, 1, {message=m[i], color={r=r,g=g,b=b}})
		end
	end
end

function printSide(message)
	if message then
		message = parseLongThing(message)
	
		table.insert(sidebarlog, 1, {message="break", color={r=0,g=0,b=0}})
		m = string.explode(message, "\n")
		for i = #m,1,-1 do
			table.insert(sidebarlog, 1, {message=m[i], color={r=255,g=255,b=255}})
		end
	end
end

--takes a nice long thing makes it short.
--Will try to split up along spaces if possible.
--If there's more than 10 characters that will be shifted
--down, it puts a hyphen in.
function parseLongThing(message)
	local splitups = {0,0,0,0,0,0,0}
	--fucking lua starts at fucking 1 what the fuck
	local numsplits = 1
	local i, spaceAt = 0, 0
	
	--print(#message .. ": #message length")
	--See if there's a space at 24, 23, 22, etc.
	while(#message > 24) do
		for i = 0, CHARS_PER_LINE do
			if(string.sub(message, CHARS_PER_LINE - i, CHARS_PER_LINE - i) == " ") then
				spaceAt = CHARS_PER_LINE - i + 1
				
				--is the space at a reasonable splitting point?
				if(spaceAt > 12) then
					--add the chunk we just found to our list of splitups
					splitups[numsplits] = string.sub(message, 1, spaceAt - 1)
					message = string.sub(message,spaceAt)
					break
				else --oh shit we gotta hyphenate I guess...
					splitups[numsplits] = string.sub(message, 1, 20) .. "-"
					message = string.sub(message,20)
				end
			end
		end
		
		numsplits = numsplits + 1
	end
	
	splitups[numsplits] = message
	message = ""
	
	--reassemble string with \n's in between each splitup
	for i = 1, numsplits do
		message = message .. "\n" .. splitups[i]
	end
	
	return message
end