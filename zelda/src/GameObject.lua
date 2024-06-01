--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- states
    self.consumable = def.consumable
    self.liftable = def.liftable
    self.projectile = false
    self.unused = false

    -- default empty collision callback
    self.onCollide = function() end
    self.onConsume = function() end
end

--[[
    AABB with some slight shrinkage of the box on the top side for perspective.
]]
function GameObject:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

function GameObject:update(dt)

end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states and self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end

-- unuse projectile
function GameObject:destroy()
    if self.unused then
        return
    end

    gSounds["broken"]:play()
    self.projectile = false
    self.unused = true
end

-- fire object as projectile
function GameObject:fire(dx, dy)
    self.projectile = true
    self.solid = false
    self.liftable = false

    self.dx = dx
    self.dy = dy

    gSounds["fire"]:play()

    Timer.tween(0.5, {
        [self] = {
            x = self.x + dx * TILE_SIZE * 4,
            y = self.y + dy * TILE_SIZE * 4
        }
    -- ease object lifting
    }):ease(function(t, b, c, d)
      return math.floor(c * t / d + b)
    end):finish(function ()
        self:destroy()
    end)
end
