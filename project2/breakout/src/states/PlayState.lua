--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls_amount = 1
    self.level = params.level
    self.powerups = {}
    self.balls = {}
    self.locked_bricks = 0
    self.bricks_active = 0

    self.growthPoints = self.score + 1500 * self.paddle.size
    self.recoverPoints = 5000

    -- give ball random starting velocity
    table.insert(self.balls, params.ball)
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)

    -- amount of normal/special bricks in the game
    self.locked_bricks = 0
    self.bricks_active = 0
    
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)
    end

    -- for every powerup on the screen
    for k, powerup in pairs(self.powerups) do
        if powerup:collides(self.paddle) then
            gSounds['paddle-hit']:play()

            -- check if it's key
            if powerup.skin == 9 then
                -- unlock all special bricks
                for k, brick in pairs(self.bricks) do
                    if brick.color == 6 and brick.tier == 1 then
                        brick.tier = 0
                    end
                end
            -- spawn 2 balls
            else
                local ball_tmp_1 = Ball(math.random(7))
                ball_tmp_1.dx = math.random(-200, 200)
                ball_tmp_1.dy = math.random(-50, -60)
                ball_tmp_1.x = self.paddle.x - 8
                ball_tmp_1.y = self.paddle.y

                local ball_tmp_2 = Ball(math.random(7))
                ball_tmp_2.dx = math.random(-200, 200)
                ball_tmp_2.dy = math.random(-50, -60)
                ball_tmp_2.x = self.paddle.x + 8
                ball_tmp_2.y = self.paddle.y
                table.insert(self.balls, ball_tmp_1)
                table.insert(self.balls, ball_tmp_2)

                self.balls_amount = self.balls_amount + 2
            end

            -- remove powerup from the table
            for i, v in pairs(self.powerups) do
                if v == powerup then
                    table.remove(self.powerups, i)
                    break
                end
            end        
            
        end
    end

    -- for every ball
    for k, ball in pairs(self.balls) do 
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end


        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                
                if brick.tier == 0 and brick.color == 6 then
                    self.score = self.score + 1000
                    brick.inPlay = false
                elseif brick.tier ~= 1 and brick.color ~= 6 then
                    -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)

                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()

                    -- give a power up with some chance
                    if math.random(100) > 90 and brick.inPlay == false then
                        local powerUp = Powerup(brick.x + 8, brick.y + 16)
                        table.insert(self.powerups, powerUp)
                    end
                end
                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                if self.score > self.growthPoints then 
                    self.paddle.size = math.min(4, self.paddle.size + 1)
                    self.growthPoints = self.score + 1500 * self.paddle.size
                    self.paddle.width = self.paddle.size * 32
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.balls[1],
                        recoverPoints = self.recoverPoints,
                        balls_amount = 1,
                        powerups = {}
                    })
                end
                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end

        -- count all normal and special bricks
        for k, brick in pairs(self.bricks) do
            if brick.color == 6 and brick.inPlay then
                self.locked_bricks = self.locked_bricks + 1
            end
            if brick.inPlay then
                self.bricks_active = self.bricks_active + 1
            end
        end
        
        -- if the amount of the special bricks equals to 
        -- normal bricks, then unlock all locked bricks
        if self.locked_bricks == self.bricks_active then
            for k, brick in pairs(self.bricks) do
                brick.tier = math.max(0, brick.tier - 1)
            end
        end

        -- if the last ball goes below bounds, revert to serve state and decrease health
        if ball.y >= VIRTUAL_HEIGHT then
            self.balls_amount = self.balls_amount - 1
            gSounds['hurt']:play()
            for i, v in pairs(self.balls) do
                if v == ball then
                    table.remove(self.balls, i)
                    break
                end
            end
            if self.balls_amount == 0 then
                self.health = self.health - 1
                self.paddle.size = math.max(1, self.paddle.size - 1)
                self.growthPoints = self.score + self.paddle.size * 1500
                self.paddle.width = self.paddle.size * 32
                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        ['paddle'] = self.paddle,
                        ['bricks'] = self.bricks,
                        ['health'] = self.health,
                        ['score'] = self.score,
                        ['highScores'] = self.highScores,
                        ['level'] = self.level,
                        ['recoverPoints'] = self.recoverPoints
                    })
                end
            end
        end

        for k, powerup in pairs(self.powerups) do
            if powerup.y >= VIRTUAL_HEIGHT then
                for i, v in pairs(self.powerups) do
                    if v == powerup then
                        table.remove(self.powerups, i)
                        break
                    end
                end
            end
        end

        -- for rendering particle systems
        for k, brick in pairs(self.bricks) do
            brick:update(dt)
        end

        if love.keyboard.wasPressed('escape') then
            love.event.quit()
        end
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for k, ball in pairs(self.balls) do 
        ball:render()
    end
    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end