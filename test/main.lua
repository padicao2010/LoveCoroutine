local text = "Hello, World!"
local x, y = 300, 300
local vx, vy = 0, 0

local LC = require("LoveCoroutine")()

function love.load()
    --love.keyboard.setKeyRepeat(true)
    LC:run(function()
            while true do
                love.window.setTitle("" .. love.timer.getFPS())
                LC:waitTime(1)
            end
        end)
end

function love.update(dt)
    LC:update(dt)
    x = x + vx * dt
    y = y + vy * dt
end

function love.draw()
    love.graphics.print("Use left, right, up down to move ball in 1s", 100, 100)
    love.graphics.print("Use space to move ball in a circle", 100, 150)
    love.graphics.print("Use return to reset", 100, 200)
    love.graphics.circle("fill", x, y, 20)
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
    end
end