push = require 'push'

class = require 'class'

require('Paddle')
require("Ball")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function  love.load()
    -- Screen setup
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setBackgroundColor(0, 0, 0)
    push:setupScreen(
        VIRTUAL_WIDTH,
        VIRTUAL_HEIGHT,
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        {
            fullscreen = false,
            resizable = false,
            vsync = true,
            canvas = false
        })

    love.window.setTitle("Pong")

    -- Random math seed, based on system time
    math.randomseed(os.time())

    -- Font
    smallfont = love.graphics.newFont('/font/font.ttf', 8)
    scorefont = love.graphics.newFont('/font/font.ttf', 16)
    largefont = love.graphics.newFont('/font/font.ttf', 32)
    love.graphics.setFont(smallfont)

    -- Sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    
    -- love.graphics.rectangle(drawMode, screenX, screenY, rectangleX, rectangleY)
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- Scoreboard
    player1Score = 0
    player2Score = 0

    -- Game Variables
    servingPlayer = 1
    winningPlayer = 0
    gameState = "start"

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' or key == 'space' then
        if gameState == "start" then
            gameState = "serve"

        elseif gameState == "serve" then
            gameState = "play"
        elseif gameState == "done" then
            gameState = "serve"
            ball:reset()

            -- Score reset
            player1Score = 0
            player2Score = 0

            -- Serving player is the one who lost
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end


function love.draw()
    push:start()
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if gameState == "start" then
        -- UI 
        love.graphics.setFont(smallfont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')

    elseif gameState == "serve" then
        -- UI
        love.graphics.setFont(smallfont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    
    -- Nothing to draw when the game is running 
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == "done" then
        -- UI
        love.graphics.setFont(largefont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallfont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    
    end

    displayScore()

    player1:render()
    player2:render()

    ball:render()

    displayFPS()

    push:finish()
end

function love.resize(w, h)
    push:resize(w, h)
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallfont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end

function displayScore()
    -- score display
    love.graphics.setFont(scorefont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function love.update(dt)

    -- Update based on the state of the game
    if gameState == "serve" then

        -- Init balls velocity
        ball.dy = math.random(-50, 50)

        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == "play" then

        -- Check for collisions with other players
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            
            -- Randomize velocity (not it's direction)
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds["paddle_hit"]:play();
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
    
            -- Randomize velocity (not it's direction)
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds["paddle_hit"]:play();
        end

        -- Check for collisions with the screen
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        
            sounds["wall_hit"]:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy

            sounds["wall_hit"]:play()
        end
        -- Left boundary
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1

            sounds["score"]:play();

            -- When a player scores 10 points, game over
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                -- Reset
                gameState = 'serve'
                ball:reset()
            end

        end

        -- Right boundary
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1

            sounds["score"]:play();
            
            -- When a player scores 10 points, game over
            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                -- Reset
                gameState = 'serve'
                ball:reset()
            end
        end
    end
    -- player 1 (left)
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 (right)
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
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
