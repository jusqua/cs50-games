--[[
    GD50
    Match-3 Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state the game is in when we've just started; should
    simply display "Match-3" in large text, as well as a message to press
    Enter to begin.
]]

local positions = {}

StartState = Class{__includes = BaseState}

function StartState:init()
    
    -- currently selected menu item
    self.currentMenuItem = 1

    -- colors we'll use to change the title text
    self.colors = {
        [1] = {217/255, 87/255, 99/255, 1},
        [2] = {95/255, 205/255, 228/255, 1},
        [3] = {251/255, 242/255, 54/255, 1},
        [4] = {118/255, 66/255, 138/255, 1},
        [5] = {153/255, 229/255, 80/255, 1},
        [6] = {223/255, 113/255, 38/255, 1}
    }

    -- letters of MATCH 3 and their spacing relative to the center
    self.letterTable = {
        {'M', -108},
        {'A', -64},
        {'T', -28},
        {'C', 2},
        {'H', 40},
        {'3', 112}
    }

    -- time for a color change if it's been half a second
    self.colorTimer = Timer.every(0.075, function()
        
        -- shift every color to the next, looping the last to front
        -- assign it to 0 so the loop below moves it to 1, default start
        self.colors[0] = self.colors[6]

        for i = 6, 1, -1 do
            self.colors[i] = self.colors[i - 1]
        end
    end)

    -- generate full table of tiles just for display
    for i = 1, 64 do
        table.insert(
            positions,
            gFrames['tiles'][gAvailableTilesIndexes[math.random(#gAvailableTilesIndexes)]][math.random(6)]
        )
    end

    -- used to animate our full-screen transition rect
    self.transitionAlpha = 0

    -- if we've selected an option, we need to pause input while we animate out
    self.pauseInput = false
end

function StartState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- as long as can still input, i.e., we're not in a transition...
    if not self.pauseInput then

        -- select menu with mouse
        local mouseInBounds = false
        local mouseX, mouseY = love.mouse.getPosition()
        mouseX, mouseY = push:toGame(mouseX, mouseY)

        local menuX, menuY = VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + 12
        local menuW, menuH = 150, 58

        if (mouseX >= menuX and mouseX <= menuX + menuW) and
           (mouseY >= menuY and mouseY <= menuY + menuH) then
            mouseInBounds = true
            local currentMenuItem = (mouseY - menuY) >= 32 and 2 or 1

            -- play sound if a different location is selected
            if currentMenuItem ~= self.currentMenuItem then
                self.currentMenuItem = currentMenuItem
                gSounds['select']:play()
            end
        end
        
        -- change menu selection
        if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
            self.currentMenuItem = self.currentMenuItem == 1 and 2 or 1
            gSounds['select']:play()
        end

        -- switch to another state via one of the menu options
        if (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) or
           (mouseInBounds and love.mouse.wasPressed(1)) then
            if self.currentMenuItem == 1 then
                
                -- tween, using Timer, the transition rect's alpha to 1, then
                -- transition to the BeginGame state after the animation is over
                Timer.tween(1, {
                    [self] = {transitionAlpha = 1}
                }):finish(function()
                    gStateMachine:change('begin-game', {
                        level = 1
                    })

                    -- remove color timer from Timer
                    self.colorTimer:remove()
                end)
            else
                love.event.quit()
            end

            -- turn off input during transition
            self.pauseInput = true
        end
    end

    -- update our Timer, which will be used for our fade transitions
    Timer.update(dt)
end

function StartState:render()
    
    -- render all tiles and their drop shadows
    for y = 1, 8 do
        for x = 1, 8 do
            
            -- render shadow first
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x], 
                (x - 1) * 32 + 128 + 3, (y - 1) * 32 + 16 + 3)

            -- render tile
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x], 
                (x - 1) * 32 + 128, (y - 1) * 32 + 16)
        end
    end

    -- keep the background and tiles a little darker than normal
    love.graphics.setColor(0, 0, 0, 128/255)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    self:drawMatch3Text(-60)
    self:drawOptions(12)

    -- draw our transition rect; is normally fully transparent, unless we're moving to a new state
    love.graphics.setColor(1, 1, 1, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

--[[
    Draw the centered MATCH-3 text with background rect, placed along the Y
    axis as needed, relative to the center.
]]
function StartState:drawMatch3Text(y)
    
    -- draw semi-transparent rect behind MATCH 3
    love.graphics.setColor(1, 1, 1, 128/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y - 11, 150, 58, 6)

    -- draw MATCH 3 text shadows
    love.graphics.setFont(gFonts['large'])
    self:drawTextShadow('MATCH 3', VIRTUAL_HEIGHT / 2 + y)

    -- print MATCH 3 letters in their corresponding current colors
    for i = 1, 6 do
        love.graphics.setColor(self.colors[i])
        love.graphics.printf(self.letterTable[i][1], 0, VIRTUAL_HEIGHT / 2 + y,
            VIRTUAL_WIDTH + self.letterTable[i][2], 'center')
    end
end

--[[
    Draws "Start" and "Quit Game" text over semi-transparent rectangles.
]]
function StartState:drawOptions(y)
    
    -- draw rect behind start and quit game text
    love.graphics.setColor(1, 1, 1, 128/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y, 150, 58, 6)

    -- draw Start text
    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Start', VIRTUAL_HEIGHT / 2 + y + 8)
    
    if self.currentMenuItem == 1 then
        love.graphics.setColor(99/255, 155/255, 1, 1)
    else
        love.graphics.setColor(48/255, 96/255, 130/255, 1)
    end
    
    love.graphics.printf('Start', 0, VIRTUAL_HEIGHT / 2 + y + 8, VIRTUAL_WIDTH, 'center')

    -- draw Quit Game text
    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Quit Game', VIRTUAL_HEIGHT / 2 + y + 33)
    
    if self.currentMenuItem == 2 then
        love.graphics.setColor(99/255, 155/255, 1, 1)
    else
        love.graphics.setColor(48/255, 96/255, 130/255, 1)
    end
    
    love.graphics.printf('Quit Game', 0, VIRTUAL_HEIGHT / 2 + y + 33, VIRTUAL_WIDTH, 'center')
end

--[[
    Helper function for drawing just text backgrounds; draws several layers of the same text, in
    black, over top of one another for a thicker shadow.
]]
function StartState:drawTextShadow(text, y)
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.printf(text, 2, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 0, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 2, VIRTUAL_WIDTH, 'center')
end
