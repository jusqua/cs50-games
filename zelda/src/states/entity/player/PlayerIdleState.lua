--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:enter(params)
    if params and params.object then
        self.object = params.object
        self.entity:changeAnimation('pot-idle-' .. self.entity.direction)
    end
    
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
        love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk', { object = self.object })
    end

    if self.object then
        -- TODO
    else
        if love.keyboard.wasPressed('space') then
            self.entity:changeState('swing-sword')
        elseif love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self.entity:changeState('grab')
        end
    end
end

function PlayerIdleState:render()
    EntityIdleState.render(self)
    if self.object then
        love.graphics.draw(
            gTextures[self.object.texture],
            gFrames[self.object.texture][self.object.states and self.object.states[self.state].frame or self.object.frame],
            self.object.x,
            self.object.y
        )
    end
end
