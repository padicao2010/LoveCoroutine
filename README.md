# LoveCoroutine

A simple tool based on coroutine for LÖVE. LoveCoroutine targets at implement a serial of actions in a easier way.

## Target

LoveCoroutine provides a more straightforward and human-readable way to implement a serial of actions in game.

For example, object A will go down 3s, then right 2s, then down 1s.

We can implement it with [hump.timer](http://hump.readthedocs.org/en/latest/timer.html):

```lua
local Timer = require "hump.timer"
function love.update(dt)
    A:moveDown()
    Timer.after(3, function()
            A:moveRight()
            Timer.after(2, function()
                A:moveDown()
                Timer.after(1, function()
                    -- Other actions
                end)
            end)
        end)
end
```

With LoveCoroutine:

```lua
local LC = require("LoveCoroutine")()
LC:run(function()
        A:moveDown()
        LC:waitTime(3)
        A:moveRight()
        LC:waitTime(2)
        A:moveDown()
        LC:waitTime(1)
        -- Other actions
    end)
    
function love.update(dt)
    LC:update(dt)
end
```

## Sadness

Although it looks nice, LoveCoroutine makes more overhead. Following is the result of a benchmark.

Number of coroutines | cpu | memory | avgFPS | maxFPS | minFPS
-------------------- | --- | ------ | ------ | ------ | ------
0                    |  0  |   53   |    653 |   875  |   396 
1000                 |  2  |   53   |    619 |   741  |   338 
10000                | 19  |   57   |    245 |   286  |   141 
100000               | 28  |   97   |    35  |    36  |    12 

Also, coroutine is the standard library in lua, but not in LÖVE.

## Dependencies

* middlebox. (However, it is easy to remove such dependency)

## API

### Used in the main routine

initialize:

```lua
LC = require("LoveCoroutine")
local lc = LC()
```

run a serial of actions:

```lua
-- func consumes the extra parameters, return the task
local co = lc.run(func, ...)
```

make it work, **LoveCoroutine.update is recommended to be put in the beginning of love.update**:

```lua
function love.update(dt)
    lc:update(dt)
end
```

clean all tasks:

```lua
lc:clean()
```

pause or stop a task, return a state for resume. If it return nil, it means LoveCoroutine cannot find the specific task:

```lua
local state = lc:stop(co)
```

resume a paused task. It return true if succeed, and nil means LoveCoroutine cannot resume the task, maybe because the task is done, or the state is unrecognized:

```lua
lc:resume(co, state)
```

### Used in the subroutine

Following functions can only be used in the function provided to LoveRoutine:run.

Wait until next frame, return the time between the last two frames, always provided by love.update:

```lua
local dt = lc:waitNextFrame()
```

Wait multiple seconds, return the deviation, not less than 0:

```lua
local deviation = lc:waitTime(seconds)
```

Wait for signal, returns arguments attached with the signal:

```lua
LC:waitSignal(signal)
```

Send Signal, can attach some arguments. **LoveCoroutine.sendSignal can also be put in the main routine**:

```lua
LC:sendSignal(signal, ...)
```

## Some restrictions

LoveCoroutine makes some restrictions. LoveCoroutine.update requires to be put in the beginning of the love.udpate, 
in order to make sure that all waitNextFrame will be waken up in next frame, 
all waitTime will be waken up in the specific time, all tasks waiting for a signal will be waken up by that signal.

In one frame, if a task call waitNextFrame before LoveCoroutine, the task will be waken up in the same frame.

For signal, one signal will wakes up all tasks in the same frame, no matter call waitSignal before or after the sending time.

That means, the following code will go into a death cycle:

```lua
LC:run(function()
    while true do
        LC:waitSignal("a")
        text = text .. "a"
    end
end)
LC:sendSignal("a")
```

It should be like this:

```lua
LC:run(function()
    while true do
        LC:waitSignal("a")
        text = text .. "a"
        LC:waitNextFrame()
    end
end)
LC:sendSignal("a")
```

## Next step

* Fix BUG if found
* So much `while true do ... end` is ugly. It can be improved, but I have no idea right now.

## License

The MIT License (MIT)