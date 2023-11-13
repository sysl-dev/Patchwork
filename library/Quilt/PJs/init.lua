local m = {
  __NAME        = "Quilt-Kit-PJs",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "A cursed UI Library.",
  __URL         = "http://github.sysl.dev/",
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2023 Chris / Systemlogoff

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
--[[
Cursor and Mouse Control
Buttons
Sliders
Arrow Selector
Levels of Active
Linked Elements
Grid Alignment
Drodown List (iPhone Style?)
Themes
Number Selector  000  _0_00 _1_00
]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Debug Mode
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.debug = true

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create 1x1 Pixel Image
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.x1_pixel = love.image.newImageData(1,1)
m.x1_pixel:setPixel(0, 0, 1, 1, 1, 1)
m.x1_pixel = love.graphics.newImage(m.x1_pixel)
m.x1_pixel:setFilter("nearest", "nearest")
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Memory
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.storage = {
  __current = nil,
  __cursor = {x = 0, y = 0},
  __grid = 8,
  __width = love.graphics.getWidth(),
  __height = love.graphics.getHeight(),
  __selection = 1,
  __last_width = 0,
  __last_height = 0,
  __selection_mode = "both", -- Values, mouse/keyboard/both
  __active = false,
}

m.theme = {
  background = "",
  color = "",
  border_width = 1,
  border_color = {"","","","",},
  active_color = "",
  hover_color = "",
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Local Functions 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Let's do cursed things to strings
local function string_to_number(value, value2)
  if type(value) == "string" then 
    -- % Positioning 
    if string.sub(value, -2, -1) == "%w" then 
      return math.floor(tonumber(string.sub(value, 1, -3))/100 * m.storage.__width)
    end
    if string.sub(value, -2, -1) == "%h" then 
      return math.floor(tonumber(string.sub(value, 1, -3))/100 * m.storage.__height)
    end
    -- Grid Pos
    if string.sub(value, -1, -1) == "#" then 
      return math.floor(tonumber(string.sub(value, 1, -2)) * m.storage.__grid)
    end
    -- Center Positioning 
    if string.sub(value, -2, -1) == "cw" then 
      return math.floor(m.storage.__width/2 - value2/2)
    end
    if string.sub(value, -2, -1) == "ch" then 
      return math.floor(m.storage.__height/2 - value2/2)
    end
    return value
  else
    return value 
  end
end

-- I'm lazy, give me hex colors
local function hex2color(color_string)
  color_string = color_string:gsub("#", "")
  if #color_string == 3 then 
    color_string = string.sub(color_string, 1,1) .. string.sub(color_string, 1,1) .. string.sub(color_string, 2,2) .. string.sub(color_string, 2,2) ..
    string.sub(color_string, 3,3) ..  string.sub(color_string, 3,3) 
  end
  if #color_string == 4 then 
    color_string = string.sub(color_string, 1,1) .. string.sub(color_string, 1,1) .. string.sub(color_string, 2,2) .. string.sub(color_string, 2,2) ..
    string.sub(color_string, 3,3) .. string.sub(color_string, 3,3)  .. string.sub(color_string, 4,4)  .. string.sub(color_string, 4,4) 
  end
  local r = tonumber(color_string:sub(1, 2), 16)
  local g = tonumber(color_string:sub(3, 4), 16)
  local b = tonumber(color_string:sub(5, 6), 16)
  local a = tonumber(color_string:sub(7, 8), 16)
  if r == nil or g == nil or b == nil then return end
  a = a or 255
  r, g, b, a = love.math.colorFromBytes(r, g, b, a)
  return {r, g, b, a}
end

-- Safe-Rectangle, made from a pixel.
local function draw_color_rectangle(color, x, y, w, h)
  local lastcolor = {love.graphics.getColor()}
  -- Set the color
  if color then 
    if type(color) == "string" then 
      love.graphics.setColor(hex2color(color))
    else 
      love.graphics.setColor(color)
    end
  end
  -- Draw the rectangle
  love.graphics.draw(m.x1_pixel, x, y, 0, w, h)
  -- Reset the color 
  love.graphics.setColor(lastcolor)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create new UI 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Reset the UI / Create new window
function m.start(name, grid, x, y, w, h)
  -- Remove all items in our UI from the table.
  name = name or "no_name"
  grid = grid or 8
  x = x or 0
  y = y or 0
  w = w or love.graphics.getWidth()
  h = h or love.graphics.getHeight()
  if not m.storage[name] then 
    m.storage[name] = {}
  end
  if table.clear then 
    table.clear(m.storage[name])
  else
    for i=#m.storage[name], 1, -1 do 
      m.storage[name][i] = nil
    end
  end
  
  m.storage.__current = name
  m.storage.__cursor.x = x
  m.storage.__cursor.y = y
  m.storage.__width = w
  m.storage.__height = h
  m.storage.__last_width = 0
  m.storage.__last_height = 0
  m.storage.__grid = 8
  m.storage.__active = ""
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw the items 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw(name)
  -- Run the draw function for each object
  name = name or "no_name"
  for i=1, #m.storage[name] do 
    -- Stored as: 
    -- 1. Function 
    -- 2. Can the cursor land on this
    m.storage[name][i][1]()
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * UI Parts 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Add a custom function (I'm lazy and I know this will show up sooner or later)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Add a custom UI Item 
-- Needs a way to mark x/y
function m.custom(fun, cursor, ...)
  local stuff = {...}
  for i = 1, #stuff do 
    -- If x then do cursor stuff
    stuff[i] = string_to_number(stuff[i])
  end
  m.storage[m.storage.__current][#m.storage[m.storage.__current] + 1] = {
    -- Do a function.
      
    function()
      fun(unpack(stuff))
    end,
    -- Can the cursor land on this?
    cursor
  }
end




--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Solid brick of color 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.solid(w,h,color,x,y)
  -- Update these values 
  w = string_to_number(w)
  h = string_to_number(h)
  x = x or 0
  y = y or 0
  x = string_to_number(x, w)
  y = string_to_number(y, h)
  local tempx = x 
  local tempy = y
  x = x + m.storage.__cursor.x
  y = y + m.storage.__cursor.y

  -- Grab the current UI we're working on
  m.storage[m.storage.__current][#m.storage[m.storage.__current] + 1] = {
    -- Do a function.
    function()
      draw_color_rectangle(color, x, y, w, h)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
  -- Update the cursor 
  m.storage.__cursor.x = m.storage.__cursor.x + tempx
  m.storage.__cursor.y = m.storage.__cursor.y + tempy
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Text  
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.text_format(text,w,align,color,x,y,r)
  -- Update these values 
  w = string_to_number(w)
  align = align or "left"
  x = x or 0
  y = y or 0
  r = r or 0
  x = string_to_number(x, w)
  y = string_to_number(y)
  local tempx = x 
  local tempy = y
  x = x + m.storage.__cursor.x
  y = y + m.storage.__cursor.y
  local _, twrappedtext = love.graphics.getFont():getWrap(text, w)
  local h = math.floor(#twrappedtext * love.graphics.getFont():getHeight() * love.graphics.getFont():getLineHeight())

  -- Grab the current UI we're working on
  m.storage[m.storage.__current][#m.storage[m.storage.__current] + 1] = {
    -- Do a function.
    function()
      local lastcolor = {love.graphics.getColor()}
      -- Set the color
      if color then 
        if type(color) == "string" then 
          love.graphics.setColor(hex2color(color))
        else 
          love.graphics.setColor(color)
        end
      end
      -- Draw the rectangle
      love.graphics.printf(text, x, y, w,align)
      -- Reset the color 
      love.graphics.setColor(lastcolor)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
  -- Update the cursor 
  m.storage.__cursor.x = m.storage.__cursor.x + tempx
  m.storage.__cursor.y = m.storage.__cursor.y + tempy
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * UI Positioning
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Move UI Pen Position
function m.right(px)
  px = px or m.storage.__last_width
  px = string_to_number(px)
  m.storage.__cursor.x = m.storage.__cursor.x + px
end

function m.left(px)
  px = px or m.storage.__last_width
  px = string_to_number(px)
  m.storage.__cursor.x = m.storage.__cursor.x - px
end

function m.down(px)
  px = px or m.storage.__last_height
  px = string_to_number(px)
  m.storage.__cursor.y = m.storage.__cursor.y + px
end

function m.up(px)
  px = px or m.storage.__last_height
  px = string_to_number(px)
  m.storage.__cursor.y = m.storage.__cursor.y - px
end

-- This includes the last object and a bit extra
function m.right_and(px)
  px = string_to_number(px)
  px = px + m.storage.__last_width
  m.storage.__cursor.x = m.storage.__cursor.x + px
end

function m.left_and(px)
  px = string_to_number(px)
  px = px + m.storage.__last_width
  m.storage.__cursor.x = m.storage.__cursor.x - px
end

function m.down_and(px)
  px = string_to_number(px)
  px = px + m.storage.__last_width
  m.storage.__cursor.y = m.storage.__cursor.y + px
end

function m.up_and(px)
  px = string_to_number(px)
  px = px + m.storage.__last_width
  m.storage.__cursor.y = m.storage.__cursor.y - px
end

function m.newline(px)
  px = px or 0
  px = string_to_number(px)
  m.storage.__cursor.x = 0
  px = px + m.storage.__last_height
  m.storage.__cursor.y = m.storage.__cursor.y + px
end

-- Set the Pen Position 
function m.set_cursor(x, y)
  x = string_to_number(x)
  y = string_to_number(y)
  m.storage.__cursor.x = x
  m.storage.__cursor.y = y
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw
--------------------------------------------------------------------------------------------------------------------------------------------------]]--

return m