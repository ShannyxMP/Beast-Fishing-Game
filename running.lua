local running = {}

local ending1 = require("ending1")
local ending2 = require("ending2")
local ending3 = require("ending3")

-- Libaries
local anim8 = require 'libraries/anim8'

-- Declaring constants
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480

-- Declaring variables
local scale_x = 0
local scale_y = 0
local lureBeingPulled = false
local backToFishing = true
local tutorialTextOn = true

-- Declaring image variables
local newCreature = nil

local player = {}
local lure = {}
local backgroundImages = {}
local fishImages = {}

-- Declaring timer variables
local tutorialTimer = 0
local tutorialDuration = 10

local gameTime = 45 --[[ TO CHANGE FOR TESTING PURPOSES ]]
local gameTimeRemaining = gameTime
local gameOver = false -- Tracks whether countdown / ending should be initiated 

local creatureDisplayTimer = 0
local creatureDisplayDuration = 3
local isTimerRunning = false -- Tracks whether the timer is currently running (to stop "space" keypress amidst creature being displayed)

-- Stores caught creatures
local caughtCreatures = {}

function running.load()
    -- Set title
    love.window.setTitle("Fishing Time")

    -- Load BACKGROUND images
    backgroundImages.draft = love.graphics.newImage('sprites/draft.png')
    backgroundImages.cliff = love.graphics.newImage('sprites/cliff.png')
    backgroundImages.sky = love.graphics.newImage('sprites/sky.png')
    backgroundImages.guide = love.graphics.newImage('sprites/guide.png')

    -- BACKGROUND setting
    love.graphics.setDefaultFilter("nearest", "nearest") -- If you scale up the dimensions, it doesn't blur

    -- Game dimensions
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    local window_width, window_height = love.graphics.getDimensions()
    local background_width, background_height = backgroundImages.draft:getDimensions()

    scale_x = window_width / background_width
    scale_y = window_height / background_height
    
    -- Load SUN image
    sunImage = love.graphics.newImage('sprites/sun.png')

    -- Load FISH images
    fishImages.creatures = {}
    fishImages.creatures.crab1 = love.graphics.newImage('sprites/creature-crab1.png')
    fishImages.creatures.crab2 = love.graphics.newImage('sprites/creature-crab2.png')

    fishImages.creatures.fish1 = love.graphics.newImage('sprites/creature-fish1.png')
    fishImages.creatures.fish2 = love.graphics.newImage('sprites/creature-fish2.png')

    fishImages.creatures.jelly1 = love.graphics.newImage('sprites/creature-jelly1.png')
    fishImages.creatures.jelly2 = love.graphics.newImage('sprites/creature-jelly2.png')

    fishImages.creatures.shark1 = love.graphics.newImage('sprites/creature-shark1.png')
    fishImages.creatures.shark2 = love.graphics.newImage('sprites/creature-shark2.png')

    -- Load DISPLAY image
    fishImages.spriteSheetNormal = love.graphics.newImage('sprites/display1Sheet.png')
    fishImages.gridNormal = anim8.newGrid ( 64, 64, fishImages.spriteSheetNormal:getWidth(), fishImages.spriteSheetNormal:getHeight() )

    fishImages.spriteSheetGlitch = love.graphics.newImage('sprites/display2Sheet.png')
    fishImages.gridGlitch = anim8.newGrid ( 64, 64, fishImages.spriteSheetGlitch:getWidth(), fishImages.spriteSheetGlitch:getHeight() )
    fishImages.glitch = love.graphics.newImage('sprites/glitch.png')
    
    fishImages.animations = {}
    fishImages.animations.displayNormal = anim8.newAnimation( fishImages.gridNormal('1-6', 1), 0.20 )
    fishImages.animations.displayGlitch = anim8.newAnimation( fishImages.gridGlitch('1-6', 1), 0.20 )


    -- PLAYER properties
    player.x = 0
    player.y = 0
    player.spriteSheet  = love.graphics.newImage('sprites/finnSheet.png')
    player.grid = anim8.newGrid( 64, 64, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )
    
    player.animations = {}
    player.animations.quiet = anim8.newAnimation( player.grid('1-2', 1), 1 )
    player.animations.snagged = anim8.newAnimation( player.grid('1-2', 2), 0.5 )
    player.animations.pulled = anim8.newAnimation( player.grid('1-2', 3), 0.2 )

    -- PLAYER will be *pre-set* to 'quite'
    player.anim = player.animations.quiet

    -- LURE properties:
    lure.x = WINDOW_WIDTH / 2
    lure.originalLurePosition = -15
    lure.y = lure.originalLurePosition 
    lure.x_speed = 7
    lure.x_direction = 1
    lure.y_speed = 15
    lure.y_direction = -1
    lure.spriteSheet = love.graphics.newImage('sprites/lureSheet.png') -- !!!NOT WORKING
    lure.grid = anim8.newGrid( 192, 416, lure.spriteSheet:getWidth(), lure.spriteSheet:getHeight() )

    lure.animations = {}
    lure.animations.snagged = anim8.newAnimation( lure.grid('1-4', 1), 0.20 )
    lure.animations.pulled = anim8.newAnimation( lure.grid('1-4', 2), 0.1 )

    -- LURE will be *pre-set* to 'pulled'
    lure.anim = lure.animations.pulled

    -- Table to keep track of keys released
    love.keyboard.key_released = {}

    -- SFX and Music
    sounds = {}
    sounds.mlem = love.audio.newSource("sounds/yoshi-mlem.mp3", "static")
    sounds.inGameMusic = love.audio.newSource("sounds/music.mp3", "stream")

    sounds.mlem:setVolume(0.5)

    sounds.inGameMusic:setVolume(1) 
    sounds.inGameMusic:setLooping(true)
    sounds.inGameMusic:play()

    -- Font
    myFont = love.graphics.newFont("Pixelify_Sans/PixelifySans-VariableFont_wght.ttf", 16)
