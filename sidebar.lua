recentChange = nil
sidebarlog = {{message="You wake up.", color={r=100,g=255,b=255}}}
displayBig = true

--number of characters that we can fit on one line.
CHARS_PER_LINE = 24

function drawSidebar(start_x)
	love.graphics.setFont(mainFont) -- Just in case
	
	love.graphics.setColor( 0, 0, 0 ) -- Set color to black for the terminalish feel
	love.graphics.rectangle("fill", start_x, 0, 400, 800) -- Fill sidebar
	love.graphics.rectangle("fill", 0, 660, 1000, 140) -- Fill sidebar
	
	-- White is write!
	love.graphics.setColor( 255, 255, 255 )
	
	-- Draw strength and corresponding health
	love.graphics.print("Awesome Levels:", 15, 735)
	
	-- And the health bars
	love.graphics.setColor( 129, 129, 129 )
	love.graphics.rectangle("fill", 10, 750, char['awesome']*2, 25)
	
	-- Did awesome change?
	if recentChange then
		if(recentChange.changeType == "loss") then
			love.graphics.setColor( 129, 0, 0 )
			love.graphics.rectangle("fill", char['awesome']*2+10, 750, recentChange.amount, 25)
		else
			love.graphics.setColor( 0, 129, 0 )
			love.graphics.rectangle("fill", char['awesome']*2+10-recentChange.amount, 750, recentChange.amount, 25)
		end
	end
	
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
		love.graphics.print(char.actives[i].name, 20 + 200 * (i-1), 700)
		if(char.actives[i].cooldown > 0) then
			love.graphics.setColor(200,200,200)
			love.graphics.print("[" .. char.actives[i].cooldown .. "]", 100 + 200 * (i - 1), 712)
		end
	end
	if(char.activeNum > 0) then
		love.graphics.print("(Z)", 0, 680)
	end
	if(char.activeNum > 1) then
		love.graphics.print("(X)", 200, 680)
	end
	if(char.activeNum > 2) then
		love.graphics.print("(C)", 400, 680)
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
function parseLongThing(message, CHARS_PER_LINE)
	if not CHARS_PER_LINE then CHARS_PER_LINE = 24 end
	local splitups = {}
	--fucking lua starts at fucking 1 what the fuck
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
					splitups[#splitups+1] = string.sub(message, 1, spaceAt - 1)
					message = string.sub(message,spaceAt)
					break
				else --oh shit we gotta hyphenate I guess...
					splitups[#splitups+1] = string.sub(message, 1, 20) .. "-"
					message = string.sub(message,20)
				end
			end
		end
	end
	
	splitups[#splitups+1] = message
	
	return table.concat(splitups, "\n")
end