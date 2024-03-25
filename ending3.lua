-- Player caught all fish

local ending3 = {}

-- Libaries
local anim8 = require 'libraries/anim8'

-- Declaring constants
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480

-- Declaring variables
local scale_x = 0
local scale_y = 0

local timer = 0
local secondSceneTimer = 20 -- to initiate 'endImages.animations.text'
local thirdSceneTimer = 35 -- to initiate 'endImages.animations.creature'
local exitTimer = thirdSceneTimer + 10 -- to notify player they can exit game

-- Declaring image variables
local endImages = {}

function ending3.load()
    -- To assist with default dimensions
    endImages.perfectScene = love.graphics.newImage('sprites/ending-perfect.png')
    
    -- Load BACKGROUND images
    endImages.secretSceneSheet = love.graphics.newImage('sprites/ending-secret.png')
    endImages.grid = anim8.newGrid( 640, 480, endImages.secretSceneSheet:getWidth(), endImages.secretSceneSheet:getHeight() )

    endImages.animations = {}
    endImages.animations.perfectScene = anim8.newAnimation( endImages.grid('1-5', 1), 0.5)
    endImages.animations.text = anim8.newAnimation( endImages.grid('1-5', 2), 0.05)
    endImages.animations.creature = anim8.newAnimation( endImages.grid('1-5', 3), 0.75)

    -- BACKGROUND will be *pre-set* to 'perfectScene'
    endImages.anim = endImages.animations.perfectScene

    -- Set title
    love.window.setTitle("@%$h&3LP 3 of 3")

    -- BACKGROUND settings
    love.graphics.setDefaultFilter("nearest", "nearest") -- If you scale up the dimensions, it doesn't blur

    -- Game dimensions
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    local window_width, window_height = love.graphics.getDimensions()
    local background_width, background_height = endImages.perfectScene:getDimensions()

    scale_x = window_width / background_width
    scale_y = window_height / background_height

    -- Music
    sounds = {}
    sounds.perfectMusic = love.audio.newSource("sounds/Rhythm Heaven - 07 - Superb.mp3", "stream")
    sounds.eerieMusic = love.audio.newSource("sounds/Resident Evil 4 - 04 - A Strange Pasture.mp3", "stream")
    sounds.noise = love.audio.newSource("sounds/noise.mp3", "static")

    sounds.perfectMusic:setVolume(0.5)
    sounds.perfectMusic:play()

    sounds.eerieMusic:setVolume(1)

    -- Font
    myFont = love.graphics.newFont("Pixelify_Sans/PixelifySans-VariableFont_wght.ttf", 16)
end

function ending3.update(dt)
    timer = timer + dt -- Accumulate time
    endImages.anim:update(dt)

    -- Change to second scene
    if timer >= secondSceneTimer then
        endImages.anim = endImages.animations.text

        sounds.perfectMusic:stop()
        sounds.noise:play()
        sounds.eerieMusic:play()
    end

    -- Change to third scene
    if timer >= thirdSceneTimer then
        endImages.anim = endImages.animations.creature

        sounds.noise:stop()
    end

    -- Allow player to quit game after time elapsed
    if timer >= exitTimer then
        if love.keyboard.isDown("escape") then
            love.event.quit()
        end
    end
end

function ending3.draw()
    -- Set font
    love.graphics.setFont(myFont)

    -- Set animations
    endImages.anim:draw(endImages.secretSceneSheet, 0, 0, 0, scale_x, scale_y)

    -- Notify player they can finally quit
    if timer >= exitTimer then
        love.graphics.print("Press ESC to Quit", ((WINDOW_WIDTH * 3) / 4), ((WINDOW_HEIGHT * 9.25) / 10))
    end
end

return ending3