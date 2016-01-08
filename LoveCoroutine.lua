local MC = require("middleclass")
local LC = MC("LoveCoroutine")

function LC:initialize()
    self.tasks = {}
end

function LC:run(f, ...)
    local co = coroutine.create(f)
    self.tasks[co] = true
    coroutine.resume(co, ...)
    return co
end

function LC:update(dt)
    for co, _ in pairs(self.tasks) do
        if coroutine.status(co) == "suspended" then
            coroutine.resume(co, dt)
        else
            self.tasks[co] = nil
        end
    end
end

function LC:stop(co)
    self.tasks[co] = nil
end

function LC:resume(co)
    if coroutine.status(co) == "suspended" then
        self.tasks[co] = true
        return true
    else
        return false
    end
end

function LC:clear()
    self.tasks = {}
end

-- used in subtask
-- paused until next update
-- return time delta
function LC:waitNextFrame()
    return coroutine.yield()
end

-- used in sub task
-- paused a period of time t
-- return the deviation
function LC:waitTime(t)
    while t > 0 do
        local dt = coroutine.yield()
        t = t - dt
    end
    return -t
end

return LC