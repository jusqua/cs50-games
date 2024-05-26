Powerup = Class{}

function Powerup:init(x, y, type)
    -- spawn point
    self.x = x
    self.y = y

    -- powerup type based on frame index
    self.type = type

    -- sprite dimensions
    self.width = 16
    self.height = 16

    --fall speed
    self.dy = 50
end

function Powerup:update(dt)
  self.y = self.y + self.dy * dt
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], self.x, self.y)
end
