--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:enter(params)
    
    -- render offset for spaced character sprite (negated in render function of state)
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        if self.entity.raised_pot then 
            self.entity:changeState('walk-pot')
        else
            self.entity:changeState('walk')
        end
    end

    -- if the player doesn't hold a pot, swing a sword, otherwise throw the pot
    if love.keyboard.wasPressed('space') and not self.entity.raised_pot then
        self.entity:changeState('swing-sword')
    elseif love.keyboard.wasPressed('space') then
        local dx = 0
        local dy = 0
        if self.entity.direction == 'up' then
            dy = -POT_FLYING_SPEED
        elseif self.entity.direction == 'down' then
            dy = POT_FLYING_SPEED
        elseif self.entity.direction == 'left' then
            dx = -POT_FLYING_SPEED
        else
            dx = POT_FLYING_SPEED
        end
        self.entity.raised_pot.dx = dx
        self.entity.raised_pot.dy = dy
        self.entity.raised_pot = nil
        self.entity:changeState('idle')
    end
end