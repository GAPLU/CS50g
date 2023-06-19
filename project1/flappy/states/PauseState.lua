
PauseState = Class{__includes = BaseState}

local pause = love.graphics.newImage('pause.png')

-- preserve all data from the play state so then pass it back later
-- pause the music and play pause sound
function PauseState:enter(params)
    self.score = params.score
    self.pipePairs = params.pipePairs
    self.bird = params.bird
    self.timer = params.timer
    self.lastY = params.lastY
    scrolling = false
    sounds['music']:pause()
    sounds['stop']:play()
end

function PauseState:update(dt)
    -- change the state back to play when enter pressed, resume the music
    -- pass preserved params
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        sounds['music']:play()
        gStateMachine:change('play', {
            ['score'] = self.score,
            ['pipePairs'] = self.pipePairs,
            ['bird'] = self.bird,
            ['timer'] = self.timer,
            ['lastY'] = self.lastY
        })
    end
end

-- render the last shot from play state
function PauseState:render()
    -- simple UI code
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)
    love.graphics.setFont(mediumFont)

    self.bird:render()

    love.graphics.draw(pause, VIRTUAL_WIDTH / 2 - 32, 50)
    love.graphics.printf('Press Enter to continue', 0, 125, VIRTUAL_WIDTH, 'center')

end