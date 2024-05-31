--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerGrabState = Class{__includes = BaseState}

function PlayerGrabState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- create hitbox based on where the player is and facing
    local direction = self.player.direction
    local hitboxX, hitboxY, hitboxWidth, hitboxHeight

    self.player.offsetY = 5
    self.player.offsetX = 0

    if direction == 'left' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x - hitboxWidth
        hitboxY = self.player.y + 2
    elseif direction == 'right' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x + self.player.width
        hitboxY = self.player.y + 2
    elseif direction == 'up' then
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y - hitboxHeight
    else
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y + self.player.height
    end

    -- separate hitbox for the player's hands
    self.grabHitbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)

    self.player:changeAnimation('pot-grab-' .. self.player.direction)
end

function PlayerGrabState:enter(params)
    gSounds['grab']:stop()
    gSounds['grab']:play()

    self.player.currentAnimation:refresh()
end

function PlayerGrabState:update(dt)
    -- check if hitbox collides with any objects in the scene
    for _, object in pairs(self.dungeon.currentRoom.objects) do
        if object.liftable and object:collides(self.grabHitbox) then
            self.player:changeState('lift', { object = object })
        end
    end

    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('idle')
    end

    -- allow us to change into this state afresh if we swing within it, rapid grab
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        self.player:changeState('grab')
    end
end

function PlayerGrabState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end
