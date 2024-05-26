Powerup = Class{}

local actions = {
    -- gerenerate two more balls
    [9] = function (state)
        for _ = 0, 1 do
            local ball = Ball(math.random(7))
            ball.dx = math.random(-200, 200)
            ball.dy = math.random(-50, -60)
            ball.x = state.paddle.x + (state.paddle.width / 2) - 4
            ball.y = state.paddle.y - 8
            table.insert(state.balls, ball)
        end
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
    gSounds["recover"]:play()
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], self.x, self.y)
end
