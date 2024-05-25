PauseState = Class{__includes = BaseState}

function PauseState:enter(params)
  sounds["switch"]:play()
  sounds["music"]:pause()
  scrolling = false
  self.state = params
end

function PauseState:exit(params)
  sounds["switch"]:play()
  sounds["music"]:play()
  scrolling = true
end

function PauseState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('p') then
        gStateMachine:change('play', self.state)
    end
end

-- display a huge text saying "Paused"
function PauseState:render()
  self.state:render()
  love.graphics.setFont(hugeFont)
  love.graphics.printf('Paused', 0, 64, VIRTUAL_WIDTH, 'center')
end
