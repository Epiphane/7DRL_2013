function drawSidebar(start_x)
	love.graphics.setFont(mainFont) -- Just in case
	
	love.graphics.setColor( 0, 0, 0 ) -- Set color to black for the terminalish feel
	love.graphics.rectangle("fill", start_x, 0, 200, 600) -- Fill sidebar
	
	-- White is write!
	love.graphics.setColor( 255, 255, 255 )
	
	-- Draw strength and corresponding health
	love.graphics.print("Strength", start_x+10, 150, math.pi*3/2)
	love.graphics.print("Knowledge", start_x+60, 150, math.pi*3/2)
	love.graphics.print("Energy", start_x+110, 150, math.pi*3/2)
	love.graphics.print("Sanity", start_x+160, 150, math.pi*3/2)
	
	-- And the health bars
	love.graphics.setColor( 255, 0, 0 )
	love.graphics.rectangle("fill", start_x+30, 50, 10, 100)
	love.graphics.setColor( 0, 255, 0 )
	love.graphics.rectangle("fill", start_x+80, 50, 10, 100)
	love.graphics.setColor( 0, 0, 255 )
	love.graphics.rectangle("fill", start_x+130, 50, 10, 100)
	love.graphics.setColor( 125, 125, 125 )
	love.graphics.rectangle("fill", start_x+180, 50, 10, 100)
end