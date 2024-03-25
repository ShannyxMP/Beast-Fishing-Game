local menu = {}

-- Declaring constants
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480

function menu.load(changeStateFunction, runningState) 
    -- Set title
    love.window.setTitle("Fishing Time")

    -- BACKGROUND setting
    love.graphics.setDefaultFilter("nearest", "nearest") -- If you scale up the dimensions, it doesn't blur

    -- Game dimensions
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    -- Load scene
    menuScene = love.graphics.newImage('sprites/menu.png')

    -- Save the change_state function from main.lua into variable
    menu.change_state = changeStateFunction

    menu.running = runningState

    -- Music/Ambience
    menuAmbience = love.audio.newSource("sounds/ocean-waves.mp3", "stream")

    menuAmbience:setVolume(0.10) 
    menuAmbience:setLooping(true)
    menuAmbience:play()

    -- Font
    myFont = love.graphics.newFont("Pixelify_Sans/PixelifySans-VariableFont_wght.ttf", 16)
end

function menu.update()
    if love.keyboard.isDown("return") then
        menuAmbience:stop()
        menu.change_state(menu.running)
    elseif love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function menu.draw()
    -- Set font
    love.graphics.setFont(myFont)
    
    -- Notify player of instructions (backup if menu.png does not load)
    love.graphics.print("Press ENTER to Play \n Press ESC to Quit", ((WINDOW_WIDTH * 1.5) / 3), 20)

    -- Display BACKGROUND image
    love.graphics.draw(menuScene, 0, 0, 0, scale_x, scale_y)
end

return menu