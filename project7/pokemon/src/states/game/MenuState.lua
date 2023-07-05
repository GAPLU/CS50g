--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

MenuState = Class{__includes = BaseState}

function MenuState:init(menu, onClose, canInput)

    self.menu = menu

    self.onClose = onClose or function() end

    -- flag for taking the input, in case we would implement automatic fading in the future
    self.canInput = canInput

    if self.canInput == nil then self.canInput = true end

end

function MenuState:update(dt)
    if self.canInput then
        self.menu:update(dt)
    end

    -- pop the state in case we closed the selection(pressed space, enter, or return)
    if self.menu.selection.closed then
        gStateStack:pop()
        self.onClose()
    end
end

function MenuState:render()
    self.menu:render()
end