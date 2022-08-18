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
love.gfx = {}
-- Get the base width and height of the window before we resize it later.
local base = {width = BASE_WIDTH or love.graphics.getWidth(), height = BASE_HEIGHT or love.graphics.getHeight()}
local tablename = nil
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Internal Shaders
--------------------------------------------------------------------------------------------------------------------------------------------------]]--


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(settings)
  -- If you allow this to run, it will import everything.
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Reset Background Color 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.resetColor()
  love.graphics.setColor(1,1,1,1)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Reset Blend Mode
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.resetBlendMode()
  love.graphics.setBlendMode("alpha", "alphamultiply")
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Set the color, under my control.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.setColor(...)
  local first_color_number = ...
  if type(first_color_number) == "nil" then love.gfx.resetColor() return end
  love.graphics.setColor(...)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw Background
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.background(padding)
  padding = padding or 0
  assert(type(padding) == "number", "Padding should be a number.")
  love.graphics.rectangle("fill", 0 - padding, 0 - padding, base.width + padding * 2, base.height + padding * 2)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Print Outlined Text
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.outlinePrint(settings, ...)
  settings = settings or {}
  local temp_color = {love.graphics.getColor()}
  local text_color = settings.color or temp_color
  local outline_color = settings.color2 or  {math.abs(text_color[1] - 1), math.abs(text_color[2] - 1), math.abs(text_color[3] - 1), 1}
  local text,x,y,r,sx,sy,ox,oy,kx,ky = ...
  x = x or 0
  y = y or 0
  love.graphics.setColor(outline_color)
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
  love.graphics.setColor(text_color)
  love.graphics.print(text,x,y,r,sx,sy,ox,oy,kx,ky)
  love.graphics.setColor(temp_color)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Printf Outlined Text
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.outlinePrintf(settings, ...)
  settings = settings or {}
  local temp_color = {love.graphics.getColor()}
  local text_color = settings.color or temp_color
  local outline_color = settings.color2 or  {math.abs(text_color[1] - 1), math.abs(text_color[2] - 1), math.abs(text_color[3] - 1), 1}
  local text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky = ...
  x = x or 0
  y = y or 0
  love.graphics.setColor(outline_color)
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
  love.graphics.setColor(text_color)
  love.graphics.printf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky)
  love.graphics.setColor(temp_color)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Gradient Rectangle
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.Grectangle(x, y, w, h, color1, color2)
  color1 = color1 or love.graphics.getColor()
  color2 = color2 or love.graphics.getColor()
  local curshader = love.graphics.getShader()

  love.graphics.setShader(curshader)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Gradient Disk  
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.disk(x, y, r, startangle, endangle, color1, color2)
  color1 = color1 or love.graphics.getColor()
  color2 = color2 or love.graphics.getColor()
  local curshader = love.graphics.getShader()

  love.graphics.setShader(curshader)
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m