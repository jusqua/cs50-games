--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelUpMenuState = Class{__includes = BaseState}

function LevelUpMenuState:init(levelUp, onClose)
    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH - 256,
        y = VIRTUAL_HEIGHT - 128,
        width = 256,
        height = 128,
        hasSelection = false,
        items = {
            {
                text = string.format(
                    "HP: %i + %i = %i",
                    levelUp.hp.current,
                    levelUp.hp.increase,
                    levelUp.hp.next
                ),
                onSelect = onClose
            },
            {
                text = string.format(
                    "Attack: %i + %i = %i",
                    levelUp.attack.current,
                    levelUp.attack.increase,
                    levelUp.attack.next
                )
            },
            {
                text = string.format(
                    "Defense: %i + %i = %i",
                    levelUp.defense.current,
                    levelUp.defense.increase,
                    levelUp.defense.next
                )
            },
            {
                text = string.format(
                    "Speed: %i + %i = %i",
                    levelUp.speed.current,
                    levelUp.speed.increase,
                    levelUp.speed.next
                )
            }
        }
    }
end

function LevelUpMenuState:update(dt)
    self.levelUpMenu:update(dt)
end

function LevelUpMenuState:render()
    self.levelUpMenu:render()
end
