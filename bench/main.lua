local LC = require("LoveCoroutine")()

local status = "init"

local count = 1000

local internal = 1000

local deltaCount = 0
local deltaSum = 0
local deltaMin = 10000
local deltaMax = 0

function love.update(dt)
    if status == "run" then
        deltaMin = math.min(dt, deltaMin)
        deltaMax = math.max(dt, deltaMax)
        deltaCount = deltaCount + 1
        deltaSum = deltaSum + dt
        LC:update(dt)
    end
end

function love.draw()
    if status == "init" then
        love.graphics.print("TOTAL " .. count, 100, 100)
        love.graphics.print("INTERNAL " .. internal, 100, 150)
        love.graphics.print("Use left and right to change INTERNAL", 100, 200)
        love.graphics.print("Use up and down to change TOTAL", 100, 250)
    elseif status == "run" then
    elseif status == "finish" then
        love.graphics.print(string.format("FPS: avg %.2f, max %.2f, min %.2f", 
                1 / (deltaSum / deltaCount), 1 / deltaMin, 1 / deltaMax),
            100, 100)
    end 
end

local function testFunc()
    while true do
        LC:waitNextFrame()
    end
end

local function startTest()
    for i = 1, count do
        LC:run(testFunc)
    end
end

function love.keypressed(key)
    if status == "init" then
        if key == "down" then
            count = count + internal
        elseif key == "up" then
            count = math.max(count - internal, 0)
        elseif key == "left"  then
            internal = math.max(internal / 10, 1)
        elseif key == "right" then
            internal = internal * 10
        elseif key == "return" then
            status = "run"
            startTest()
        end
    elseif status == "run" then
        if key == "return" then
            status = "finish"
            LC:clear()
        end
    elseif status == "finish" then
        if key == "return" then
            love.event.quit()
        end
    end
end