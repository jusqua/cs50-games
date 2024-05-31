--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerLiftState = Class{__includes = BaseState}

function PlayerLiftState:init(player)
    self.player = player

    self.player:changeAnimation('pot-lift-' .. self.player.direction)
end

function PlayerLiftState:enter(params)
    self.object = params.object
    gSounds['lift']:play()
    Timer.tween(0.3, {
        [self.object] = {
            x = self.player.x, 
            y = self.player.y - 10,
        },
    -- ease object lifting to not make
    }):ease(function(t, b, c, d)
      t = t / d
      return math.floor(-c * t * (t - 2) + b)
    end)
end

function PlayerLiftState:update(dt)
    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle', { object = self.object })
    end
end

function PlayerLiftState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

    love.graphics.draw(
        gTextures[self.object.texture],
        gFrames[self.object.texture][self.object.states and self.object.states[self.state].frame or self.object.frame],
        self.object.x,
        self.object.y
    )
end
