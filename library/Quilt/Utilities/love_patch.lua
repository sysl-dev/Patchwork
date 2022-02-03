local m = {
  __NAME        = "QU-LOVE-Patch",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Patches the 'love' global library table with more functions",
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
m.debug = false
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

-- Get the base width and height of the window before we resize it later.
local base = {width = BASE_WIDTH or love.graphics.getWidth(), height = BASE_HEIGHT or love.graphics.getHeight()}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Global Settings to Load
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.functions_list = {
  "lg-resetcolor",
  "lg-background",
  "lg-outlinePrint",
  "lg-outlinePrintf",

}



--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Store into a table for easy on/off
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.functions_code = {
  -- Provides an easy reset point to solid white #FFFFFF
  ["lg-resetcolor"] = function()
    function love.graphics.resetColor()
      love.graphics.setColor(1,1,1,1)
    end
    print("love.graphics.resetColor: enabled")
  end,

  -- Draw a full screen sized square
  ["lg-background"] = function()
    -- Local copy of base into the function
    local base = base
    function love.graphics.background(padding, settings)
      padding = padding or 0
      settings = settings or {}
      assert(type(padding) == "number", "Padding should be a number.")
      -- If we are not working from the base window size in a scaled canvas, allow full screen
      if settings.not_pixel then 
        base = {width = love.graphics.getWidth(), height = love.graphics.getHeight()}
      end
      love.graphics.rectangle("fill", 0 - padding, 0 - padding, base.width + padding * 2, base.height + padding * 2)
    end
    print("love.graphics.background: enabled")
  end,

  -- Print with an outline
  ["lg-outlinePrint"] = function()
    function love.graphics.outlinePrint(settings, ...)
      settings = settings or {}
      local temp_color = {love.graphics.getColor()}
      local color = settings.color or temp_color
      local color2 = settings.color2 or  {math.abs(color[1] - 1), math.abs(color[2] - 1), math.abs(color[3] - 1), 1}
      local text,x,y,r,sx,sy,ox,oy,kx,ky = ...
      x = x or 0
      y = y or 0
      love.graphics.setColor(color2)
      if settings.thick then 
        love.graphics.print(text,x+1,y+1,r,sx,sy,ox,oy,kx,ky)
        love.graphics.print(text,x-1,y-1,r,sx,sy,ox,oy,kx,ky)
        love.graphics.print(text,x-1,y+1,r,sx,sy,ox,oy,kx,ky)
        love.graphics.print(text,x+1,y-1,r,sx,sy,ox,oy,kx,ky)
      end
      love.graphics.print(text,x+1,y,r,sx,sy,ox,oy,kx,ky)
      love.graphics.print(text,x-1,y,r,sx,sy,ox,oy,kx,ky)
      love.graphics.print(text,x,y+1,r,sx,sy,ox,oy,kx,ky)
      love.graphics.print(text,x,y-1,r,sx,sy,ox,oy,kx,ky)
      love.graphics.setColor(color)
      love.graphics.print(text,x,y,r,sx,sy,ox,oy,kx,ky)
      love.graphics.setColor(temp_color)
    end
    print("love.graphics.background: enabled")
  end,

  -- Print with an outline formatted
  ["lg-outlinePrintf"] = function()
    function love.graphics.outlinePrintf(settings, ...)
      settings = settings or {}
      local temp_color = {love.graphics.getColor()}
      local color = settings.color or temp_color
      local color2 = settings.color2 or  {math.abs(color[1] - 1), math.abs(color[2] - 1), math.abs(color[3] - 1), 1}
      local text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky = ...
      x = x or 0
      y = y or 0
      love.graphics.setColor(color2)
      if settings.thick then 
        love.graphics.printf(text,x+1,y+1,limit,align,r,sx,sy,ox,oy,kx,ky)
        love.graphics.printf(text,x-1,y-1,limit,align,r,sx,sy,ox,oy,kx,ky)
        love.graphics.printf(text,x-1,y+1,limit,align,r,sx,sy,ox,oy,kx,ky)
        love.graphics.printf(text,x+1,y-1,limit,align,r,sx,sy,ox,oy,kx,ky)
      end
      love.graphics.printf(text,x+1,y,limit,align,r,sx,sy,ox,oy,kx,ky)
      love.graphics.printf(text,x-1,y,limit,align,r,sx,sy,ox,oy,kx,ky)
      love.graphics.printf(text,x,y+1,limit,align,r,sx,sy,ox,oy,kx,ky)
      love.graphics.printf(text,x,y-1,limit,align,r,sx,sy,ox,oy,kx,ky)
      love.graphics.setColor(color)
      love.graphics.printf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky)
      love.graphics.setColor(temp_color)
    end
    print("love.graphics.background: enabled")
  end,

}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Tinker with global settings
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(settings)

  -- Set reasonable defaults if none are supplied 
  settings = settings or {}

  -- If required, only apply certain items
  local functions_to_apply = settings.apply or m.functions_list

  -- If required, remove items from being applied.
  if settings.remove then 
    for x=1, #settings.remove do
      for i=1, #functions_to_apply do
        if functions_to_apply[i] == settings.remove[x] then
          table.remove(functions_to_apply,i)
        end
      end
    end
  end

  -- Apply settings
  for i=1, #functions_to_apply do
    m.functions_code[functions_to_apply[i]]()
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m