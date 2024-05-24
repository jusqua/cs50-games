--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

local medals = {
    {
        sprite = love.graphics.newImage('images/bronze-medal.png'),
        minScore = 0
    },
    {
        sprite = love.graphics.newImage('images/silver-medal.png'),
        minScore = 5
    },
    {
        sprite = love.graphics.newImage('images/gold-medal.png'),
        minScore = 10
    },
}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
    -- select medal based on score
    for _, medal in ipairs(medals) do
        if self.score >= medal.minScore then
            self.medal = medal.sprite
        end
    end
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.draw(self.medal, VIRTUAL_WIDTH / 2 - self.medal:getWidth() / 2, 120)

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
end
