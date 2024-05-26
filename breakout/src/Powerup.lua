Powerup = Class{}

local actions = {
    -- duplicate a random ball
    [9] = function (state)
        local extra_ball = Ball(math.random(7))
        local selected_ball = state.balls[math.random(#state.balls)]
        extra_ball.x = selected_ball.x
        extra_ball.y = selected_ball.y
        extra_ball.dx = selected_ball.dx
        extra_ball.dy = selected_ball.dy
        table.insert(state.balls, extra_ball)
    end
}

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

function Powerup:pickup(state)
  actions[self.type](state)
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], self.x, self.y)
end
