local m = {
  __NAME        = "Quilt-Kit-Camera",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Camera to help cheat smooth scrolling in pixel games.",
  __URL         = "http://github.sysl.dev/",
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2022 Chris / Systemlogoff

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]],
  __LICENSE_TITLE = "MIT LICENSE"
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Debug Mode
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.debug = true
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Locals and Housekeeping
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local print = print
local debugprint = print
local function print(...)
  if m.debug then
    debugprint(m.__NAME .. ": ", unpack({...}))
  end
end print(m.__DESCRIPTION)

-- Not 100% accurate on deep floats, but close enough.
local function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

-- Camera Settings // What is currently being used.
m.current = {
  x = 0,
  y = 0,
  w = BASE_WIDTH or love.graphics.getWidth(),
  h = BASE_HEIGHT or love.graphics.getHeight(),
  smoothstep = false,
  smoothstepx = 0,
  smoothstepy = 0,
  zoom = 1,
}

-- Set up the defaults
function m.setup(config)
  config = config or {}
  m.current.x = config.x or m.current.x 
  m.current.y = config.y or m.current.y 
end

-- Start capturing the location sent, supply the smoothstep.
function m.record(x, y)
  if type(x) =="table" then 
    x = x.x
    y = x.y
  end
  if type(x) == "number" then 
    if type(y) == "nil" then 
      y = x
    end
  end
  love.graphics.push("all")
  m.current.smoothstepx = x - math.floor(x)
  m.current.smoothstepy = y - math.floor(y)
  love.graphics.scale(m.current.zoom)
  local finalx = -math.floor(x) + m.current.w/2
  local finaly = -math.floor(y) + m.current.h/2
  finalx = finalx - (m.current.w/m.current.zoom * (m.current.zoom-1))/2
  finaly = finaly - (m.current.h/m.current.zoom * (m.current.zoom-1))/2

  love.graphics.translate(finalx, finaly)
end

-- Return graphics to normal.
function m.stop_record()
  love.graphics.pop()
end

-- Return the smoothstep.
function m.get_smoothstep()
  if m.current.smoothstep then 
    return m.current.smoothstepx, m.current.smoothstepy
  else
    return 0, 0
  end
end

function m.get_smoothstep_x()
  if m.current.smoothstep then 
    return -1 * m.current.smoothstepx
  else
    return 0
  end
end

function m.get_smoothstep_y()
  if m.current.smoothstep then 
    return -1 * m.current.smoothstepy
  else
    return 0
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m