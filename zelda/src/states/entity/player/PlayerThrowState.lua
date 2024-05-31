--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerThrowState = Class{__includes = BaseState}

function PlayerThrowState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.player.offsetY = 5
    self.player.offsetX = 0

    self.projectileDX = 0
    self.projectileDY = 0

    local direction = self.player.direction
    if direction == 'left' then
        self.projectileDX = -1
    elseif direction == 'right' then
        self.projectileDX = 1
    elseif direction == 'up' then
        self.projectileDY = -1
    else
        self.projectileDY = 1
    end

    self.player:changeAnimation('pot-throw-' .. self.player.direction)
end

function PlayerThrowState:enter(params)
    self.object = params.object

    Timer.tween(0.1, {
        [self.object] = {
            x = self.player.x + (10 * self.projectileDX),
            y = self.player.y + 5 + (10 * self.projectileDY),
        },
    -- ease object throw
    }):ease(function(t, b, c, d)
      t = t / d
      return math.floor(-c * t * (t - 2) + b)
    end)
end

function PlayerThrowState:update(dt)
    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        table.insert(self.dungeon.currentRoom.objects, self.object)
        self.object:fire(self.projectileDX, self.projectileDY)
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle')
    end
end

function PlayerThrowState:render()
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
