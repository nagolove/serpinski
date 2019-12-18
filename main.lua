local inspect = require "inspect"
local vector = require "vector"
local lg = love.graphics

function love.load()
end

function love.draw()
end

function love.update(dt)
end

function love.keypressed(_, key)
    if key == "escape" then
        love.event.quit()
    end
end