end


function love.keyreleased(key)
    if key == "space" then
        -- Will update key_released table for key pressed
        love.keyboard.key_released[key] = true
        -- Play sound
        sounds.mlem:play()
    --[[ TESTING PURPOSES -> Player is taken back to fishing mode
    elseif key == "b" then 
        backToFishing = true
        lure.x = WINDOW_WIDTH / 2
        lure.y = lure.originalLurePosition
        ]]
    else
        print("Ignoring key press: ", key)
    end
end

-- Checks whether a specific key was released by querying the love.keyboard.key_released table
function love.keyboard.wasReleased(key)
    -- Will update key_released table for key pressed
    return love.keyboard.key_released[key] or false
end

-- Switch between states
function change_state(newState)
    print("Changing state to:", newState)
    current_state = newState
    -- Check if the new state has a load function (instead of calling immediately)
    if current_state.load then
        current_state.load()
    end
    
    return current_state
end

-- Check the #number of caught creatures to then transition into different endings
function checkEnding()
    sounds.inGameMusic:stop()

    local totalCreatures = 0 -- Total number of creature types calculated using loop as this is a table (key-value pairs) NOT an array
    for _ in pairs(fishImages.creatures) do 
        totalCreatures = totalCreatures + 1 
    end

    local caughtCreature_count = #caughtCreatures
    if caughtCreature_count <= 0 then
        -- Ending #1: Player caught no fish || Will generate lined rectangle (for now)
        print("Ending #1 triggered")
        change_state(ending1)
    elseif caughtCreature_count > 0 and caughtCreature_count < totalCreatures then
        -- Ending #2: Player caught some fish || Will generate lined circle (for now)
        print("Ending #2 triggered")
        change_state(ending2)
    elseif caughtCreature_count == totalCreatures then
        -- Ending #3: Player caught all fish || Will generate filled circle (for now)
        print("Ending #3 triggered")
        change_state(ending3)
    end
end

