-- libraries
-- https://github.com/vrld/hump/blob/master/class.lua
local Class = require("external.class")

-- paddle class definition
local Paddle = Class({})

-- paddle initialization class
function Paddle:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.dy = 0
end

-- update paddle position based on delta
function Paddle:update(dt, min_y, max_y)
	-- move paddle and ensure that not go out of bounds
	if self.dy < 0 then
		self.y = math.max(min_y, self.y + self.dy * dt)
	else
		self.y = math.min(max_y - self.height, self.y + self.dy * dt)
	end
end

-- render paddle on given engine
function Paddle:render(love)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Paddle
