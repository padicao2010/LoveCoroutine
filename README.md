# LoveCoroutine

A simple tool based on coroutine for LÖVE. LoveCoroutine targets at implement a serial of actions in a easier way.

## Target

LoveCoroutine provides a more straightforward and human-readable way to implement a serial of actions in game.

For example, object A will go down 3s, then right 2s, then down 1s.

We can implement it with [hump.timer](http://hump.readthedocs.org/en/latest/timer.html):

```
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

```
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

|| Number of coroutines || cpu || memory || avgFPS || maxFPS || minFPS ||
|| 0                    ||  0  ||   53   ||    653 ||   875  ||   396  ||
|| 1000                 ||  2  ||   53   ||    619 ||   741  ||   338  ||
|| 10000                || 19  ||   57   ||    245 ||   286  ||   141  ||
|| 100000               || 28  ||   97   ||    35  ||    36  ||    12  ||

Also, coroutine is the standard library in lua, but not in LÖVE.

## Dependencies

* middlebox. (However, it is easy to remove such dependency)

## API

### Used in the main routine

initialize:

```
LC = require("LoveCoroutine")
local lc = LC()
```

run a serial of actions:

```
-- func consumes the extra parameters, return the task
local co = lc.run(func, ...)
```

make it work:

```
lc:update(dt)
```

clean all tasks:

```
lc:clean()
```

pause or stop a task:

```
lc:stop(co)
```

resume a paused task:

```
lc:resume(co)
```

### Used in the subroutine

Following functions can only be used in the function provided to LoveRoutine:run.

Wait until next frame, return the time between the last two frames, always provided by love.update:

```
local dt = lc:waitNextFrame()
```

Wait multiple seconds, return the deviation, not less than 0:

```
local deviation = lc:waitTime(seconds)
```