function running.update(dt) -- dt = delta time
    -- PLAYER animation
    player.anim:update(dt)
    fishImages.animations.displayNormal:update(dt)
    fishImages.animations.displayGlitch:update(dt)
    lure.anim:update(dt)

    -- PLAYER is 'quiet' || This reverts FINN when player goes back to fishing
    player.anim = player.animations.quiet

    -- For TUTORIAL
    tutorialTimer = tutorialTimer + dt -- Update tutorial timer

    -- Check if the TUTORIAL duration has elapsed
    if tutorialTimer >= tutorialDuration then
        -- Removes TUTORIAL text
        tutorialTextOn = false
    end

    if love.keyboard.isDown("space") and backToFishing and not lureBeingPulled then 
        -- PLAYER is 'snagged'
        player.anim = player.animations.snagged
        lure.anim = lure.animations.snagged

        -- LURE moving back-and-forth along x-axis
        lure.x = lure.x + (lure.x_speed * lure.x_direction)

        if lure.x <= 0 or lure.x >= WINDOW_WIDTH then -- This means the GAP per creature is 140pixels
            lure.x_direction = lure.x_direction * -1
        end 
    end

    if love.keyboard.wasReleased("space") and backToFishing then
        -- PLAYER is pulling ('pulled')     
        player.anim = player.animations.pulled
        lure.anim = lure.animations.pulled
               
        -- LURE being pulled
        if lure.y + (lure.y_speed * lure.y_direction) < -600 then -- Setting how far up the lure needs to be pulled
            lure.y = -600
            lureBeingPulled = true
            backToFishing = false
            newCreature = generateFish(lure.x)
            
            -- Check if creature already caught in caughtCreatures table
            local alreadyCaught = false
            for _, creature in ipairs(caughtCreatures) do
                if creature == newCreature then
                    alreadyCaught = true
                    break
                end
            end

            -- Adds to caughtCreatures table if not caught yet
            if not alreadyCaught then
                table.insert(caughtCreatures, newCreature) 
            end

            -- Start the display timer when a creature is caught
            creatureDisplayTimer = creatureDisplayDuration  
            isTimerRunning = true

        else
            lure.y = lure.y + (lure.y_speed * lure.y_direction)
        end
    end 
    
    -- Reverting *some* values back to fish
    if not backToFishing then
        lureBeingPulled = false
        love.keyboard.key_released = {} -- To clear keysReleased table !!! Causes the lure to not reach -80y-axis
    end

    -- Update the creature display timer if a creature is being displayed
    if isTimerRunning then
        -- PLAYER is *still* 'pulled'     
        player.anim = player.animations.pulled
        creatureDisplayTimer = creatureDisplayTimer - dt

        -- Revert back to fishing mode
        if creatureDisplayTimer <= 0 then
            newCreature = nil -- Clear the displayed creature after the timer expires
            backToFishing = true
            lure.x = WINDOW_WIDTH / 2
            lure.y = lure.originalLurePosition
            isTimerRunning = false -- Reset the timer (isTimerRunning)
        end
    end

    -- Update game timer
    if gameOver == false then
        gameTimeRemaining = gameTimeRemaining - dt
    end

    if gameTimeRemaining <= 0 then
        gameOver = true
        if gameOver then
        -- Time's up, transitioning to different ending gamestates depending on results
        checkEnding()
        end
    end
end

-- Returns creature caught depending on where along x-axis lure is pulled 
function generateFish(lure_xPosition)
    if lure_xPosition <= 40 then
        return fishImages.creatures.crab2
    elseif lure_xPosition > 40 and lure_xPosition <= 160 then
        return fishImages.creatures.crab1
    elseif lure_xPosition > 160 and lure_xPosition <= 200 then
        return fishImages.creatures.fish2
    elseif lure_xPosition > 200 and lure_xPosition <= 320 then
        return fishImages.creatures.fish1
    elseif lure_xPosition > 320 and lure_xPosition <= 360 then
        return fishImages.creatures.jelly2
    elseif lure_xPosition > 360 and lure_xPosition <= 480 then
        return fishImages.creatures.jelly1
    elseif lure_xPosition > 480 and lure_xPosition <= 520 then
        return fishImages.creatures.shark2
    else
        return fishImages.creatures.shark1
    end
