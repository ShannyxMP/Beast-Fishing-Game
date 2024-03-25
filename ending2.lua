-- Player caught some fish

local ending2 = {}

-- Declaring constants
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480

-- Declaring variables
local scale_x = 0
local scale_y = 0

local timer = 0
local exitTimer = 10 -- to notify player they can exit game

function ending2.load(resetTimer)
    -- Load scene
    okayScene = love.graphics.newImage('sprites/ending-okay.png')

    -- Set title
    love.window.setTitle("Ending 2 of 3")

    -- BACKGROUND
    love.graphics.setDefaultFilter("nearest", "nearest") -- If you scale up the dimensions, it doesn't blur

    -- Game dimensions
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    local window_width, window_height = love.graphics.getDimensions()
    local background_width, background_height = okayScene:getDimensions()

    scale_x = window_width / background_width
    scale_y = window_height / background_height

    -- Music
    okayMusic = love.audio.newSource("sounds/Rhythm Heaven - 04 - OK.mp3", "stream")

    okayMusic:setVolume(0.5)
    okayMusic:play()

    -- Font
    myFont = love.graphics.newFont("Pixelify_Sans/PixelifySans-VariableFont_wght.ttf", 16)
end

function ending2.update(dt)
    timer = timer + dt -- Accumulate time

    -- Allow player to quit game after time elapsed
    if timer >= exitTimer then
        if love.keyboard.isDown("escape") then
            love.event.quit()
        end
    end
end

function ending2.draw()
    -- Set font
    love.graphics.setFont(myFont)

    -- Initiate scene
    love.graphics.draw(okayScene, 0, 0, 0, scale_x, scale_y)

    -- Notify player they can finally quit
    if timer >= exitTimer then
        love.graphics.print("Press ESC to Quit", ((WINDOW_WIDTH * 3) / 4), ((WINDOW_HEIGHT * 9.25) / 10))
    end    
end

return ending2