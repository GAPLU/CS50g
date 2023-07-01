PlayerLiftPotState = Class{__includes = EntityWalkState}

function PlayerLiftPotState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0
    
    self.entity:changeAnimation('pot-' .. self.entity.direction)

end

function PlayerLiftPotState:enter()
    self.entity.currentAnimation:refresh()
end

function PlayerLiftPotState:update(dt)
    
    if self.entity.currentAnimation.timesPlayed > 0 then
        self.entity.currentAnimation.timesPlayed = 0
        self.entity.raised_pot.x = math.floor(self.entity.x)
        self.entity.raised_pot.y = math.floor(self.entity.y - self.entity.raised_pot.height / 2)
        self.entity:changeState('idle')
    end

end

