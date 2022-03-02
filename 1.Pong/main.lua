-- Importing all required costants and files
require("./src/Dependencies")

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
	-- nearest neighbour filtering
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle("PongOPong")

	-- initialize our nice-looking retro text fonts
    gFonts = {
        ['small'] = love.graphics.newFont('assets/font.ttf', 8),
        ['medium'] = love.graphics.newFont('assets/font.ttf', 16),
        ['scoreFont'] = love.graphics.newFont('assets/font.ttf', 32)
    }

    --sounds
    sounds = {
        ["player_hit"] = love.audio.newSource("assets/sounds/player_hit.wav", "static"),
        ["score"] = love.audio.newSource("assets/sounds/score.wav", "static"),
        ["wall_hit"] = love.audio.newSource("assets/sounds/wall_hit.wav", "static"),
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
        resizable = true, -- if window should be resizable
        vsync = true
    })

    servingPlayer = 1

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

--[[
    Calles by LÖVE to resize; just give width and height to push for the virtual resolution
]]
function love.resize(w, h)
    push:resize(w, h)
end

-- Runs every frame, with "dt" passed in, our delta in seconds
function love.update(dt)
    if gameState == "serve" then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140,200)
        end
    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent    
    elseif gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            
            -- randomize velocity
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10,150)
            end

            sounds['player_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            
            -- randomize velocity
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10,150)
            end

            sounds['player_hit']:play()
        end
    
        --upper and lower bound screen boundary collision
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        --looking for the ball to update screen accordingly
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()
            -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end
        if ball.x > VIRTUAL_WIDTH then 
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        -- add negative paddle speed to current Y scaled by deltaTime
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        -- add positive paddle speed to current Y scaled by deltaTime
        player1.dy = PADDLE_SPEED
    else 
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        -- add negative paddle speed to current Y scaled by deltaTime
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        -- add positive paddle speed to current Y scaled by deltaTime
        player2.dy = PADDLE_SPEED
    else 
        player2.dy = 0
    end

	if gameState == "play" then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
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
            gameState = 'serve'
        elseif gameState == "serve" then
            gameState = "play"
        elseif gameState == "done" then
            -- game is in a restart phase
            gameState = 'serve'
            
            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else 
                servingPlayer = 1
            end
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

    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(gFonts.small)
        love.graphics.printf('Welcome to PongOPong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == "serve" then
        love.graphics.setFont(gFonts.small)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == "play" then
        -- no UI messages
    elseif gameState == "done" then
        love.graphics.setFont(gFonts.medium)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(gFonts.small)
        love.graphics.printf("Press Enter to restart!", 0, 30, VIRTUAL_WIDTH, "center")
    end
	
    -- render players and ball
    player1:render()
    player2:render()
    ball:render()
 
    displayFPS()

	-- end rendering at virtual resolution
	push:apply('end')
end

-- renders current FPS 
function displayFPS()
    love.graphics.setFont(gFonts["small"])
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

-- draws the score to the screen
function displayScore()
    love.graphics.setFont(gFonts.scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end