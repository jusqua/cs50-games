--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            local tile = self:newTile(tileX, tileY)
            table.insert(self.tiles[tileY], tile)
        end
    end

    if self:calculateMatches() or not self:checkIntegrity() then
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}
                    local start, finish = x - 1, x - matchNum
                    
                    -- find shiny tiles
                    for x2 = start, finish, -1 do
                        if self.tiles[y][x2].shiny then
                            start, finish = 8, 1
                            break
                        end
                    end

                    -- go backwards from here by matchNum
                    for x2 = start, finish, -1 do
                        
                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            local start, finish = 8, 8 - matchNum + 1
            
            -- find shiny tiles
            for x = start, finish, -1 do
                if self.tiles[y][x].shiny then
                    finish = 1
                    break
                end
            end
            
            -- go backwards from end of last row by matchNum
            for x = start, finish, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}
                    local start, finish = y - 1, y - matchNum
                    
                    -- find shiny tiles
                    for y2 = start, finish, -1 do
                        if self.tiles[y2][x].shiny then
                            start, finish = 8, 1
                            break
                        end
                    end

                    for y2 = start, finish, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            local start, finish = 8, 8 - matchNum + 1
            
            -- find shiny tiles
            for y = start, finish, -1 do
                if self.tiles[y][x].shiny then
                    finish = 1
                    break
                end
            end
            
            -- go backwards from end of last row by matchNum
            for y = start, finish, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- 20% chance to generate a shiny block
    local shiny = math.random() > 0.8 and true or false

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- keep track of generated tiles
    local newTiles = {}

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = self:newTile(x, y)
                tile.y = -32
                self.tiles[y][x] = tile
                table.insert(newTiles, tile)

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    if #newTiles ~= 0 and shiny then
        newTiles[math.random(1, #newTiles)]:shinify()
    end

    return tweens
end

--[[
    Check if have at least one possible move in the board
]]
function Board:checkIntegrity()
    local offsets = {
        -2, -- 2 rooms left/up
        -1, -- 1 room left/up
        1,  -- 1 room right/down
        2   -- 2 rooms right/down
    }

    for y = 1, 8 do
        for x = 1, 8 do
            local color = self.tiles[y][x].color
            local found = 1

            -- check horizontal matches, the ugly and the bad way
            -- this logic virtually moves the tile and check if the color
            -- from the left and right side of the tile matches
            -- "moving" y position based on offset, i.e. upwards and backwards
            for offset = -1, 1, 2 do
                local movedY = y + offset
                -- check if it out of bounds
                if movedY >= 1 and movedY <= 8 then
                    -- use the helper table that store the offsets between the virtual position
                    -- of the tile and the other two possible tiles
                    for i = 1, 3 do
                        local leftX = x + offsets[i]
                        local rightX = x + offsets[i + 1]
                        -- check if it out of bounds
                        if leftX >= 1 and leftX <= 8 and rightX >= 1 and rightX <= 8 then
                            local leftColor = self.tiles[movedY][leftX].color
                            local rightColor = self.tiles[movedY][rightX].color
                            -- if color matches, so have one possible move
                            if leftColor == color and rightColor == color then
                                return true
                            end
                        end
                    end
                end
            end
            -- do the same thing to x position :P
            for offset = -1, 1, 2 do
                local movedX = x + offset
                -- check if it out of bounds
                if movedX >= 1 and movedX <= 8 then
                    -- use the helper table that store the offsets between the virtual position
                    -- of the tile and the other two possible tiles
                    for i = 1, 3 do
                        local leftY = y + offsets[i]
                        local rightY = y + offsets[i + 1]
                        -- check if it out of bounds
                        if leftY >= 1 and leftY <= 8 and rightY >= 1 and rightY <= 8 then
                            local leftColor = self.tiles[leftY][movedX].color
                            local rightColor = self.tiles[rightY][movedX].color
                            -- if color matches, so have one possible move
                            if leftColor == color and rightColor == color then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end

    -- no match found
    return false
end

function Board:newTile(x, y)
    return Tile(
        x,
        y,
        -- workaround to get only selected colors with tinkering too much
        gAvailableTilesIndexes[math.random(#gAvailableTilesIndexes)],
        math.random(1, math.min(self.level, 6))
    )
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end
