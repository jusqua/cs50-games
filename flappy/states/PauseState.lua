PauseState = Class{__includes = BaseState}

function PauseState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('p') then
        gStateMachine:change('play')
    end
end

-- display a huge text saying "Paused"
function PauseState:render()
  love.graphics.setFont(hugeFont)
  love.graphics.printf('Paused', 0, 64, VIRTUAL_WIDTH, 'center')
end