end
 
function running.draw()
    -- BACKGROUND Part1-3:
    love.graphics.draw(backgroundImages.sky, 0, 0, 0, scale_x, scale_y)

    -- SUN (timer):
    -- Countdown timer
    love.graphics.print("Time left: " .. math.ceil(gameTimeRemaining), 10, 10)
    -- Draw the sun based on the remaining time
    local sunY = ((WINDOW_HEIGHT / 2) + 32) * (1 - gameTimeRemaining / gameTime) -- '+ 32' to ensure sun.png disappears from horizon
    -- love.graphics.draw(sunImage, WINDOW_WIDTH / 2 - sunImage:getWidth() / 2, sunY, nil, 1.5)
    love.graphics.draw(sunImage, WINDOW_WIDTH / 2, sunY, nil, 1, 1, sunImage:getWidth() / 2, sunImage:getHeight() / 2)

    -- BACKGROUND Part2-3:
    love.graphics.draw(backgroundImages.cliff, 0, 0, 0, scale_x, scale_y)

    -- PLAYER:
    if not lureBeingPulled then
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 4)
    end

    -- Set font
    love.graphics.setFont(myFont)

    -- Display TUTORIAL
    if tutorialTextOn then
        love.graphics.print("Hold down the SPACEBAR, \nand when you are ready.. \nrelease it!", ((WINDOW_WIDTH * 1.75) / 3), 20)
    end

    -- LURE:
    if not lureBeingPulled then
        lure.anim:draw(lure.spriteSheet, lure.x, lure.y, nil, 2, 2, lure.grid.frameWidth / 2)
    end

    -- BACKGROUND Part3-3:
    love.graphics.draw(backgroundImages.guide, 0, 0, 0, scale_x, scale_y)

    -- FISH:
    -- Display the caught creature temporarily
    if newCreature then
        if newCreature == fishImages.creatures.crab2 or newCreature == fishImages.creatures.fish2 or newCreature == fishImages.creatures.jelly2 or newCreature == fishImages.creatures.shark2 then
            love.graphics.draw(fishImages.glitch, 0, 0, 0, scale_x, scale_y)
            fishImages.animations.displayGlitch:draw(fishImages.spriteSheetGlitch, WINDOW_WIDTH / 2 - (fishImages.gridGlitch.frameWidth * 6) / 2, WINDOW_HEIGHT / 2 - (fishImages.gridGlitch.frameHeight * 6) / 2, nil, 6, 6)
        else
            fishImages.animations.displayNormal:draw(fishImages.spriteSheetNormal, WINDOW_WIDTH / 2 - (fishImages.gridNormal.frameWidth * 6) / 2, WINDOW_HEIGHT / 2 - (fishImages.gridNormal.frameHeight * 6) / 2, nil, 6, 6)
        end
        
        love.graphics.draw(newCreature, WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 0, 6, 6, newCreature:getWidth() / 2, newCreature:getHeight() / 2)

        --[[ *DISABLED* Display a countdown timer on the screen 
        love.graphics.print("Display timer: " .. math.ceil(creatureDisplayTimer), (WINDOW_WIDTH * .85) / 2, (WINDOW_HEIGHT * 9) / 10)
        ]]
    end

    -- Display the caught creatures permanently
    local creatureSize = 40  -- Adjusts the size of displayed creatures
    local spacing = 15       -- Adjusts the vertical spacing between creatures
    local startX = WINDOW_WIDTH - creatureSize - 30  -- Adjusts the starting X position

    for i, creatureImage in ipairs(caughtCreatures) do
        local yPosition = (i - 1) * (creatureSize + spacing) + 20  -- Adjusts the spacing and starting position
        love.graphics.draw(creatureImage, startX, yPosition, nil, 1, 1)
    end
end

return running