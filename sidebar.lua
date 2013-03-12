sidebarlog = {{message="You wake up.", color={r=100,g=255,b=255}}}

function drawSidebar(start_x)
	love.graphics.setFont(mainFont) -- Just in case
	
	love.graphics.setColor( 0, 0, 0 ) -- Set color to black for the terminalish feel
	love.graphics.rectangle("fill", start_x, 0, 200, 600) -- Fill sidebar
	
	-- White is write!
	love.graphics.setColor( 255, 255, 255 )
	
	-- Draw strength and corresponding health
	love.graphics.print("Awesome", start_x+10, 10)
	
	-- And the health bars
	love.graphics.setColor( 129, 129, 129 )
	love.graphics.rectangle("fill", start_x+10, 30, char['awesome'], 10)
	
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
		table.insert(sidebarlog, 1, {message="break", color={r=0,g=0,b=0}})
		m = string.explode(message, "\n")
		for i = #m,1,-1 do
			table.insert(sidebarlog, 1, {message=m[i], color={r=255,g=255,b=255}})
		end
	end
end