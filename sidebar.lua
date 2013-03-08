function drawSidebar(start_x)
	love.graphics.setFont(mainFont) -- Just in case
	
	love.graphics.setColor( 0, 0, 0 ) -- Set color to black for the terminalish feel
	love.graphics.rectangle("fill", start_x, 0, 200, 600) -- Fill sidebar
	
	-- White is write!
	love.graphics.setColor( 255, 255, 255 )
	
	-- Draw strength and corresponding health
	love.graphics.print("Strength", start_x+10, 10)
	love.graphics.print("Knowledge", start_x+10, 60)
	love.graphics.print("Energy", start_x+10, 110)
	love.graphics.print("Sanity", start_x+10, 160)
	
	-- And the health bars
	love.graphics.setColor( 255, 0, 0 )
	love.graphics.rectangle("fill", start_x+10, 30, char['strength'], 10)
	love.graphics.setColor( 0, 255, 0 )
	love.graphics.rectangle("fill", start_x+10, 80, char['knowledge'], 10)
	love.graphics.setColor( 0, 0, 255 )
	love.graphics.rectangle("fill", start_x+10, 130, char['energy'], 10)
	love.graphics.setColor( 125, 125, 125 )
	love.graphics.rectangle("fill", start_x+10, 180, char['sanity'], 10)
end