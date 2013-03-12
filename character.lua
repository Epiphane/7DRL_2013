char = {awesome=100, weapon=hands}

function char:hitByExplosion()
	printSideWithColor("You get hit by a fiery\n explosion!", 255, 0, 0)
	self.awesome = self.awesome - 15
end

