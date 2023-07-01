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
    self.consumable = def.consumable

    self.remove = false

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.dx = 0
    self.dy = 0
    -- total distance traveled
    self.flew = 0
    self.width = def.width
    self.height = def.height

    -- default empty collision callback
    self.onCollide = function() end
    -- default empty consume callback
    self.onConsume = function() end
end

function GameObject:update(dt)
    -- check whether the pot is flying
    if self.dx ~= 0 then
        -- change the position and increment the traveled distance
        self.x = self.x + self.dx * dt
        self.flew = self.flew + self.dx * dt

        -- remove if crashes against the wall 
        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE or self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.remove = true
        end
    elseif self.dy ~= 0 then
        -- change the position and increment the traveled distance
        self.y = self.y + self.dy * dt
        self.flew = self.flew + self.dy * dt

        
        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE
        -- remove if crashes against the wall
        if self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 or self.y + self.height >= bottomEdge then
            self.remove = true
        end
    end

    -- remove if traveled more than 4 tiles
    if self.flew >= 64 or self.flew <= -64 then
        self.remove = true
    end

end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end