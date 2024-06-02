--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Pokemon = Class{}

function Pokemon:init(def, level)
    self.name = def.name

    self.battleSpriteFront = def.battleSpriteFront
    self.battleSpriteBack = def.battleSpriteBack

    self.baseHP = def.baseHP
    self.baseAttack = def.baseAttack
    self.baseDefense = def.baseDefense
    self.baseSpeed = def.baseSpeed

    self.HPIV = def.HPIV
    self.attackIV = def.attackIV
    self.defenseIV = def.defenseIV
    self.speedIV = def.speedIV

    self.HP = self.baseHP
    self.attack = self.baseAttack
    self.defense = self.baseDefense
    self.speed = self.baseSpeed

    self.level = level
    self.currentExp = 0
    self.expToLevel = self.level * self.level * 5 * 0.75

    self:calculateStats()

    self.currentHP = self.HP
end

function Pokemon:calculateStats()
    for i = 1, self.level do
        self:statsLevelUp()
    end
end

function Pokemon.getRandomDef()
    return POKEMON_DEFS[POKEMON_IDS[math.random(#POKEMON_IDS)]]
end

--[[
    Takes the IV (individual value) for each stat into consideration and rolls
    the dice 3 times to see if that number is less than or equal to the IV (capped at 5).
    The dice is capped at 6 just so no stat ever increases by 3 each time, but
    higher IVs will on average give higher stat increases per level. Returns all of
    the increases so they can be displayed in the TakeTurnState on level up.
]]
function Pokemon:statsLevelUp()
    local levelUp = {
        hp = { current = self.HP, increase = 0, next = nil },
        attack = { current = self.attack, increase = 0, next = nil },
        defense = { current = self.defense, increase = 0, next = nil },
        speed = { current = self.speed, increase = 0, next = nil }
    }

    for j = 1, 3 do
        if math.random(6) <= self.HPIV then
            levelUp.hp.increase = levelUp.hp.increase + 1
        end

        if math.random(6) <= self.attackIV then
            levelUp.attack.increase = levelUp.attack.increase + 1
        end

        if math.random(6) <= self.defenseIV then
            levelUp.defense.increase = levelUp.defense.increase + 1
        end

        if math.random(6) <= self.speedIV then
            levelUp.speed.increase = levelUp.speed.increase + 1
        end
    end

    self.HP = levelUp.hp.current + levelUp.hp.increase
    self.attack = levelUp.attack.current + levelUp.attack.increase
    self.defense = levelUp.defense.current + levelUp.defense.increase
    self.speed = levelUp.speed.current + levelUp.speed.increase

    levelUp.hp.next = self.HP
    levelUp.attack.next = self.attack
    levelUp.defense.next = self.defense
    levelUp.speed.next = self.speed

    return levelUp
end

function Pokemon:levelUp()
    self.level = self.level + 1
    self.expToLevel = self.level * self.level * 5 * 0.75

    return self:statsLevelUp()
end
