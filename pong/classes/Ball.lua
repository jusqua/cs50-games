-- libraries
-- https://github.com/vrld/hump/blob/master/class.lua
local Class = require("external.class")

-- ball class definition
local Ball = Class({})

-- ball initialization class
function Ball:init(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.dy = 0
	self.dx = 0
end

-- ball collision detection based on ball and paddle position
function Ball:collides(paddle)
	-- check to see if the left edge of either is farther to the right than the right edge of the other
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
		return false
	end

	-- check to see if the bottom edge of either is higher than the top edge of the other
	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
		return false
	end

	-- collides
	return true
end

-- reset the ball in given position
function Ball:reset(x, y)
	self.x = x
	self.y = y
	self.dx = 0
	self.dy = 0
end

-- update ball position based on deltas
function Ball:update(dt)
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
end

-- render ball on given engine
function Ball:render(love)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Ball
