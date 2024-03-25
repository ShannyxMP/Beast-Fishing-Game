local menu = require("menu")
local running = require("running")
--[[ TESTING PURPOSES ONLY *TO REMOVE*
local ending1 = require("ending1")
local ending2 = require("ending2")
local ending3 = require("ending3")
]]

local current_state = menu

function love.load()
    -- Pass the change_state function to running.lua
    current_state.load(change_state, running)
    
--[[ TESTING PURPOSES ONLY *TO REMOVE*
    current_state.load()
]]
end

function love.update(dt)
    current_state.update(dt)
end

function love.draw()
    current_state.draw()
end

-- Switch between states
function change_state(newState)
    current_state = newState
    
    -- Check if the new state has a load function (instead of calling immediately)
    if current_state.load then
        current_state.load()
    end
end
