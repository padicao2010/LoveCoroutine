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
local lc = require("LoveCoroutine")()
lc:run(function()
        A:moveDown()
        lc:waitTime(3)
        A:moveRight()
        lc:waitTime(2)
        A:moveDown()
        lc:waitTime(1)
        -- Other actions
    end)
    
function love.update(dt)
    lc:update(dt)
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


## API

### Used in the main routine

Initialize:

```lua
LoveCoroutine = require("LoveCoroutine")
local lc = LoveCoroutine()
```

Run a serial of actions:

```lua
-- func consumes all the extra parameters, return the task
local co = lc:run(func, ...)
```

Make it work in love.update (**LoveCoroutine.update is recommended to be put in the beginning of love.update**):

```lua
function love.update(dt)
    lc:update(dt)
end
```

Clean all tasks:

```lua
lc:clean()
```

Pause or stop a task, return a state for resume. If it returns nil, it means LoveCoroutine cannot find the specific task:

```lua
local state = lc:stop(co)
```

Resume a paused task. It returns true if succeed, and nil means LoveCoroutine cannot resume the task, maybe because the task is done, or the state is unrecognized:

```lua
lc:resume(co, state)
```

### Used in the subroutine

Following APIs can only be used in the function provided to LoveRoutine:run.

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
lc:waitSignal(signal)
```

Send Signal, can attach some arguments. (**LoveCoroutine.sendSignal can also be put in the main routine**):

```lua
lc:sendSignal(signal, ...)
```

## Some restrictions

LoveCoroutine makes some restrictions. LoveCoroutine.update requires to be put in the beginning of the love.udpate, 
in order to make sure that all waitNextFrame will be waken up in next frame, 
all waitTime will be waken up in the specific time, all tasks waiting for a signal will be waken up by that signal.

In one frame, if a task call waitNextFrame before LoveCoroutine.update, the task will be waken up in the same frame.
If a task call waitTime before LoveCoroutine.update, the task will skil one frame.

For signal, one signal will wake up all tasks in the same frame, no matter they call waitSignal before or after the sending time.

That means, the following code will go into a death cycle:

```lua
lc:run(function()
    while true do
        lc:waitSignal("a")
        text = text .. "a"
    end
end)
lc:sendSignal("a")
```

It should be fixed like this:

```lua
lc:run(function()
    while true do
        lc:waitSignal("a")
        text = text .. "a"
        lc:waitNextFrame()
    end
end)
lc:sendSignal("a")
```

## Next step

* Fix BUG if found
* So much `while true do ... end` is ugly. It can be improved, but I have no idea right now.

## License

The MIT License (MIT)