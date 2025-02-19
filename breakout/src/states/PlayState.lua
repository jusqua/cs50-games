--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    -- give ball random starting velocity
    params.ball.dx = math.random(-200, 200)
    params.ball.dy = math.random(-50, -60)

    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.balls = { params.ball }
    self.powerups = {}
    self.timer = params.timer
    self.hits = params.hits

    self.availablePowerups = params.availablePowerups
    self.paddleSizeup = params.paddleSizeup
    self.recoverPoints = params.recoverPoints 
    self.timeLimit = params.timeLimit
    self.hitLimit = params.hitLimit

    for _, brick in pairs(self.bricks) do
        if brick.color == 6 and brick.tier == 3 then
            table.insert(self.availablePowerups, 10)
            break
        end
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    for _, ball in pairs(self.balls) do
        ball:update(dt)
    end
    for _, powerup in pairs(self.powerups) do
        powerup:update(dt)
    end

    for i, powerup in ipairs(self.powerups) do
        if self.paddle:collides(powerup) then
            powerup:pickup(self)
            table.remove(self.powerups, i)
        end
    end

    for _, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with each ball
    for _, ball in pairs(self.balls) do
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- trigger the brick's hit function and score if brick was hitted
                if brick:hit() then
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    self.hits = self.hits + 1

                    -- enough number of hits make a powerup spawn
                    if (self.hits >= self.hitLimit) then
                        self.hits = self.hits - self.hitLimit

                        local powerup = self.availablePowerups[math.random(1, #self.availablePowerups)]
                        table.insert(self.powerups, Powerup(brick.x + brick.width / 2, brick.y + brick.height / 2, powerup))

                        self.hitLimit = math.min(self.hitLimit + 2, 50)
                    end

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)

                        -- multiply recover points by 2
                        self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- if we have enough points, grow paddle
                    if self.score > self.paddleSizeup then
                        local size = math.min(self.paddle.size + 1, 4)
                        if size ~= self.paddle.size then
                            self.paddle.size = size
                            self.paddle.width = 32 * size
                            self.paddle.x = math.max(0, self.paddle.x - 16)
                        end

                        self.paddleSizeup = self.paddleSizeup + math.min(100000, self.paddleSizeup)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            ball = ball,
                            recoverPoints = self.recoverPoints,
                            paddleSizeup = self.paddleSizeup,
                            timeLimit = self.timeLimit,
                            hitLimit = self.hitLimit,
                            availablePowerups = self.availablePowerups,
                            hits = self.hits,
                            timer = self.timer
                        })
                    end
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, remove from list
    for i, powerup in ipairs(self.powerups) do
        if powerup.y >= VIRTUAL_HEIGHT then
            table.remove(self.powerups, i)
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for i, ball in ipairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT then
            table.remove(self.balls, i)

            if #self.balls == 0 then
                local size = math.max(self.paddle.size - 1, 1)
                if size ~= self.paddle.size then
                    self.paddle.size = size
                    self.paddle.width = 32 * size
                    self.paddle.x = math.min(self.paddle.x + 16, VIRTUAL_WIDTH - self.paddle.width)
                end

                self.health = self.health - 1
                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints,
                        paddleSizeup = self.paddleSizeup,
                        timeLimit = self.timeLimit,
                        hitLimit = self.hitLimit,
                        availablePowerups = self.availablePowerups,
                        hits = self.hits,
                        timer = self.timer
                    })
                end
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    self.timer = self.timer + dt
    if self.timer >= self.timeLimit then
        self.timer = self.timer - self.timeLimit

        local powerup = self.availablePowerups[math.random(1, #self.availablePowerups)]
        table.insert(self.powerups, Powerup(math.random(32, WINDOW_WIDTH - 32), 16, powerup))
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    -- render all powerups
    for _, powerup in pairs(self.powerups) do
        powerup:render()
    end

    -- render balls powerups
    for _, ball in pairs(self.balls) do
        ball:render()
    end

    self.paddle:render()

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end
