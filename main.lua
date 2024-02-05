---@diagnostic disable: 111
push = require 'push'

class = require 'class'

require('Paddle')

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function  love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallfont = love.graphics.newFont('/font/font.ttf', 8)
    love.graphics.setFont(smallfont)

    love.graphics.setBackgroundColor(0, 0, 0)
    push:setupScreen(
        VIRTUAL_WIDTH, 
        VIRTUAL_HEIGHT, 
        WINDOW_WIDTH, 
        WINDOW_HEIGHT, 
        {
            fullscreen = false,
            resizable = false,
            vsync = true
        })

    -- love.graphics.rectangle(drawMode, screenX, screenY, rectangleX, rectangleY)
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end


function love.draw()
    push:start()
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    player1:render()
    player2:render()

    push:finish()
end

function love.update(dt)

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

    player1:update(dt)
    player2:update(dt)
end
