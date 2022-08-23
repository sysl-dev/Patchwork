local m = {
  __NAME = "Quilt-Mouse",
  __VERSION = "4.0",
  __AUTHOR = "C. Hall (Sysl)",
  __DESCRIPTION = "Graphical Cursor and Mouse Function",
  __URL = "http://github.sysl.dev/",
  __LICENSE = [[
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
  __LICENSE_TITLE = "MIT LICENSE",
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Debug Mode
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
m.debug = false
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Locals and Housekeeping
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
local print = print
local debugprint = print
local function print(...)
  if m.debug then
    debugprint(m.__NAME .. ": ", unpack({
      ...,
    }))
  end
end
print(m.__DESCRIPTION)

local base = {
  width = BASE_WIDTH or love.graphics.getWidth(),
  height = BASE_HEIGHT or love.graphics.getHeight(),
}

m.quad = {}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup (if Required)
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.setup(settings)
  -- Set reasonable defaults if none are supplied.
  settings = settings or {}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Functions
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.create(name, imgw, imgh)
  m.quad[name] = love.graphics.newQuad(0, 0, base.width * 2, base.height * 2, imgw, imgh or imgw)
end

-- clamp, clampzero, repeat, mirroredrepeat
function m.set_repeat(img, mode, mode2)
  mode2 = mode2 or mode
  img:setWrap(mode, mode2)
end

function m.delete(name) m.quad[name] = nil end

function m.draw(img, name, x, y, r, sx, sy, ox, oy, kx, ky)
  love.graphics.draw(img, m.quad[name], x, y, r, sx, sy, ox, oy, kx, ky)
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
return m
