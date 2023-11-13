local m = {
  __NAME = "QU-LOVE-Patch",
  __VERSION = "1.0",
  __AUTHOR = "C. Hall (Sysl)",
  __DESCRIPTION = "Patches the 'love' global library table with more functions",
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
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.debug = false
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Locals and Housekeeping
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
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
love.gfx = {}
-- Get the base width and height of the window before we resize it later.
local base = {
  width = __BASE_WIDTH__ or love.graphics.getWidth(),
  height = __BASE_HEIGHT__ or love.graphics.getHeight(),
}

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
function love.gfx.resetColor() love.graphics.setColor(1, 1, 1, 1) end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Reset Blend Mode
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.resetBlendMode() love.graphics.setBlendMode("alpha", "alphamultiply") end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Set the color, under my control.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.setColor(...)
  local first_color_number = ...
  if type(first_color_number) == "nil" then
    love.gfx.resetColor()
    return
  end
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
  local temp_color = {
    love.graphics.getColor(),
  }
  local text_color = settings.color or temp_color
  local outline_color = settings.color2 or {
    math.abs(text_color[1] - 1),
    math.abs(text_color[2] - 1),
    math.abs(text_color[3] - 1),
    1,
  }
  local text, x, y, r, sx, sy, ox, oy, kx, ky = ...
  x = x or 0
  y = y or 0
  love.graphics.setColor(outline_color)
  if settings.thick then
    love.graphics.print(text, x + 1, y + 1, r, sx, sy, ox, oy, kx, ky)
    love.graphics.print(text, x - 1, y - 1, r, sx, sy, ox, oy, kx, ky)
    love.graphics.print(text, x - 1, y + 1, r, sx, sy, ox, oy, kx, ky)
    love.graphics.print(text, x + 1, y - 1, r, sx, sy, ox, oy, kx, ky)
  end
  love.graphics.print(text, x + 1, y, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print(text, x - 1, y, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print(text, x, y + 1, r, sx, sy, ox, oy, kx, ky)
  love.graphics.print(text, x, y - 1, r, sx, sy, ox, oy, kx, ky)
  love.graphics.setColor(text_color)
  love.graphics.print(text, x, y, r, sx, sy, ox, oy, kx, ky)
  love.graphics.setColor(temp_color)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Printf Outlined Text
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.outlinePrintf(settings, ...)
  settings = settings or {}
  local temp_color = {
    love.graphics.getColor(),
  }
  local text_color = settings.color or temp_color
  local outline_color = settings.color2 or {
    math.abs(text_color[1] - 1),
    math.abs(text_color[2] - 1),
    math.abs(text_color[3] - 1),
    1,
  }
  local text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky = ...
  x = x or 0
  y = y or 0
  love.graphics.setColor(outline_color)
  if settings.thick then
    love.graphics.printf(text, x + 1, y + 1, limit, align, r, sx, sy, ox, oy, kx, ky)
    love.graphics.printf(text, x - 1, y - 1, limit, align, r, sx, sy, ox, oy, kx, ky)
    love.graphics.printf(text, x - 1, y + 1, limit, align, r, sx, sy, ox, oy, kx, ky)
    love.graphics.printf(text, x + 1, y - 1, limit, align, r, sx, sy, ox, oy, kx, ky)
  end
  love.graphics.printf(text, x + 1, y, limit, align, r, sx, sy, ox, oy, kx, ky)
  love.graphics.printf(text, x - 1, y, limit, align, r, sx, sy, ox, oy, kx, ky)
  love.graphics.printf(text, x, y + 1, limit, align, r, sx, sy, ox, oy, kx, ky)
  love.graphics.printf(text, x, y - 1, limit, align, r, sx, sy, ox, oy, kx, ky)
  love.graphics.setColor(text_color)
  love.graphics.printf(text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky)
  love.graphics.setColor(temp_color)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Gradient Rectangle -- love.gfx.colorRectangle(20, 20, 100, 10 + 5 * math.sin(timer*5), {0.2,0.8,0.2,1}, {0,0.6,0.45,1}, "y")
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Create image for scaling
local x1pixel_image = love.image.newImageData(1, 1)
x1pixel_image:setPixel(0, 0, 1, 1, 1, 1)
local x1pix = love.graphics.newImage(x1pixel_image)

-- Local shader 
local horizontal_shade = love.graphics.newShader([[
    extern vec4 color1;
    extern vec4 color2;
    vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
    {
      vec4 fcolor = mix(color1,color2,uv.x);
      return Texel(texture, uv) * fcolor;
    }  
]])

local vertical_shade = love.graphics.newShader([[
    extern vec4 color1;
    extern vec4 color2;
    vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
    {
      vec4 fcolor = mix(color1,color2,uv.y);
      return Texel(texture, uv) * fcolor;
    }  
]])

local both_shade = love.graphics.newShader([[
    extern vec4 color1;
    extern vec4 color2;
    vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
    {
      vec4 fcolor = mix(color1,color2,(uv.y * uv.x));
      return Texel(texture, uv) * fcolor;
    }  
]])

local center_shade = love.graphics.newShader([[
    extern vec4 color1;
    extern vec4 color2;
    extern float limit_colors;
    vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
    {
      vec2 centeruv = uv;
      centeruv.x = centeruv.x - 0.5;
      centeruv.y = centeruv.y - 0.5;
      float d = length(centeruv);
      vec4 fcolor = mix(color1,color2,d);
      fcolor.r = floor((limit_colors - 1.0) * fcolor.r + 0.5) / (limit_colors - 1.0);
      fcolor.g = floor((limit_colors - 1.0) * fcolor.g + 0.5) / (limit_colors - 1.0);
      fcolor.b = floor((limit_colors - 1.0) * fcolor.b + 0.5) / (limit_colors - 1.0);
      return Texel(texture, uv) * fcolor;
    }  
]])

center_shade:send("limit_colors", 24)

function love.gfx.colorRectangle(x, y, w, h, color1, color2, mode, colors)
  colors = colors or 24
  -- Capture the current color 
  local r, g, b, a = love.graphics.getColor()
  local tempcolor = {
    r,
    g,
    b,
    a,
  }
  color1 = color1 or tempcolor
  color2 = color2 or tempcolor

  -- Capture the current shader 
  local curshader = love.graphics.getShader()

  -- Send the colors to the shader and render the shader
  mode = mode or "x"
  if mode == "x" then
    mode = horizontal_shade
    horizontal_shade:send("color1", color1)
    horizontal_shade:send("color2", color2)
  end

  if mode == "y" then
    mode = vertical_shade
    vertical_shade:send("color1", color1)
    vertical_shade:send("color2", color2)
  end

  if mode == "xy" then
    mode = both_shade
    both_shade:send("color1", color1)
    both_shade:send("color2", color2)
  end

  if mode == "c" then
    mode = center_shade
    center_shade:send("color1", color1)
    center_shade:send("color2", color2)
  end

  center_shade:send("limit_colors", colors)
  love.graphics.setShader(mode)

  -- Make a 1x1 image into a huge box
  love.graphics.draw(x1pix, x + w / 2, y + h / 2, math.rad(0), w, h, w / w / 2, h / h / 2)

  -- Return the shader to normal 
  love.graphics.setShader(curshader)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Gradient Disk  
  -- Outline Example 
    love.gfx.disk(49, 49, 26, math.sin(timer) - 0.015 , -90+2, 12)
    love.gfx.colorDisk(50, 50, 25, math.sin(timer), -90, {1,0,0,1}, {0,0,1,1}, 10, "x")
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.colorDisk(x, y, r, total, rotate, color1, color2, dwidth, mode, colors)
  colors = colors or 24
  
  dwidth = dwidth or r / 2

  local function xc()
    love.graphics.arc("fill", x + r, y + r, r, 0 + math.rad(rotate), math.rad(total * 360) + math.rad(rotate), 128)
    love.graphics.arc("fill", x + r, y + r, r, 0 + math.rad(rotate), math.rad(total * 360) + math.rad(rotate), 128)
    love.graphics.circle("fill", x + r, y + r, r - dwidth)
  end

  love.graphics.stencil(xc, "increment", 1)
  love.graphics.setStencilTest("equal", 2)
  love.gfx.colorRectangle(x, y, r * 2, r * 2, color1, color2, mode, colors)
  love.graphics.setStencilTest()
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Standard Disk  
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.gfx.disk(x, y, r, total, rotate, dwidth)
  dwidth = dwidth or r / 2

  local function xc()
    love.graphics.arc("fill", x + r, y + r, r, 0 + math.rad(rotate), math.rad(total * 360) + math.rad(rotate), 128)
    love.graphics.arc("fill", x + r, y + r, r, 0 + math.rad(rotate), math.rad(total * 360) + math.rad(rotate), 128)
    love.graphics.circle("fill", x + r, y + r, r - dwidth)
  end

  love.graphics.stencil(xc, "increment", 1)
  love.graphics.setStencilTest("equal", 2)
  local w, h = r * 2, r * 2
  love.graphics.draw(x1pix, x + w / 2, y + h / 2, math.rad(0), w, h, w / w / 2, h / h / 2)
  love.graphics.setStencilTest()
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m
