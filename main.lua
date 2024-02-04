push = require 'push'

class = require 'class'

require('Paddle')

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

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
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    push:apply('start')
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- love.graphics.rectangle(drawMode, screenX, screenY, rectangleX, rectangleY)
    left_paddle = Paddle(10, 30, 5, 20)
    right_paddle = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    left_paddle:render()
    right_paddle:render()

    push:apply('end')
end