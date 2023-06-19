
Powerup = Class{}

-- powerup that gives you balls boost with 75% chance,
-- and unlocking key with 25% chance
function Powerup:init(x,y)
    self.width = 16
    self.height = 16
    self.x = x
    self.y = y

    self.dy = BOOST_SPEED 

    self.skin = math.random(8)
    if math.random(100) > 75 then
        self.skin = 9
    end
end

-- descend towards the bottom
function Powerup:update(dt)
    self.y = self.y + self.dy * dt

end

-- draw powerup at the current position
function Powerup:render()   
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin],
        self.x, self.y)
end

-- check for collision
function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end