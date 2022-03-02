-- Importing all required costants and files
require("./src/Dependencies")

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
	-- nearest neighbour filtering
    love.graphics.setDefaultFilter('nearest', 'nearest')

	-- initialize our nice-looking retro text fonts
    gFonts = {
        ['small'] = love.graphics.newFont('assets/font.ttf', 8),
        ['medium'] = love.graphics.newFont('assets/font.ttf', 16),
        ['scoreFont'] = love.graphics.newFont('assets/font.ttf', 32)
    }
    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

	love.graphics.setFont(gFonts['small'])

	-- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions; replaces our love.window.setMode call
    -- from the last example
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = trues
    })

	-- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    player1 = Paddle(4, 50, 4, 24)
    player2 = Paddle(VIRTUAL_WIDTH - 8, VIRTUAL_HEIGHT - 74, 4, 24)

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	-- math.random returns a random value between the left and right number
    -- ballDX = math.random(2) == 1 and 100 or -100
    -- ballDY = math.random(-50, 50)

	gameState = 'start'
end

-- Runs every frame, with "dt" passed in, our delta in seconds
function love.update(dt)
    -- player 1 movement
    if love.keyboard.isDown('w') then
        -- add negative paddle speed to current Y scaled by deltaTime
        player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('s') then
        -- add positive paddle speed to current Y scaled by deltaTime
        player1Y = math.min(VIRTUAL_HEIGHT - 24, player1Y + PADDLE_SPEED * dt)
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        -- add negative paddle speed to current Y scaled by deltaTime
        player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down') then
        -- add positive paddle speed to current Y scaled by deltaTime
        player2Y = math.min(VIRTUAL_HEIGHT - 24, player2Y + PADDLE_SPEED * dt)
    end

	-- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end
end

--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
	-- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    -- if we press enter during the start state of the game, we'll go into play mode
    -- during play mode, the ball will move in a random direction
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'
            
            -- start ball's position in the middle of the screen
            ballX = VIRTUAL_WIDTH / 2 - 2
            ballY = VIRTUAL_HEIGHT / 2 - 2

            -- given ball's x and y velocity a random starting value
            -- the and/or pattern here is Lua's way of accomplishing a ternary operation
            -- in other programming languages like C
            ballDX = math.random(2) == 1 and 100 or -100
            ballDY = math.random(-50, 50) * 1.5
        end
    end
end

--[[
    Called after update, used to draw anything to the screen
]]
function love.draw()
	-- begin rendering at virtual resolution
	push:apply('start')

	-- clear the screen with a specific color
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

	-- draw different things based on the state of the game
    love.graphics.setFont(gFonts["small"])

    if gameState == 'start' then
        love.graphics.printf('Hello Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Hello Play State!', 0, 20, VIRTUAL_WIDTH, 'center')
    end

	-- condensed onto one line from last example
	-- note we are now using virtual width and height now for text placement
	-- love.graphics.printf('FongPong', 0, 20, VIRTUAL_WIDTH, 'center')

	-- render first paddle
	love.graphics.rectangle('fill', 4, player1Y, 4, 24)

	-- render second paddle
	love.graphics.rectangle('fill', VIRTUAL_WIDTH - 8, player2Y, 4, 24)
 
	-- render ball (center)
	love.graphics.rectangle('fill', ballX, ballY, 4, 4)
 
	-- end rendering at virtual resolution
	push:apply('end')
end
