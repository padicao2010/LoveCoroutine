local text = "Hello, World!"
local x, y = 300, 300
local vx, vy = 0, 0
local size = 20

local increaseTask, decreaseTask, regularTask, runTask
local incTaskState, decTaskState, regTaskState, runTaskState

local LC = require("LoveCoroutine")()

function love.load()
    --love.keyboard.setKeyRepeat(true)
    LC:run(function()
            while true do
                love.window.setTitle("" .. love.timer.getFPS())
                LC:waitTime(1)
            end
        end)
    increaseTask = LC:run(function()
            while true do
                LC:waitSignal("increase")
                size = size + 10
                LC:waitNextFrame()
            end
        end)
    decreaseTask = LC:run(function()
            while true do
                LC:waitSignal("decrease")
                size = math.max(size - 10, 10)
                LC:waitNextFrame()
            end
        end)
    regularTask = LC:run(function()
            while true do
                vx = vx + 40
                LC:waitTime(1)
                vx = vx - 40
                LC:waitTime(0.5)
                vx = vx - 40
                LC:waitTime(1)
                vx = vx + 40
                LC:waitTime(0.5)
            end
        end)
    runTask = LC:run(function()
            while true do
                local dt = LC:waitNextFrame()
                x = x + vx * dt
                y = y + vy * dt
            end
        end)
end

function love.update(dt)
    LC:update(dt)
end

function love.draw()
    love.graphics.print("left, right, up, down : move ball in 1s", 100, 100)
    love.graphics.print("space : move ball in a circle", 100, 125)
    love.graphics.print("return : reset", 100, 150)
    love.graphics.print("home, end : scale ball", 100, 175)
    love.graphics.print("a : enable/disable scale and normal move", 100, 200)
    love.graphics.print("b : enable/disable move", 100, 225)
    love.graphics.circle("fill", x, y, size)
    --love.graphics.print(text, math.floor(x), math.floor(y))
end

function love.keypressed(key)
    if key == "down" then
        LC:run(function()
                vy = vy + 40
                LC:waitTime(1)
                vy = vy - 40
            end)
    elseif key == "up" then
        LC:run(function()
                vy = vy - 40
                LC:waitTime(1)
                vy = vy + 40
            end)
    elseif key == "left" then
        LC:run(function()
                vx = vx - 40
                LC:waitTime(1)
                vx = vx + 40
            end)
    elseif key == "right" then
        LC:run(function()
                vx = vx + 40
                LC:waitTime(1)
                vx = vx - 40
            end)
    elseif key == "return" then
        LC:clear()
        x, y, vx, vy = 300, 300, 0, 0
    elseif key == "space" then
        LC:run(function()
                local v = 2 * math.pi * 100 / 5 / 100
                local centerx, centery = x, y + 100
                local go = 0
                local lastvx, lastvy = 0, 0
                while go < 5 do
                    local dt = LC:waitNextFrame()
                    local dx, dy = x - centerx, y - centery
                    local dist = math.sqrt(dx * dx + dy * dy)
                    go = go + dt
                    local cvx, cvy = v * dy, - v * dx
                    vx = vx - lastvx + cvx
                    vy = vy - lastvy + cvy
                    lastvx, lastvy = cvx, cvy
                end
                vx = vx - lastvx
                vy = vy - lastvy
            end)
    elseif key == "home" then
        print("HOME")
        LC:run(function()
            LC:sendSignal("increase")
        end)
    elseif key == "end"  then
        LC:sendSignal("decrease")
    elseif key == "a" then
        if not incTaskState then
            incTaskState = LC:stop(increaseTask)
            decTaskState = LC:stop(decreaseTask)
            regTaskState = LC:stop(regularTask)
        else
            LC:resume(increaseTask, incTaskState)
            LC:resume(decreaseTask, decTaskState)
            LC:resume(regularTask, regTaskState)
            incTaskState = nil
            decTaskState = nil
            regTaskState = nil
        end
    elseif key == "b" then
        if not runTaskState then
            runTaskState = LC:stop(runTask)
        else
            LC:resume(runTask, runTaskState)
            runTaskState = nil
        end
    end
end