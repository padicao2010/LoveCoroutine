local LC = {}
LC.__index = LC

setmetatable(LC, {
        __call = function(cls)
            return cls:new()
        end
})

function LC:new()
    local t = { 
        times = {}, 
        frames = {}, 
        signals = {}, 
        signaltasks = {}, 
        signaltasks2 = {} 
    }
    setmetatable(t, LC)
    return t
end

function LC:run(f, ...)
    local co = coroutine.create(f)
    coroutine.resume(co, ...)
    return co
end

function LC:update(dt)
    local frs = self.frames
    local tis = self.times
    self.frames = {}
    self.times = {}
    self.signals = {}
    
    for co, _ in pairs(frs) do
        coroutine.resume(co, dt)
    end
    
    for co, remain in pairs(tis) do
        remain = remain - dt
        if remain <= 0 then
            coroutine.resume(co, -remain)
        else
            self.times[co] = remain
        end
    end
end

function LC:stop(co)
    if self.times[co] then
        local remain = self.times[co]
        self.times[co] = nil
        return remain
    elseif self.frames[co] then
        self.frames[co] = nil
        return true
    else
        local signal = self.signaltasks2[co]
        self.signaltasks2[co] = nil
        self.signaltasks[signal][co] = nil
        return signal
    end
end

local function addSignalTask(tasks, s, co)
    local cos = tasks[s]
    if not cos then
        cos = {}
        tasks[s] = cos
    end
    cos[co] = true
end

function LC:resume(co, argu)
    if argu and coroutine.status(co) == "suspended" then
        if type(argu) == "boolean" then
            self.frames[co] = true
        elseif type(argu) == "number" then
            self.times[co] = argu
        else
            self.signaltasks2[co] = argu
            addSignalTask(self.signaltasks, argu, co)
        end
        return true
    end
end

function LC:clear()
    self.times = {}
    self.frames = {}
    self.signals = {}
    self.signaltasks = {}
    self.signaltasks2 = {}
end

-- used in subtask
-- paused until next update
-- return time delta
function LC:waitNextFrame()
    local co = coroutine.running()
    self.frames[co] = true
    return coroutine.yield()
end

-- used in sub task
-- paused a period of time t
-- return the deviation
function LC:waitTime(t)
    local co = coroutine.running()
    if t > 0 then
        self.times[co] = t
        return coroutine.yield()
    end
    return 0
end

function LC:sendSignal(s, ...)
    self.signals[s] = {...}
    while true do
        local ss = self.signaltasks[s]
        if not ss then
            break
        end
        
        self.signaltasks[s] = nil
        for co, _ in pairs(ss) do
            self.signaltasks2[co] = nil
            coroutine.resume(co, ...)
        end
    end
end

function LC:waitSignal(s)
    if self.signals[s] then
        return table.unpack(self.signals[s])
    end
    
    local co = coroutine.running()
    self.signaltasks2[co] = s
    addSignalTask(self.signaltasks, s, co)
    
    return coroutine.yield()
end

return LC
