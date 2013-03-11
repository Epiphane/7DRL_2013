sidebarlog = {"You wake up."}

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
	
	
	-- Draw strength and corresponding health
	love.graphics.setColor( 255, 255, 255 )
	for i = 1,#sidebarlog do
		if i > 8 then break end
		love.graphics.setColor( 255 - i*30, 255 - i*30, 255 - i*30 )
		love.graphics.print(sidebarlog[i], start_x+10, 100+i*15)
	end
end

function printSide(message)
	if message then
		table.insert(sidebarlog, 1, message)
	end
end