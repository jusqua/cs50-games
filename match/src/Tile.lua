--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- it's a shiny tile?
    self.shiny = false
    self.transitionColor = 1

    -- tile appearance/points
    self.color = color
    self.variety = variety

    if shiny then
        self:shinify()
    end
end

function Tile:shinify()
    self.shiny = true

    Timer.every(1, function ()
        Timer.tween(0.5, {
            [self] = { transitionColor = 0.5 }
        }):finish(function()
            Timer.tween(0.5, {
                [self] = { transitionColor = 1 }
            })
        end)
    end)
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(self.transitionColor, self.transitionColor, self.transitionColor, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
end
