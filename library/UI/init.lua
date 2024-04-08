local m = {
  __NAME        = "Living Pen UI",
  __VERSION     = "0.5",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Generate a UI in update, draw the drawing list in draw.",
  __URL         = "http://github.sysl.dev/",
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2024 Chris / Systemlogoff

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
  __DEBUG = 3, -- Warning, Info, Noise 
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Debug Mode

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function print_warning(...)
  if m.__DEBUG >= 1 then
    print(m.__NAME .. "-WARNING:")
    print(...)
    print("")
  end
end

local function print_information(...)
  if m.__DEBUG >= 2 then
    print(m.__NAME .. "-INFORMATION:")
    print(...)
    print("")
  end
end

local function print_noise(...)
  if m.__DEBUG >= 2 then
    print(m.__NAME .. "-NOISE:")
    print(...)
    print("")
  end
end

--[[

To Do
  VEGETABLES:
    Start Basic Documentation [Started]

  CURSOR:
    cursor memory [Figure out how to do this best]
    change cursor per button/set of buttons 
    MOUSE - Can't click inactive UI
    better way to refresh the nodemap 
    Jump to NAMED NODE when a direction is pressed.

  UI SETTINGS:
    UI Flag - Do not draw unless active

  GRAPHS
    Line Graph
    Bar Graph

  MORE FEATURES
    Text Box (Simple, no advanced editing)
    Number Picker0
    Color Picker
      
  PAINFUL ITEMS
    Fake Scrolling Window, Shows X Items, changes what items are in slots when move (Window
    Real Scrolling Window, Items out of view do not render
      plot along line / curved line 
]]--


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Resources

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Capture the exposed base width/height if avaiable, if not grab the love graphics value.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.basewidth = __BASE_WIDTH__ or love.graphics.getWidth()
m.baseheight = __BASE_HEIGHT__ or love.graphics.getHeight()
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Configuration Values 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Mouse Buttons if remapping is needed 
m.primary_mouse = 1
m.secondary_mouse = 2
m.tertiary_mouse = 3
m.vcursor_key = false
m.vcursor_up = false
m.vcursor_down = false
m.vcursor_left = false
m.vcursor_right = false

-- Lock Mouse if Pressed 
m.mouse_button_lock = false
m.vcursor_key_lock = false



--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Memory
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.storage = {
  -- Cache of draw instructions.
  --__uis[ui name][1 ... ♾️]
  __uis = {},
  -- Cache, create a sub table depending on the UI with each button ID being able to add themselves.
  -- __button_states[ui name][id] = false/true 
  __button_states = {},
  -- Create a note tree for the current ui when using the cursor.
  -- __node_map[ui name].[id] = {Direction = Numpad, 5 = Back. 1=bl, 2=down, 3=br, etc }
  -- Mose node maps only will likely use 2,6,8,4, bottom right top left 
  -- higher numbers may be used depending on ???
  __node_map = {},
  -- Current UI we are adding to.
  __current = nil,
  -- Pen is used to link shapes 
  __pen = {x = 0, y = 0, basex = 0, basey = 0},
  -- If width and height are not defined take whole screen.
  __width = m.basewidth,
  __height = m.baseheight,
  -- Cache, last w/h of what we drew 
  __last_width = 0,
  __last_height = 0,
  -- Theme 
  __theme = "default",
  __current_font = love.graphics.getFont(),
  -- Active UI 
  __ui_active = {},
  -- MODE mouse, cursor, both
  __mode = "both"
}

m.vcursor = {
  ui_active_check = "",
  -- default-arrow, outline, custom function, custom image
  default_type = "arrow",
  type = "arrow",
  -- bounce, bounce-x, bounce-y, ???
  animation = "bounce-x",
  outline_spacing = 2,
}
m.clock = {
  background = 0
}

local function vcursor_reset()
  m.vcursor.x = 0
  m.vcursor.y = 0
  m.vcursor.goal_x = 0
  m.vcursor.goal_y = 0
  m.vcursor.w = 1
  m.vcursor.h = 1
  m.vcursor.speed = 800
  m.vcursor.element = nil
  m.vcursor.element_name = nil
  m.vcursor.visible = true
  m.vcursor.is_moving = false
  m.vcursor.timer = 0
  m.vcursor.timer_ani = 0
end vcursor_reset()

m.theme = {
  -- Boring Grey Buttons
  default = {
    color = "0f0f0f",
    background = "f0f0f0",
    highlight = "aa0000",

    -- TOOLTIP STYLE --
    tooltip = {
      color = "0f0f0f",
      background = "ffffcc",
      border = "663300"
    },

    -- BUTTON STYLE --
    button = {
      align = "center",
      normal = {
        background = "c0c0c0",
        color = "0f0f0f",
        align = "center",
        border_color = "0f0f0f",
        padding = {top = 3, right = 5, bottom = 2, left = 5},
      },
      hover = {
        background = "d0d0d0",
        border_color = "f0f0f0",
      },
      active = {
        border_color = "ff0000",
        color = "ff0000",
      },
      enabled = {
        background = "a0c0a0",
        border_color = "c0F0c0",
      },
      disabled = {
        background = "b0b0b0",
        color = "3f3f3f",
        border_color = "aa7f7f",
      },
    },
  },
}


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Simple B/W Image Creator 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function generate_pixels_on_imagemap(imap, atable, length, width)
  local i = 1
  for y=1, length/width do
    for x=1, width do
      local color = atable[i]
      local px = x - 1
      local py = y - 1
      if color ~= 2 then
        imap:setPixel(px, py, color, color, color, 1)
      end
      i = i + 1
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create 1x1 White Pixel Image
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.texture_1xpixel = love.image.newImageData(1,1)
m.texture_1xpixel:setPixel(0, 0, 1, 1, 1, 1)
m.texture_1xpixel = love.graphics.newImage(m.texture_1xpixel)
m.texture_1xpixel:setFilter("nearest", "nearest")
m.texture_1xpixel:setWrap("repeat", "repeat")

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create Basic Arrow
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.texture_arrow = love.image.newImageData(7,9)
local rawcur = {
  0,0,0,2,2,2,
  0,1,1,0,2,2,
  0,1,1,1,0,2,
  0,1,1,1,1,0,
  0,1,1,1,1,0,
  0,1,1,1,0,2,
  0,1,1,0,2,2,
  0,0,0,2,2,2,
}
generate_pixels_on_imagemap(m.texture_arrow, rawcur, #rawcur, 6)
m.texture_arrow = love.graphics.newImage(m.texture_arrow)
m.texture_arrow:setFilter("nearest", "nearest")
m.texture_arrow:setWrap("clampzero", "clampzero")

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Empty Table
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local empty_table = {}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Quick Node Map Storage 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local node_map_storage = {
  default_map = {
    up = -1,
    down = 1,
    left = -1,
    right = 1,
  }
}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Generate Quick Nodemap for a square grid of interactive things
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.create_simple_grid_node_map(size)
  local name = "simple_grid" .. tostring(size)
  if not node_map_storage[name] then
    node_map_storage[name] = { [0] = {
      up = -1*size,
      down = 1*size,
      left = -1,
      right = 1,
    }
    }
  end

  return node_map_storage[name]
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Local Functions 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Split a string into a table with a separator character.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function split_string_by(str, sep)
  local return_string = {}
  local n = 1
  for w in str:gmatch("([^" .. sep .. "]*)") do
    return_string[n] = return_string[n] or w -- only set once (so the blank after a string is ignored)
    if w == "" then n = n + 1 end -- step forwards on a blank but not a string
  end
  return return_string
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Convert special string values for size into context values.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function string_to_number(value)
  -- Got a nil? Don't bother. 
  if type(value) == "nil" then return end
  -- Strings are work.
  if type(value) == "string" then
    value = value:lower()
    -- % Positioning X
    if string.sub(value, -1, -1) == "%" then
      return math.floor((tonumber(string.sub(value, 1, -2))/100 * m.storage.__width))
    -- % Positioning X
    elseif string.sub(value, -2, -1) == "%w" then
      return math.floor((tonumber(string.sub(value, 1, -3))/100 * m.storage.__width))
    -- % Positioning Y
    elseif string.sub(value, -2, -1) == "%h" then
      return math.floor(tonumber(string.sub(value, 1, -3))/100 * m.storage.__height)
    -- Pixels, used for calc 
    elseif string.sub(value, -2, -1) == "px" then
      return math.floor(tonumber(string.sub(value, 1, -3)))
    -- Fixed X 
    elseif string.sub(value, -2, -1) == "fx" then
      return math.floor(tonumber(string.sub(value, 1, -3))) - m.storage.__pen.x
    -- Fixed Y 
    elseif string.sub(value, -2, -1) == "fy" then
      return math.floor(tonumber(string.sub(value, 1, -3))) - m.storage.__pen.y
    -- Grid Pos
    elseif string.find(value, "#") then
      local gridparts = split_string_by(value, "#")
      return math.floor(gridparts[1] * gridparts[2])
    -- Last Width
    elseif string.find(value, "last width") then
      return m.storage.__last_width
    -- Last Height
    elseif string.find(value, "last height") then
      return m.storage.__last_height
    -- Center Positioning X
    elseif string.find(value, "half width") then
      return math.floor(m.storage.__width/2)
    -- Center Positioning Y
    elseif string.find(value, "half height") then
      return math.floor(m.storage.__height/2)
        -- % Positioning Y
    elseif string.sub(value, 1,4) == "calc" then
      local calcparts = split_string_by(value, " ")
      local result = 0
      local state = "replace"
      for i = 2, #calcparts - 1 do
        if calcparts[i] == "+" then state = "add"
        elseif calcparts[i] == "-" then state = "sub"
        elseif calcparts[i] == "*" then state = "mul"
        elseif calcparts[i] == "/" then state = "div"
        else
          if state == "replace" then
            result = string_to_number(calcparts[i])
          elseif state == "add" then
            result = result + string_to_number(calcparts[i])
          elseif state == "sub" then
            result = result - string_to_number(calcparts[i])
          elseif state == "div" then
            result = result / string_to_number(calcparts[i])
          elseif state == "mul" then
            result = result * string_to_number(calcparts[i])
          end
        end
      end
      return result
    end
    error("Command Not Understood: " .. tostring(value))
  else
    -- Any other types? Just return them. 
    return value
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Allow using hex colors for lazyness 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local color_convert_cache = {}

local function color_read_hex(color_string)
  -- If a table of colors or number is sent, kick it back.
  if type(color_string) == "table" or type(color_string) == "number" then return color_string end
  -- Convert
  color_string = color_string:gsub("#", "")
  if color_convert_cache[color_string] then return color_convert_cache[color_string] end
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
  color_convert_cache[color_string] = {r, g, b, a}
  return color_convert_cache[color_string]
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create a rectangle from an image to allow for lazy shaders.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function draw_rectangle_with_color(color, x, y, w, h)
  local lr, lg, lb, la = love.graphics.getColor()
  -- Set the color 
  if color then
      love.graphics.setColor(color_read_hex(color))
  end
  -- Draw the rectangle
  love.graphics.draw(m.texture_1xpixel, x, y, 0, w, h)
  -- Reset the color 
  love.graphics.setColor(lr, lg, lb, la)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create a pixel line (replace w/ pixel line if I care enough later)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function draw_line_with_color(color, ...)
  local lr, lg, lb, la = love.graphics.getColor()
  -- Set the color 
  if color then
      love.graphics.setColor(color_read_hex(color))
  end
  -- Draw the rectangle
  love.graphics.line(...)
  -- Reset the color 
  love.graphics.setColor(lr, lg, lb, la)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create a rectangle from an image to allow for lazy shaders.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function draw_text_with_color(text, x, y, w, align, color)
  local lr, lg, lb, la = love.graphics.getColor()
    -- Set the color
    if color then
      love.graphics.setColor(color_read_hex(color))
    end
    -- Draw the rectangle
    love.graphics.printf(text, x, y, w,align)
    -- Reset the color 
    love.graphics.setColor(lr, lg, lb, la)
  end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draws a 1 width outline
--------------------------------------------------------------------------------------------------------------------------------------------------]]--  
local white_color_for_draw_frame = {1,1,1,1}
local function draw_frame_square(color, x, y, w, h)
  local lr, lg, lb, la = love.graphics.getColor()
  color = color or white_color_for_draw_frame
    if color then
      color = love.graphics.setColor(color_read_hex(color))
    end

    draw_rectangle_with_color(color, x, y, w, 1)
    draw_rectangle_with_color(color, x, y+h-1, w, 1)
    draw_rectangle_with_color(color, x, y, 1, h)
    draw_rectangle_with_color(color, x+w-1, y, 1, h)

    love.graphics.setColor(lr, lg, lb, la)
  end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw a complex polygon from a table 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local draw_poly_cache = {}
local function draw_poly_with_color_cache(name, color, vertices, style)
  style = style or "fill"
  local lr, lg, lb, la = love.graphics.getColor()
    -- Set the color
    if color then
      love.graphics.setColor(color_read_hex(color))
    end
    -- Draw the polygon
    if not draw_poly_cache[name] then
      draw_poly_cache[name] = love.math.triangulate(vertices)
    end
    local triangles = draw_poly_cache[name]

    for tri=1, #triangles do
      love.graphics.polygon(style, triangles[tri])
    end
    -- Reset the color 
    love.graphics.setColor(lr, lg, lb, la)
  end

local function draw_poly_with_color(name, color, vertices, style)
  style = style or "fill"
  local lr, lg, lb, la = love.graphics.getColor()
    -- Set the color
    if color then
      love.graphics.setColor(color_read_hex(color))
    end
    -- Draw the polygon
    local triangles = love.math.triangulate(vertices)

    for tri=1, #triangles do
      love.graphics.polygon(style, triangles[tri])
    end
    -- Reset the color 
    love.graphics.setColor(lr, lg, lb, la)
  end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Check if something is over the mouse.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
  local function isover(local_x, local_y, local_width, local_height, mouse_x, mouse_y, mouse_width, mouse_height)
    mouse_width = mouse_width or 1
    mouse_height = mouse_height or 1
    return local_x < mouse_x + mouse_width and
            mouse_x < local_x + local_width and
            local_y < mouse_y + mouse_height and
            mouse_y < local_y + local_height
    end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Get the character width for the current font.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function get_character_width(text)
  return love.graphics.getFont():getWidth(text)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Get the character height for the current font. (Will have to add linebreak count later.)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function get_character_height(text)
  return love.graphics.getFont():getHeight(text)
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Get the character height for the current font. (Will have to add linebreak count later.)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function get_character_height_include_linebreaks(text,width)
  local _, twrappedtext = love.graphics.getFont():getWrap(text, width)
  return math.floor(#twrappedtext * love.graphics.getFont():getHeight() * love.graphics.getFont():getLineHeight()), get_character_height(text)
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Simple Clamp
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local min, max = math.min, math.max
local function clamp(num_var, max_val, min_val)
  return max(max_val, min(min_val, num_var))
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Update and cursor/mouse babysitter.

--------------------------------------------------------------------------------------------------------------------------------------------------]]--

function m.update(dt)
  m.clock.background = m.clock.background + dt
  if m.clock.background > 100000 * math.pi then m.clock.background = m.clock.background - 100000 * math.pi end

  if (not love.mouse.isDown(m.primary_mouse)) then
    m.mouse_button_lock = false
  end
  if (not love.mouse.isDown(m.secondary_mouse)) then
    m.mouse_button_lock = false
  end
  if (not love.mouse.isDown(m.tertiary_mouse)) then
    m.mouse_button_lock = false
  end

  if (not m.vcursor_key) then
    m.vcursor_key_lock = false
  end

  -- Do the cursor animations
  m.cursor_update(dt)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Functions

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Grab the currently active UI Draw Queue 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_active_ui_draw_queue()
  return  m.storage.__uis[m.storage.__current].draw_queue
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Grab a UI Draw Queue 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_ui_draw_queue(name)
  return  m.storage.__uis[name].draw_queue
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Grab the currently active UI 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_active_ui_settings()
  return  m.storage.__uis[m.storage.__current].settings
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Grab a UIs settings
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_ui_settings(name)
  return  m.storage.__uis[name].settings
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Grab the current themee
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_current_theme(theme)
  theme = theme or m.get_active_ui_settings().theme or m.storage.__theme
  return m.theme[theme]
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Insert a new theme into the theme library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.add_theme(theme_name, theme_table)
  m.theme[theme_name] = theme_table
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Insert a new theme into the theme library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_number_from_id_draw_queue(id)
  local draw_queue = m.get_active_ui_draw_queue()
  local escape_search = nil
  for i=#draw_queue, 1, -1 do
    if draw_queue[i][3] == id then
      escape_search = i
    end
  end
  return escape_search
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Grab the cache 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_current_button_cache()
  if not m.storage.__button_states[m.storage.__current] then m.storage.__button_states[m.storage.__current] = {} end
  return m.storage.__button_states[m.storage.__current]
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create new UI 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Reset the UI / Create new window
function m.define(name, x, y, w, h, mousex, mousey, theme)
  -- Define and update the table settings, we can't use the special string numbers here. 
  name = tostring(name)
  x = x or 0
  y = y or 0
  w = w or love.graphics.getWidth()
  h = h or love.graphics.getHeight()
  mousex = mousex or love.mouse.getX()
  mousey = mousey or love.mouse.getY()

  -- Cache our menu, so we can toggle active/inactive for cursor
  if not m.storage.__uis[name] then
    m.storage.__uis[name] = {
      settings = {
      active = false,
      theme = theme
      },
      draw_queue = {

      }
    }
  end

  -- Clear any draw commands for a fresh round
  for i=#m.storage.__uis[name].draw_queue, 1, -1 do
    m.storage.__uis[name].draw_queue[i] = nil
  end

  -- Update the storage with the details.
  -- Storage acts as our guide since we're only drawing
  -- one UI at a time.
  -- This could be per UI, but there's no real need. 
  m.storage.__current = name
  m.storage.__pen.x = x
  m.storage.__pen.y = y
  m.storage.__pen.basex = x
  m.storage.__pen.basey = y
  m.storage.__width = w
  m.storage.__height = h
  m.storage.__last_width = 0
  m.storage.__last_height = 0
  m.storage.mousex = mousex
  m.storage.mousey = mousey
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * UI Get Active 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.active_ui_name_get()
  -- Get the name of the current active UI
  return m.storage.__ui_active[1]
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * UI Set Active 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.active_ui_clear()
-- If we're setting active, clear any stored states for popping 
  for i=#m.storage.__ui_active, 1, -1 do
    m.storage.__ui_active[i] = nil
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * UI Set Active 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.active_ui_set(name)
  -- Just in case 
  name = tostring(name)

  -- If we're setting active, clear any stored states for popping 
  m.active_ui_clear()

  -- Set the current and only ui
  m.storage.__ui_active[1] = name
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * UI Push UI 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.active_ui_push(name)
  -- Just in case 
  name = tostring(name)

  -- Push the new UI to the stack (unless it's already set)
  -- I know I should let you push the same UI more than once
  -- instead of correcting this magically
  -- but this library is going to be used in gamejams
  -- so it stays.
  if (m.storage.__ui_active[#m.storage.__ui_active] ~= name) then
    table.insert(m.storage.__ui_active, 1, name)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * UI pop UI 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.active_ui_pop()
  -- Set the current and only ui
  table.remove(m.storage.__ui_active, 1)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw the items 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw_defined(name)
  name = tostring(name)

  -- Confirm that we've create the UI before drawing it.
  if not m.storage.__uis[name] then return end

  -- Run the draw function for each object
  for i=1, #m.storage.__uis[name].draw_queue do
    -- Stored as: 
    -- 1. Function 
    -- 2. Can the cursor land on this
    m.storage.__uis[name].draw_queue[i][1]()
  end
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create a node map for directions
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.create_node_map(name, map_table)
  -- Make sure name is a string 
  name = tostring(name)
  map_table = map_table or empty_table
  -- Make a local for the node map and draw queue 
  local nodemap
  local drawq

  -- if it exists, make a local for our drawqueue
  if m.storage.__uis[name].draw_queue then
     drawq = m.storage.__uis[name].draw_queue
  else
    error("That NAME: " .. name .. "DID NOT EXIST!")
  end

  -- Create the map if it does not exist, set to our cache local 
  if not m.storage.__node_map[name] then
    m.storage.__node_map[name] = {}
  end

  -- Empty the node map 
  for i=#m.storage.__node_map[name], 1, -1 do
    m.storage.__node_map[name][i] = nil
  end

  -- Shorten the path to the nodemap table for line length
  nodemap = m.storage.__node_map[name]

  -- Start building our map.
  for i=1, #drawq do
    if drawq[i][2] then
      -- If our maptable has defined special remaps, then we use it.
      local map_used = map_table[drawq[i][3]] or map_table[0] or node_map_storage.default_map
      --                        id,         cursor type,           x,         y,          w,          h,             map
      nodemap[#nodemap + 1] = {drawq[i][3], drawq[i][4], drawq[i][5], drawq[i][6], drawq[i][7], drawq[i][8], map_used}
    end
  end

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Get the node map
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_node_map(name)
  -- Make sure name is a string 
  name = tostring(name)
  return m.storage.__node_map[name]
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------


  * UI Parts 


--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * MISC

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Solid Color Rectangle
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.solid_rectangle(color, w, h, x, y, shader)
  -- Update these values 
  w = string_to_number(w) or m.storage.__width
  h = string_to_number(h) or m.storage.__height
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  color = color or m.get_current_theme().background

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      local pastshader = love.graphics.getShader()
      love.graphics.setShader(shader)
      draw_rectangle_with_color(color, x, y, w, h)
      love.graphics.setShader(pastshader)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Solid Color Disk
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.solid_disk(color, disk_width, total_filled, disk_thickness, rotate_start_end, x, y, shader)
  -- Update these values 
  local w = string_to_number(disk_width)
  local h = string_to_number(disk_width)
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  color = color or m.get_current_theme().background
  disk_thickness = disk_thickness or math.floor(disk_width/2)
  disk_thickness = math.min(disk_thickness, disk_width)

  rotate_start_end = rotate_start_end or 0
  rotate_start_end = rotate_start_end - 90

  local function pixel_test_function()
    love.graphics.arc("fill", x + disk_width/2, y + disk_width/2, disk_width/2, 0 + math.rad(rotate_start_end), math.rad(total_filled * 360) + math.rad(rotate_start_end), 128)
    love.graphics.arc("fill", x + disk_width/2, y + disk_width/2, disk_width/2, 0 + math.rad(rotate_start_end), math.rad(total_filled * 360) + math.rad(rotate_start_end), 128)
    love.graphics.circle("fill", x + disk_width/2, y + disk_width/2, disk_width/2 -  disk_thickness/2)
  end

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      local pastshader = love.graphics.getShader()
      love.graphics.setShader(shader)
      love.graphics.stencil(pixel_test_function, "increment", 1)
      love.graphics.setStencilTest("equal", 2)
      draw_rectangle_with_color(color, x, y, w, h)
      love.graphics.setStencilTest()
      love.graphics.setShader(pastshader)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Image (Always centered for easy animation)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.image(image, r, scale, mode, w, h, x, y, shader)
  -- Update these values 
  w = image:getWidth()
  h = image:getHeight()
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  r = r or 0
  scale = scale or 1
  local ox, oy = 0,0
  if mode ~= "top-left" then
    ox = math.floor(w/2)
    oy = math.floor(h/2)
    x = x + math.floor(w/2)
    y = y + math.floor(h/2)
  end

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      local pastshader = love.graphics.getShader()
      love.graphics.setShader(shader)
      love.graphics.draw(image, x, y, r, scale, scale, ox, oy)
      love.graphics.setShader(pastshader)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Slice9 - Always assumes same size squares
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local slice9_cache = {}
function m.slice9(image, w, h, is_tile, x, y, shader)
  -- Update these values 
  local image_w = image:getWidth()
  local image_h = image:getHeight()
  local chunk = math.floor(image:getWidth()/3)
  local scale_width = (w - 2*chunk)/chunk
  local scale_height = (h - 2*chunk)/chunk
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  if not slice9_cache[image] then
    image:setWrap("clampzero", "clampzero")
    slice9_cache[image] = {
      top_left = love.graphics.newQuad(0*chunk,0,chunk,chunk,image_w,image_h),
      top_center = love.graphics.newQuad(1*chunk,0,chunk,chunk,image_w,image_h),
      top_right = love.graphics.newQuad(2*chunk,0,chunk,chunk,image_w,image_h),
      center_left = love.graphics.newQuad(0*chunk,1*chunk,chunk,chunk,image_w,image_h),
      center_center = love.graphics.newQuad(1*chunk,1*chunk,chunk,chunk,image_w,image_h),
      center_right = love.graphics.newQuad(2*chunk,1*chunk,chunk,chunk,image_w,image_h),
      bottom_left = love.graphics.newQuad(0*chunk,2*chunk,chunk,chunk,image_w,image_h),
      bottom_center = love.graphics.newQuad(1*chunk,2*chunk,chunk,chunk,image_w,image_h),
      bottom_right = love.graphics.newQuad(2*chunk,2*chunk,chunk,chunk,image_w,image_h),
    }
  end

  if is_tile then
    local remainder = w % chunk
    w = w - remainder
    local remainder = h % chunk
    h = h - remainder
    w = math.max(w, 2*chunk)
    h = math.max(h, 2*chunk)
  end

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      local pastshader = love.graphics.getShader()
      love.graphics.setShader(shader)
      if is_tile then
        for ty = 1, math.floor(h/chunk) - 2 do
          for tx = 1, math.floor(w/chunk) - 2 do
            love.graphics.draw(image, slice9_cache[image]["center_center"], x + chunk + (tx -1) * chunk, y + chunk + (ty -1) * chunk)
          end
        end

        for ty = 1, math.floor(h/chunk) - 2 do
          love.graphics.draw(image, slice9_cache[image]["center_left"], x, y + chunk + (ty -1) * chunk)
          love.graphics.draw(image, slice9_cache[image]["center_right"], x+w-chunk, y + chunk + (ty -1) * chunk)
        end
        for tx = 1, math.floor(w/chunk) - 2 do
          love.graphics.draw(image, slice9_cache[image]["top_center"], x + chunk + (tx -1) * chunk, y)
          love.graphics.draw(image, slice9_cache[image]["bottom_center"], x + chunk + (tx -1) * chunk, y+h-chunk)
        end


        love.graphics.draw(image, slice9_cache[image]["top_left"], x, y)
        love.graphics.draw(image, slice9_cache[image]["top_right"], x+w-chunk, y)
        love.graphics.draw(image, slice9_cache[image]["bottom_left"], x, y+h-chunk)
        love.graphics.draw(image, slice9_cache[image]["bottom_right"], x+w-chunk, y+h-chunk)
      else
        love.graphics.draw(image, slice9_cache[image]["center_center"], x + chunk, y + chunk, 0, scale_width, scale_height)
        love.graphics.draw(image, slice9_cache[image]["top_center"], x + chunk, y, 0, scale_width, 1)
        love.graphics.draw(image, slice9_cache[image]["bottom_center"], x + chunk, y+h-chunk, 0, scale_width, 1)
        love.graphics.draw(image, slice9_cache[image]["center_left"], x, y + chunk, 0, 1, scale_height)
        love.graphics.draw(image, slice9_cache[image]["center_right"], x+w-chunk, y + chunk, 0, 1, scale_height)

        love.graphics.draw(image, slice9_cache[image]["top_left"], x, y)
        love.graphics.draw(image, slice9_cache[image]["top_right"], x+w-chunk, y)
        love.graphics.draw(image, slice9_cache[image]["bottom_left"], x, y+h-chunk)
        love.graphics.draw(image, slice9_cache[image]["bottom_right"], x+w-chunk, y+h-chunk)

      end
      love.graphics.setShader(pastshader)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Repeating Image
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local repeating_image_cache = {}
-- Repeating Background is not allowed to resize.
function m.repeating_background(image, id, speedx, speedy, dt, w, h, x, y, shader)
  -- Update these values 
  w = string_to_number(w) or m.storage.__width
  h = string_to_number(h) or m.storage.__height
  local imgw = image:getWidth()
  local imgh = image:getHeight()
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  dt = dt or 0

  local quadw = math.max(imgw*3, w*3)
  local quadh = math.max(imgh*3, h*3)

  if not repeating_image_cache[id] then
  image:setWrap("repeat", "repeat")
  repeating_image_cache[id] = {
      image,
      love.graphics.newQuad(0, 0, quadw, quadh, imgw, imgh),
      -imgw,
      -imgh
  }
  end

  -- Update the Timers
  repeating_image_cache[id][3] = repeating_image_cache[id][3] + dt * speedx
  repeating_image_cache[id][4] = repeating_image_cache[id][4] + dt * speedy

  if repeating_image_cache[id][3] >= 0 then repeating_image_cache[id][3] = repeating_image_cache[id][3] - imgw end
  if repeating_image_cache[id][4] >= 0 then repeating_image_cache[id][4] = repeating_image_cache[id][4] - imgh end

  if repeating_image_cache[id][3] <= -imgw*2 then repeating_image_cache[id][3] = repeating_image_cache[id][3] + imgw end
  if repeating_image_cache[id][4] <= -imgw*2 then repeating_image_cache[id][4] = repeating_image_cache[id][4] + imgh end


  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
  -- Do a function.
  function()
    local pastshader = love.graphics.getShader()
    love.graphics.setShader(shader)
    -- store old Scissor
    local sx, sy, swidth, sheight = love.graphics.getScissor()
    -- Set the Scissor
    love.graphics.setScissor(x, y, w, h)
    love.graphics.draw(
    repeating_image_cache[id][1],
    repeating_image_cache[id][2],
    math.floor(x + repeating_image_cache[id][3]),
    math.floor(y + repeating_image_cache[id][4])
  )
  -- Restore old Scissor
  love.graphics.setScissor(sx, sy, swidth, sheight)
  love.graphics.setShader(pastshader)
  end,
  -- Can the cursor land on this?
  false
 }

 -- Store the sizes 
 m.storage.__last_width = w
 m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Text

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Simple Colored Text, always centered in the defined box.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.text_color(text,w,h,align,color,x,y,shader)
  -- Update these values 
  text = text or "NO TEXT DEFINED"
  w = string_to_number(w) or get_character_width(text)
  align = align or "left"
  color = color or m.get_current_theme().color
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  h = h or get_character_height_include_linebreaks(text, w)
  local text_y_pos = 0
  text_y_pos = math.floor(h/2 - get_character_height_include_linebreaks(text, w)/2 )
  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      local pastshader = love.graphics.getShader()
      love.graphics.setShader(shader)
      draw_text_with_color(text, x, y + text_y_pos, w, align, color)
      love.graphics.setShader(pastshader)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end



--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Scrollbar

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local scrollbar_cache = {}
local vel = 0
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Basic
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.scrollbar_basic(id,dt,w,h,maxw,maxh,start_posx, start_posy,x,y)
  -- Update these values 
  w = string_to_number(w) or m.storage.__width
  h = string_to_number(h) or m.storage.__height
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  start_posx = start_posx or 0
  start_posy = start_posy or 0

  local colorfront = m.get_current_theme().color
  local colorbg = m.get_current_theme().background

  if not scrollbar_cache[id] then
    scrollbar_cache[id] = {start_posx, start_posy}
  end

  local is_mouse_over = isover(x,y,maxw,maxh,m.storage.mousex, m.storage.mousey)
  local is_mouse_down = love.mouse.isDown(m.primary_mouse)
  local is_mouse2_down = love.mouse.isDown(m.secondary_mouse)
  local is_mouse3_down = love.mouse.isDown(m.tertiary_mouse)
  local is_cursor_button_active = m.vcursor_key
  local is_vcursor_over = (m.vcursor.element_name == id) and (m.active_ui_name_get() == m.vcursor.ui_active_check)

  local any_mouse = is_mouse_down or is_mouse2_down or is_mouse3_down
  if is_mouse_over and any_mouse then
    colorfront = m.get_current_theme().highlight
    local mosx = m.storage.mousex - x
    local mosy = m.storage.mousey - y
    local per_box = (mosx + 1) / maxw
    local per_boy = (mosy + 1) / maxh

    scrollbar_cache[id][1] = per_box
    scrollbar_cache[id][2] = per_boy
  end

  if is_cursor_button_active and is_vcursor_over then
    m.vcursor_key_lock = true
    vel = 0.5
    colorfront = m.get_current_theme().highlight
    if m.vcursor_left then
      scrollbar_cache[id][1] = scrollbar_cache[id][1] - (vel) * dt
    end
    if m.vcursor_right then
      scrollbar_cache[id][1] = scrollbar_cache[id][1] + (vel) * dt
    end
    if m.vcursor_up then
      scrollbar_cache[id][2] = scrollbar_cache[id][2] - (vel) * dt
    end
    if m.vcursor_down then
      scrollbar_cache[id][2] = scrollbar_cache[id][2] + (vel) * dt
    end
  else

  end

  scrollbar_cache[id][1] = clamp(scrollbar_cache[id][1], 0, 1)
  scrollbar_cache[id][2] = clamp(scrollbar_cache[id][2], 0, 1)

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      draw_rectangle_with_color(colorfront, x, y, maxw, maxh)
      draw_rectangle_with_color(colorbg, x+1, y+1, maxw-2, maxh-2)
      local px = math.floor(scrollbar_cache[id][1] * maxw) - math.floor(w/2)
      px = clamp(px, 0, maxw-w)
      local py = math.floor(scrollbar_cache[id][2] * maxh) - math.floor(h/2)
      py = clamp(py, 0, maxh-h)
      draw_rectangle_with_color(colorfront, x + px, y + py, w, h)
    end,
    -- Can the cursor land on this?
    true, id,nil,x,y,maxw,maxh
  }

  -- Store the sizes 
  m.storage.__last_width = maxw
  m.storage.__last_height = h

  return  scrollbar_cache[id][1],  scrollbar_cache[id][2]
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Image
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.scrollbar_image(img_bg, img_bg_act, img_cur, id,dt,start_posx,start_posy,x,y)
  -- Update these values 
  local w, h = img_cur:getWidth(), img_cur:getHeight()
  local maxw, maxh = img_bg:getWidth(), img_bg:getHeight()
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  start_posx = start_posx or 0
  start_posy = start_posy or 0

  local bg = img_bg
  local cur = img_cur


  if not scrollbar_cache[id] then
    scrollbar_cache[id] = {start_posx, start_posy}
  end

  local is_mouse_over = isover(x,y,maxw,maxh,m.storage.mousex, m.storage.mousey)
  local is_mouse_down = love.mouse.isDown(m.primary_mouse)
  local is_mouse2_down = love.mouse.isDown(m.secondary_mouse)
  local is_mouse3_down = love.mouse.isDown(m.tertiary_mouse)
  local is_cursor_button_active = m.vcursor_key
  local is_vcursor_over = (m.vcursor.element_name == id) and (m.active_ui_name_get() == m.vcursor.ui_active_check)

  local any_mouse = is_mouse_down or is_mouse2_down or is_mouse3_down
  if is_mouse_over and any_mouse then
    bg = img_bg_act
    local mosx = m.storage.mousex - x
    local mosy = m.storage.mousey - y
    local per_box = (mosx + 1) / maxw
    local per_boy = (mosy + 1) / maxh

    scrollbar_cache[id][1] = per_box
    scrollbar_cache[id][2] = per_boy
  end

  if is_cursor_button_active and is_vcursor_over then
    m.vcursor_key_lock = true
    vel = 0.5
    bg = img_bg_act
    if m.vcursor_left then
      scrollbar_cache[id][1] = scrollbar_cache[id][1] - (vel) * dt
    end
    if m.vcursor_right then
      scrollbar_cache[id][1] = scrollbar_cache[id][1] + (vel) * dt
    end
    if m.vcursor_up then
      scrollbar_cache[id][2] = scrollbar_cache[id][2] - (vel) * dt
    end
    if m.vcursor_down then
      scrollbar_cache[id][2] = scrollbar_cache[id][2] + (vel) * dt
    end
  else

  end

  scrollbar_cache[id][1] = clamp(scrollbar_cache[id][1], 0, 1)
  scrollbar_cache[id][2] = clamp(scrollbar_cache[id][2], 0, 1)

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      love.graphics.draw(bg, x, y)
      local px = math.floor(scrollbar_cache[id][1] * maxw) - math.floor(w/2)
      px = clamp(px, 0, maxw-w)
      local py = math.floor(scrollbar_cache[id][2] * maxh) - math.floor(h/2)
      py = clamp(py, 0, maxh-h)
      love.graphics.draw(cur, x + px, y + py)
    end,
    -- Can the cursor land on this?
    true, id,nil,x,y,maxw,maxh
  }

  -- Store the sizes 
  m.storage.__last_width = maxw
  m.storage.__last_height = h

  return  scrollbar_cache[id][1],  scrollbar_cache[id][2]
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Buttons

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Button Parent
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.button(text, id, button_active, w, h, theme, cursor_type, x, y, draw_function, ...)
  -- State Management
  local state = "normal"
  local active_button = "no"
  local button_cache = m.get_current_button_cache()
  local cacheid = id
  local extra = {...}

  -- Enter, set font for scaling reasons
  local capture_font = love.graphics.getFont()
  love.graphics.setFont(m.storage.__current_font)

  -- Set the theme so we can start doing w/h calc
  theme = theme or "default"
  theme = m.get_current_theme(theme)
  local theme_state = theme.button[state] or theme.button.normal
  local theme_padding = theme.button[state].padding or  theme.button["normal"].padding
  local theme_align = theme.button.align

  -- X/Y/W/H Calcs 
  w = w or get_character_width(text) + theme_padding.left + theme_padding.right + 2
  w = string_to_number(w)
  h = h or get_character_height_include_linebreaks(text,w) + theme_padding.top + theme_padding.bottom
  h = string_to_number(h)
  x,y = (x or 0),(y or 0)
  x = string_to_number(x) + m.storage.__pen.x
  y = string_to_number(y) + m.storage.__pen.y

  -- A bit of text formatting
  local text_x = x + theme_padding.left
  local text_y = y + (h/2) - get_character_height_include_linebreaks(text,w)/2
  local text_w = w-(theme_padding.left + theme_padding.right)

  -- Is the mouse over?
  local is_mouse_over = isover(x,y,w,h,m.storage.mousex, m.storage.mousey)
  local is_vcursor_over = (m.vcursor.element_name == id) and (m.active_ui_name_get() == m.vcursor.ui_active_check)
  local is_mouse_down = love.mouse.isDown(m.primary_mouse)
  local is_mouse2_down = love.mouse.isDown(m.secondary_mouse)
  local is_mouse3_down = love.mouse.isDown(m.tertiary_mouse)
  local is_cursor_button_active = m.vcursor_key

  -- If we're hovering, then change state 
  if is_mouse_over or is_vcursor_over then state = "hover" end

   -- Are we over the button and the mouse buttons accepted are down? We enable button function 
  if ((is_mouse_over and (is_mouse_down or is_mouse2_down or is_mouse3_down) and (not m.mouse_button_lock)) or (is_cursor_button_active and is_vcursor_over and (not m.vcursor_key_lock))) then
    active_button = "yes"
  else
    button_cache[cacheid] = false
  end

  -- Are we over the button and the mouse buttons accepted are down? We set draw state to active!
  if ((is_mouse_over and (is_mouse_down or is_mouse2_down or is_mouse3_down)) or (is_cursor_button_active and is_vcursor_over)) then
    state = "active"
  else
    button_cache[cacheid] = false
  end

  -- Buttons are active unless they are not.
  if type(button_active) == "boolean" then
    if button_active then
      state = "enabled"
    else
      state = "disabled"
    end
  end

    -- If we're still active, adjust the text.
    if state == "active" or state == "enabled" then
      text_y = text_y + 1
    end

  -- Update the theme_state
  theme_state = theme.button[state] or theme.button.normal
  local col_bg = theme_state.background
  local col_txt = theme_state.color
  local col_border = theme_state.border_color

-- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  -- Throw all our work in the draw queue.
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      draw_function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
    end,
    -- Cursor Land [2] Node ID [3] Cursor Type [4] Size of element hitbox [5,6,7,8] 
    true, id,cursor_type,x,y,w,h
  }

  -- Clean Up 
  love.graphics.setFont(capture_font)

  -- Store for future UI
  m.storage.__last_width = w
  m.storage.__last_height = h

  -- Run Code 
  if (active_button == "yes") and (not button_cache[cacheid]) then
    button_cache[cacheid] = true
    m.mouse_button_lock = true
    m.vcursor_key_lock = true
    return true, is_mouse_down, is_mouse2_down, is_mouse3_down, is_cursor_button_active, m.vcursor_key
  else
    return false
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Simple Button - 1px Outline
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function button_basic_draw(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  draw_rectangle_with_color(col_bg, x, y, w, h)
  draw_frame_square(col_border, x, y, w, h)
  draw_text_with_color(text,text_x,text_y,text_w,theme_align,col_txt)
end

function m.button_basic(text, id, button_active, w, h, theme, cursor_type, x, y)
  return m.button(text, id, button_active, w, h, theme, cursor_type, x, y, button_basic_draw)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Quad Button
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function button_quad_draw(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  love.graphics.draw(extra[1], extra[2][state], x, y)
  text = extra[3]
  local text_move = extra[4] or 0
  col_txt = extra[5] or "000000"
  local color2 = extra[6] or col_txt
  local color3 = extra[7] or col_txt
  if text then
    text_x = x
    text_y = y + math.floor(h/2 - get_character_height_include_linebreaks(text, w)/2 )
    text_w = w
    if state == "hover" then col_txt = color2 end
    if state == "active" then text_y = text_y + text_move; col_txt = color3 end
    theme_align = "center"
    draw_text_with_color(text,text_x,text_y,text_w,theme_align,col_txt)
  end
end

local cache_button_quad = {}
function m.button_quad(img, id, button_active, text, text_move, color1, color2, color3, cursor_type, x, y)
  assert(img, "Button QUAD: IMAGE NIL - Did you make a typo?")
  local theme = nil
  local imgw = img:getWidth()
  local imgh = img:getHeight()
  local w = imgw
  local h = imgh
  local text = text or " "
  color1 = color1 or "000000"
  color2 = color2 or color1
  color3 = color3 or color1
  local width_bigger = true
  -- It's going to be mostly square buttons, this should work 95% of the time 
  if w > h then
    w = w / 5
  elseif h > w then
    h = h / 5
    width_bigger = false
  end
  -- Override in ID if your image does not auto-create correctly (lazy hack)
  if string.find(id, "_h") then width_bigger = false h = imgh / 5 end
  if string.find(id, "_w") then width_bigger = true  w = imgw / 5 end

  -- Cache those quads so we don't have to keep making them, cache is based on the image.
  if not cache_button_quad[img] then
    if width_bigger then
      cache_button_quad[img] = {
        normal = love.graphics.newQuad(0,0,w,h,imgw,imgh),
        hover = love.graphics.newQuad(0+w,0,w,h,imgw,imgh),
        active = love.graphics.newQuad(0+w*2,0,w,h,imgw,imgh),
        enabled = love.graphics.newQuad(0+w*3,0,w,h,imgw,imgh),
        disabled = love.graphics.newQuad(0+w*4,0,w,h,imgw,imgh),
      }
  else
    cache_button_quad[img] = {
      normal = love.graphics.newQuad(0,0,w,h,imgw,imgh),
      hover = love.graphics.newQuad(0,0+h,w,h,imgw,imgh),
      active = love.graphics.newQuad(0,0+h*2,w,h,imgw,imgh),
      enabled = love.graphics.newQuad(0,0+h*3,w,h,imgw,imgh),
      disabled = love.graphics.newQuad(0,0+h*4,w,h,imgw,imgh),
    }
  end
  end
  -- We've hacked the button system in such a way it's easier to pass the text twice. 
  return m.button(text, id, button_active, w, h, theme, cursor_type, x, y, button_quad_draw, img, cache_button_quad[img], text, text_move, color1, color2, color3)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Function Button
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function button_fun_draw(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  local text = extra[6]
  if state == "normal" then
    extra[1](col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  elseif state == "hover" then
    extra[2](col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  elseif state =="active" then
    extra[3](col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  elseif state == "enabled" then
    extra[4](col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  else
    extra[5](col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  end
end

function m.button_function(text, id, button_active, w, h, fun1, fun2, fun3, fun4, fun5, cursor_type, x, y)
  assert(fun1, "Button Function: Function Nil - Did you make a typo?")
  local theme = nil
  -- If we only have one draw function, copy it to all buttons.
  fun2 = fun2 or fun1
  fun3 = fun3 or fun1
  fun4 = fun4 or fun3
  fun5 = fun5 or fun1


  -- Messy, but whatever 
  return m.button(text, id, button_active, w, h, theme, cursor_type, x, y, button_fun_draw, fun1, fun2, fun3, fun4, fun5, text)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Progress Bars

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Progress Horz - Basic
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.progress_x_basic(fill_color, fullness, w, h, x, y, bg_color, outline_color, shader)
  fullness = fullness or 0
  fullness = clamp(fullness, 0, 1)
  -- Update these values 
  w = string_to_number(w) or m.storage.__width
  h = string_to_number(h) or m.storage.__height
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  fill_color = fill_color or m.get_current_theme().color
  bg_color = bg_color or m.get_current_theme().background
  outline_color = outline_color or m.get_current_theme().color

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      local pastshader = love.graphics.getShader()
      draw_rectangle_with_color(outline_color, x, y, w, h)
      draw_rectangle_with_color(bg_color, x+1, y+1, w-2, h-2)
      love.graphics.setShader(shader)
      draw_rectangle_with_color(fill_color, x+2, y+2, math.floor((w-4) * fullness), h-4)
      love.graphics.setShader(pastshader)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Progress Vert - Basic
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.progress_y_basic(fill_color, fullness, w, h, x, y, bg_color, outline_color, shader)
  fullness = fullness or 0
  fullness = clamp(fullness, 0, 1)
  -- Update these values 
  w = string_to_number(w) or m.storage.__width
  h = string_to_number(h) or m.storage.__height
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  fill_color = fill_color or m.get_current_theme().color
  bg_color = bg_color or m.get_current_theme().background
  outline_color = outline_color or m.get_current_theme().color

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      local pastshader = love.graphics.getShader()

      draw_rectangle_with_color(outline_color, x, y, w, h)
      draw_rectangle_with_color(bg_color, x+1, y+1, w-2, h-2)
      -- We want the bar to start from the bottom and go up
      love.graphics.setShader(shader)
      draw_rectangle_with_color(fill_color, x+2, y + 2 + (h-4) - math.floor((h-4)*fullness), w-4, math.floor((h-4) * fullness))
      love.graphics.setShader(pastshader)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Progress Horz - Quad
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local cache_progress_quadx = {}
function m.progress_x_quad(img, fullness, x, y)
  assert(img, "Button QUAD: IMAGE NIL - Did you make a typo?")
  fullness = fullness or 0
  fullness = clamp(fullness, 0, 1)
  local imgw = img:getWidth()
  local imgh = img:getHeight()
  local w = imgw
  local h = imgh/2
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y

  -- Cache those quads so we don't have to keep making them, cache is based on the image.
  if not cache_progress_quadx[img] then
    cache_progress_quadx[img] = {
      empty = love.graphics.newQuad(0,0,w,h,imgw,imgh),
      full = love.graphics.newQuad(0,h,w,h,imgw,imgh),
    }
  end

  -- Throw into our draw queue
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      love.graphics.draw(img, cache_progress_quadx[img].empty, x, y)
      -- store old Scissor
      local sx, sy, swidth, sheight = love.graphics.getScissor()
      love.graphics.setScissor(x, y, math.floor(w * fullness), h)
      love.graphics.draw(img, cache_progress_quadx[img].full, x, y)
      -- Restore old Scissor
      love.graphics.setScissor(sx, sy, swidth, sheight)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Progress Vert - Quad
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local cache_progress_quady = {}
function m.progress_y_quad(img, fullness, x, y)
  assert(img, "Button QUAD: IMAGE NIL - Did you make a typo?")
  fullness = fullness or 0
  fullness = clamp(fullness, 0, 1)
  local imgw = img:getWidth()
  local imgh = img:getHeight()
  local w = imgw/2
  local h = imgh
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y

  -- Cache those quads so we don't have to keep making them, cache is based on the image.
  if not cache_progress_quady[img] then
    cache_progress_quady[img] = {
      empty = love.graphics.newQuad(0,0,w,h,imgw,imgh),
      full = love.graphics.newQuad(w,0,w,h,imgw,imgh),
    }
  end

  -- Throw into our draw queue
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      love.graphics.draw(img, cache_progress_quady[img].empty, x, y)
      -- store old Scissor
      local sx, sy, swidth, sheight = love.graphics.getScissor()
      love.graphics.setScissor(x, y + h - math.floor(h * fullness), w , math.floor(h * fullness))
      love.graphics.draw(img, cache_progress_quady[img].full, x, y)
      -- Restore old Scissor
      love.graphics.setScissor(sx, sy, swidth, sheight)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Progress Horz - image
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.progress_x_image(img, fullness, max_fullness, x, y)
  assert(img, "Button Image: IMAGE NIL - Did you make a typo?")
  fullness = fullness or 0
  max_fullness = max_fullness or fullness
  local imgw = img:getWidth()
  local imgh = img:getHeight()
  local w = imgw
  local h = imgh
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y

  -- Throw into our draw queue
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      for i=1, fullness do
        love.graphics.draw(img, x + (i-1)*imgw, y)
      end
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w * max_fullness
  m.storage.__last_height = h
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Progress Vert - image
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.progress_y_image(img, fullness, max_fullness, x, y)
  assert(img, "Button Image: IMAGE NIL - Did you make a typo?")
  fullness = fullness or 0
  max_fullness = max_fullness or fullness
  local imgw = img:getWidth()
  local imgh = img:getHeight()
  local w = imgw
  local h = imgh
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y

  -- Throw into our draw queue
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      for i=1, fullness do
        love.graphics.draw(img, x, y + (i-1)*imgw)
      end
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h * max_fullness
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Graphs

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Bar Graph
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.bar_graph(table, w, h, x, y)
-- Table should be 
-- { x-name = y-plot (int) }
-- Sort by x name, get higest and lowest value, display 

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Line Graph
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.line_graph(table, w, h, x, y)
-- Table should be 
-- { x-name = y-plot (int) }
-- Sort by x name, get higest and lowest value, display 

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Spider Graph
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local graph_spider_cache = {}
function m.graph_spider(input_table, w, r, x, y)
  -- Update these values 
  w = string_to_number(w)
  local h = w
  r = r or w/2+0.5 -- Dirty line hack
  x = x or 0
  y = y or 0
  x = string_to_number(x)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  if not graph_spider_cache[input_table] then
    -- Log Data 
    graph_spider_cache[input_table]  = {
      centerx = math.floor(w/2),
      centery = math.floor(h/2),
      background_color = input_table.background_color,
      line_color = input_table.line_color,
      text_colors = input_table.text_colors,
      end_colors = input_table.end_colors,
      plot_colors = input_table.plot_colors,
      plot_outline_colors = input_table.plot_outline_colors,
      axis_count = #input_table.data.axis_name,
      axis_name = input_table.data.axis_name,
      axis_adjust = input_table.data.axis_adjust,
      show_axis = input_table.data.axis_name.show,
      plots = input_table.data.plots,
      plot_max_value = input_table.max,
      line_style = input_table.line_style,
      line_width = input_table.line_width,
      internal_line_width = input_table.internal_line_width,
      name = input_table.name,
      cache = input_table.cache,
    }
    graph_spider_cache[input_table].axis_deg = math.rad(360/graph_spider_cache[input_table].axis_count)
  end



  --------------------------------------------------------------
  -- Make cache easy to access 
  --------------------------------------------------------------
  local data_sg = graph_spider_cache[input_table]

  --------------------------------------------------------------
  -- If we're not going to be moving, reccomend enable cache.
  --------------------------------------------------------------
  local draw_poly_with_color_cache = draw_poly_with_color_cache
  if not data_sg.cache then 
    draw_poly_with_color_cache = draw_poly_with_color
  end

  --------------------------------------------------------------
  -- Generate the lines for the graph 
  --------------------------------------------------------------
  data_sg.line_start = {}
  data_sg.line_end_100 = {}
  data_sg.line_end_75 = {}
  data_sg.line_end_50 = {}
  data_sg.line_end_25 = {}
  local cx = data_sg.centerx
  local cy = data_sg.centery
  local adjust_start_axis = math.rad(90)
  for point_number = 1, data_sg.axis_count do
    --------------------------------------------------------------
    -- Graph Spokes - Center  
    --------------------------------------------------------------
    data_sg.line_start[#data_sg.line_start + 1] = cx + x
    data_sg.line_start[#data_sg.line_start + 1] = cy + y

    --------------------------------------------------------------
    -- Graph Spokes - Outside   
    --------------------------------------------------------------
    data_sg.line_end_100[#data_sg.line_end_100 + 1] = r * math.cos(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cx + x
    data_sg.line_end_100[#data_sg.line_end_100 + 1] = r * math.sin(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cy + y

    --------------------------------------------------------------
    -- Graph Spokes - 75   
    --------------------------------------------------------------
    data_sg.line_end_75[#data_sg.line_end_75 + 1] = r * 0.75 * math.cos(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cx + x
    data_sg.line_end_75[#data_sg.line_end_75 + 1] = r * 0.75 * math.sin(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cy + y

    --------------------------------------------------------------
    -- Graph Spokes - 50  
    --------------------------------------------------------------
    data_sg.line_end_50[#data_sg.line_end_50 + 1] = r * 0.50 * math.cos(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cx + x
    data_sg.line_end_50[#data_sg.line_end_50 + 1] = r * 0.50 * math.sin(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cy + y

    --------------------------------------------------------------
    -- Graph Spokes - 25 
    --------------------------------------------------------------
    data_sg.line_end_25[#data_sg.line_end_25 + 1] = r * 0.25 * math.cos(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cx + x
    data_sg.line_end_25[#data_sg.line_end_25 + 1] = r * 0.25 * math.sin(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cy + y
  end

  --------------------------------------------------------------
  -- Generate 1D array of Vec2 Points for Graphing
  --------------------------------------------------------------
  data_sg.plot_these = {}
  for plot_num=1, #data_sg.plots do
    data_sg.plot_these[#data_sg.plot_these + 1] = {}
    local work_plot = data_sg.plot_these[#data_sg.plot_these]
    --print("---")
    for point_number=1, #data_sg.plots[plot_num] do
      local plot_value = data_sg.plots[plot_num][point_number]
      local plot_percent = plot_value/data_sg.plot_max_value
      --print(plot_value, plot_percent)
      -- Values
      work_plot[#work_plot+1] = r * plot_percent * math.cos(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cx + x
      work_plot[#work_plot+1] = r * plot_percent * math.sin(data_sg.axis_deg * (point_number-1) - adjust_start_axis) + cy + y
    end

  end


  --------------------------------------------------------------
  -- We're drawing a lot of stuff we've prepared  
  --------------------------------------------------------------
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      --------------------------------------------------------------
      -- Capture previous drawing globals, replace it with our own.
      -------------------------------------------------------------- 
      local previous_line_style = love.graphics.getLineStyle()
      local previous_line_width = love.graphics.getLineWidth()
      
      love.graphics.setLineStyle(data_sg.line_style)
      love.graphics.setLineWidth(data_sg.line_width)

      --------------------------------------------------------------
      -- Draw the background of our graph if set
      --------------------------------------------------------------
      if data_sg.background_color then
        draw_poly_with_color_cache(data_sg.name .. "background", data_sg.background_color, data_sg.line_end_100, "fill")
      end

      --------------------------------------------------------------
      -- Create Spiderweb 
      --------------------------------------------------------------
      for i=1, #data_sg.line_start, 2 do
        local adjust_i = i
        adjust_i = i + 2
        if adjust_i >  #data_sg.line_start then adjust_i = 1 end

        if data_sg.line_width and data_sg.line_width > 0 then
          draw_line_with_color(
            data_sg.line_color,
            math.floor(data_sg.line_start[i]),
            math.floor(data_sg.line_start[i+1]),
            math.floor(data_sg.line_end_100[i]),
            math.floor(data_sg.line_end_100[i+1])
          )
          draw_line_with_color(
            data_sg.line_color,
            math.floor(data_sg.line_end_100[i]),
            math.floor(data_sg.line_end_100[i+1]),
            math.floor(data_sg.line_end_100[adjust_i]),
            math.floor(data_sg.line_end_100[adjust_i+1])
          )
        end
        -- If we've set intenral lines, then draw.
        if data_sg.internal_line_width and data_sg.internal_line_width > 0 then
          --------------------------------------------------------------
          -- Create Inside Web 
          --------------------------------------------------------------
          local previous_line_width = love.graphics.getLineWidth()
          love.graphics.setLineWidth(data_sg.internal_line_width)
          draw_line_with_color(
            data_sg.line_color,
            math.floor(data_sg.line_end_75[i]),
            math.floor(data_sg.line_end_75[i+1]),
            math.floor(data_sg.line_end_75[adjust_i]),
            math.floor(data_sg.line_end_75[adjust_i+1])
          )
          draw_line_with_color(
            data_sg.line_color,
            math.floor(data_sg.line_end_50[i]),
            math.floor(data_sg.line_end_50[i+1]),
            math.floor(data_sg.line_end_50[adjust_i]),
            math.floor(data_sg.line_end_50[adjust_i+1])
          )
          draw_line_with_color(
            data_sg.line_color,
            math.floor(data_sg.line_end_25[i]),
            math.floor(data_sg.line_end_25[i+1]),
            math.floor(data_sg.line_end_25[adjust_i]),
            math.floor(data_sg.line_end_25[adjust_i+1])
          )
          love.graphics.setLineWidth(previous_line_width)
        end
      end

      --------------------------------------------------------------
      -- Draw on top of our graph
      --------------------------------------------------------------
      local counter_graph_position_clockwise = 1
      for graph_v2pos=1, #data_sg.line_start, 2 do
        --------------------------------------------------------------
        -- Plot Polygons
        --------------------------------------------------------------
        for plot_num=1, #data_sg.plot_these do
          local name = data_sg.name .. plot_num
          if data_sg.plot_outline_colors and #data_sg.plot_outline_colors > 0 then
            local final_color = data_sg.plot_outline_colors[plot_num]
            if not final_color then final_color = data_sg.plot_outline_colors[#data_sg.plot_outline_colors] end
            love.graphics.push()
            love.graphics.translate(0, 1)
            draw_poly_with_color_cache(name, final_color, data_sg.plot_these[plot_num], "fill")
            love.graphics.translate(0, -2)
            draw_poly_with_color_cache(name, final_color, data_sg.plot_these[plot_num], "fill")
            love.graphics.translate(1, 1)
            draw_poly_with_color_cache(name, final_color, data_sg.plot_these[plot_num], "fill")
            love.graphics.translate(-2, 0)
            draw_poly_with_color_cache(name, final_color, data_sg.plot_these[plot_num], "fill")
            love.graphics.pop()
          end

          local final_color = data_sg.plot_colors[plot_num]
          if not final_color then final_color = data_sg.plot_colors[#data_sg.plot_colors] end
          draw_poly_with_color_cache(name, final_color, data_sg.plot_these[plot_num], "fill")
        end



        --------------------------------------------------------------
        -- Display Text 
        -------------------------------------------------------------- 
        if data_sg.show_axis then
          -- Capture old font 
          local oldfont = love.graphics.getFont()
          love.graphics.setFont(input_table.font)
          local final_color = data_sg.text_colors[counter_graph_position_clockwise]
          if not final_color then final_color = data_sg.text_colors[#data_sg.text_colors] end
          local twidth = love.graphics.getFont():getWidth(data_sg.axis_name[counter_graph_position_clockwise])
          local adjax_x = data_sg.axis_adjust[graph_v2pos]
          local adjax_y = data_sg.axis_adjust[graph_v2pos + 1]
          adjax_x = adjax_x or 0
          adjax_y = adjax_y or 0

          draw_text_with_color(
            data_sg.axis_name[counter_graph_position_clockwise],
            data_sg.line_end_100[graph_v2pos] - twidth/2 + adjax_x,
            data_sg.line_end_100[graph_v2pos+1] + adjax_y,
            twidth,
            "center",
            final_color
          )
          love.graphics.setFont(oldfont)
        end
         --------------------------------------------------------------
        -- Up counter
        --------------------------------------------------------------        
        counter_graph_position_clockwise = counter_graph_position_clockwise + 1
      end
      --------------------------------------------------------------
      -- Restore drawing globals we updated
      --------------------------------------------------------------  
      
      love.graphics.setLineStyle(previous_line_style)
      love.graphics.setLineWidth(previous_line_width)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h

end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Tooltip 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Basic Tooltip 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.add_tooltip_basic(text, id_attach_tooltip, tooltip_width, tooltip_pos, theme)
  tooltip_width = string_to_number(tooltip_width)
  local queue_pos = m.get_number_from_id_draw_queue(id_attach_tooltip)
  local draw_queue = m.get_active_ui_draw_queue()
  assert(draw_queue[queue_pos], "Unable to find ID in Queue! ID: " .. id_attach_tooltip)
  local x = draw_queue[queue_pos][5]
  local y = draw_queue[queue_pos][6]
  local w = draw_queue[queue_pos][7]
  local h = draw_queue[queue_pos][8]
  local box_h = 0 -- We need to define this live so we can update the font.
  local theme = m.get_current_theme(theme)
  local position = tooltip_pos or "top"
  local is_vcursor_over = (m.vcursor.element_name == id_attach_tooltip)
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      box_h = get_character_height_include_linebreaks(text, tooltip_width-8)
      if isover(x,y,w,h,m.storage.mousex, m.storage.mousey) or is_vcursor_over then
        if position == "right" then
          x = x + w + 4
        elseif position == "left" then
          x = x - tooltip_width - 4
        elseif position == "top" then
          y = y - box_h - 8
        elseif position == "bottom" then
          y = y + h + 4
        end
        draw_rectangle_with_color(theme.tooltip.border, x, y, tooltip_width, box_h+6)
        draw_rectangle_with_color(theme.tooltip.background, x+1, y+1, tooltip_width-2, box_h+4)
        draw_text_with_color(text, x+4, y+4, tooltip_width-8, "left", theme.tooltip.color)
      end
    end,
    -- Can the cursor land on this?
    false
  }
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Advanced Tooltip 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.add_tooltip_function(text, id_attach_tooltip, myfun, tooltip_width, theme)
  tooltip_width = string_to_number(tooltip_width)
  local queue_pos = m.get_number_from_id_draw_queue(id_attach_tooltip)
  local draw_queue = m.get_active_ui_draw_queue()
  assert(draw_queue[queue_pos], "Unable to find ID in Queue! ID: " .. id_attach_tooltip)
  local x = draw_queue[queue_pos][5]
  local y = draw_queue[queue_pos][6]
  local w = draw_queue[queue_pos][7]
  local h = draw_queue[queue_pos][8]
  local box_h = 0 -- We need to define this live so we can update the font.
  local theme = m.get_current_theme(theme)
  local is_vcursor_over = (m.vcursor.element_name == id_attach_tooltip)
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      box_h = get_character_height_include_linebreaks(text, tooltip_width-8)
      if isover(x,y,w,h,m.storage.mousex, m.storage.mousey) or is_vcursor_over then
        myfun(text,x,y,w,h,box_h,tooltip_width,theme,id_attach_tooltip)
      end
    end,
    -- Can the cursor land on this?
    false
  }
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Other

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.change_font(font)
  m.storage.__current_font = font
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      love.graphics.setFont(font)
    end,
    -- Can the cursor land on this?
    false
  }
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * UI Positioning

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move the drawing pen to the right, based on the width of the last thing added to the UI (or define your own in pixels).
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_right(px)
  px = px or m.storage.__last_width
  px = string_to_number(px)
  m.storage.__pen.x = m.storage.__pen.x + px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move the drawing pen to the left, based on the width of the last thing added to the UI (or define your own in pixels).
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_left(px)
  px = px or m.storage.__last_width
  px = string_to_number(px)
  m.storage.__pen.x = m.storage.__pen.x - px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move the drawing pen to the south, based on the height of the last thing added to the UI (or define your own in pixels).
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_down(px)
  px = px or m.storage.__last_height
  px = string_to_number(px)
  m.storage.__pen.y = m.storage.__pen.y + px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move the drawing pen to the north, based on the height of the last thing added to the UI (or define your own in pixels).
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_up(px)
  px = px or m.storage.__last_height
  px = string_to_number(px)
  m.storage.__pen.y = m.storage.__pen.y - px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move the drawing pen to the right plus your own defined extra, based on the width of the last thing added to the UI (or define your own in pixels).
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_right_and(px)
  px = string_to_number(px)
  px = px + m.storage.__last_width
  m.storage.__pen.x = m.storage.__pen.x + px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move the drawing pen to the left plus your own defined extra, based on the width of the last thing added to the UI (or define your own in pixels).
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_left_and(px)
  px = string_to_number(px)
  px = px + m.storage.__last_width
  m.storage.__pen.x = m.storage.__pen.x - px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move the drawing pen to the south plus your own defined extra, based on the height of the last thing added to the UI (or define your own).
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_down_and(px)
  px = string_to_number(px)
  px = px + m.storage.__last_height
  m.storage.__pen.y = m.storage.__pen.y + px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
 * Move the drawing pen to the north plus your own defined extra, based on the height of the last thing added to the UI (or define your own).
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_up_and(px)
  px = string_to_number(px)
  px = px + m.storage.__last_height
  m.storage.__pen.y = m.storage.__pen.y - px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move the drawing pen to the south and move X to 0, based on the height of the last thing added to the UI .
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_newline(px)
  px = px or 0
  px = string_to_number(px)
  m.storage.__pen.x = m.storage.__pen.basex
  px = px + m.storage.__last_height
  m.storage.__pen.y = m.storage.__pen.y + px
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Reset the pen position to 0/0 based on the defined position of the UI
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Reset the Pen Position 
function m.pen_reset()
  m.storage.__pen.x = m.storage.__pen.basex
  m.storage.__pen.y = m.storage.__pen.basey
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Set the pen position based on the origin x/y
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pen_set(x, y)
  m.pen_reset()
  x = string_to_number(x)
  y = string_to_number(y)
  m.storage.__pen.x = m.storage.__pen.x + x
  m.storage.__pen.y = m.storage.__pen.y + y
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Cursor

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Command to move the cursor Up 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_move_up(dir, details)
  m.get_element_from_node_map(dir, details)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Command to move the cursor Down
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_move_down(dir, details)
  m.get_element_from_node_map(dir, details)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Command to move the cursor Left 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_move_left(dir, details)
  m.get_element_from_node_map(dir, details)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Command to move the cursor Right
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_move_right(dir, details)
    m.get_element_from_node_map(dir, details)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Command to 'click' the active element 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Grab the element from the node map and process it.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_element_from_node_map(key_dir, details)
  if m.vcursor_key_lock then return end
  -- Grab the Node Map of the active ui
  local local_nm = m.get_node_map(m.active_ui_name_get())

  -- Nothing active? Just return.
  if not local_nm then return end

  -- Empty?
  if #local_nm == 0 then return end

  -- Cache the cursor 
  local vcur = m.vcursor

  -- Get the Move Type 
  key_dir = local_nm[vcur.element][7][key_dir]

  -- Number Move Types just move us up and down on the graph
  if type(key_dir) == "number" then
    vcur.element = vcur.element + key_dir
    if vcur.element > #local_nm then
      vcur.element = vcur.element - #local_nm
    end
    if vcur.element < 1 then
      vcur.element = vcur.element + #local_nm
    end
  end

  -- String Move Type, Jump to that Node
  if type(key_dir) == "string" then
    -- Get Node Number By Name 
    -- Set vcur.element 
  end

  -- If it's a function, we run the code.
  -- I have no idea how you could pass a function outside of the dev's control
  -- But disable this if you're doing something weird like using userdata for node maps.
  if type(key_dir) == "function" then
    key_dir()
  end

end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Make cursor appear or disappear
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_toggle_visibility(state)
  -- Change the state, if the state is nil swap the state.
  if type(state) ~= "nil" then
    m.vcursor.visible = state
  else
    m.vcursor.visible = not m.vcursor.visible
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Make cursor appear 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_show()
  m.vcursor.visible = true
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Make cursor disappear 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_hide()
  m.vcursor.visible = false
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Cursor Drawing Functions - Arrow 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_draw_basic_arrow(anix, aniy)
  local x = m.vcursor.x
  local y = m.vcursor.y
  local img = m.texture_arrow

  x = math.floor(x - 8)
  y = y + math.floor(m.vcursor.h/2 - img:getHeight()/2)
  love.graphics.draw(img, x + anix, y + aniy)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Cursor Drawing Functions - Outline 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_draw_basic_outline(anix, aniy)
  anix = math.floor(anix)
  aniy = math.floor(aniy)
  local aw = anix*2
  local ah = aniy*2
  local vcur = m.vcursor
  local pad = vcur.outline_spacing
  local x = vcur.x - pad
  local y = vcur.y - pad
  local w = vcur.w + pad*2
  local h = vcur.h + pad*2
  local white = {1,1,1,0.2}
  local black = {0,0,0,10.75}

  draw_rectangle_with_color(white, x-anix, y-aniy, w+aw, h+ah)

  draw_rectangle_with_color(black, x-anix, y-aniy, w+aw, 1)
  draw_rectangle_with_color(black, x-anix, y-aniy, 1, h+ah)
  draw_rectangle_with_color(black, x-anix, y+aniy+h-1, w+aw, 1)
  draw_rectangle_with_color(black, x+anix+w-1, y-aniy, 1, h+ah)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw the cursor depending on animation and style 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_draw(debug_mode)

  local aniy = 0
  local anix = 0
  local vcur = m.vcursor

  -- If the cursor is not on a named value, don't bother drawing it. 
  if not vcur.element_name then return end

  if vcur.animation == "bounce-x" then
    anix = math.floor(((math.sin(m.vcursor.timer_ani*15)+1)/2)*3)
  end

  if vcur.animation == "bounce-xy" then
    anix = math.floor(((math.sin(m.vcursor.timer_ani*15)+1)/2)*3)
    aniy = math.floor(((math.sin(m.vcursor.timer_ani*15)+1)/2)*3)
  end

  if vcur.animation == "circle-xy" then
    anix = math.floor(((math.sin(m.vcursor.timer_ani*15)+1)/2)*3)
    aniy = math.floor(((math.cos(m.vcursor.timer_ani*15)+1)/2)*3)
  end

  if m.active_ui_name_get() and vcur.visible then
    if vcur.type == "arrow" then
      m.cursor_draw_basic_arrow(anix, aniy)
    end

    if vcur.type == "outline" then
      m.cursor_draw_basic_outline(anix, aniy)
    end

    if debug_mode then
      local lr, lg, lb, la = love.graphics.getColor()

      love.graphics.setColor(0,0,0,1)
      love.graphics.print(tostring(vcur.element_name), 1-1, 1)
      love.graphics.print(tostring(vcur.element_name), 1, 1-1)
      love.graphics.print(tostring(vcur.element_name), 1+1, 1)
      love.graphics.print(tostring(vcur.element_name), 1, 1+1)
      love.graphics.setColor(1,1,1,0.9)
      love.graphics.print(tostring(vcur.element_name), 1, 1)

      love.graphics.setColor(lr,lg,lb,la)
    end
  end

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update the cursor sprite 
  -- Runs in m.update()
--------------------------------------------------------------------------------------------------------------------------------------------------]]--

local goal_bubble = 8
local half_goal_bubble = goal_bubble/2
function m.cursor_update(dt)
  -- Cache the cursor 
  local vcur = m.vcursor

  -- Timer, how long has the cursor been moving for?
  if vcur.is_moving then
    vcur.timer = vcur.timer + dt
  end

  -- Used for some animations, bounce with sin, etc 
  vcur.timer_ani = vcur.timer_ani + dt

  -- If there is no UI active, reset the cursor and stop processing
  -- OPTO: Only reset once 
  if (not m.active_ui_name_get()) then
    vcursor_reset()
    return
  end

  -- If we've changed UIs, reset index.
  if m.active_ui_name_get() ~= vcur.ui_active_check then
    vcur.ui_active_check = m.active_ui_name_get()
    vcursor_reset()
  end

  -- Grab the Node Map of the active ui
  local local_nm = m.get_node_map(m.active_ui_name_get())

  -- If there is no node map then exit
  if not local_nm then return end

  -- Empty? Exit 
  if #local_nm == 0 then return end

  -- If no element is set, or the active UI changed set to first 
  if (not vcur.element) then
    for i=1, #local_nm do
      if not vcur.element then
        vcur.element = i
        vcur.goal_x = local_nm[vcur.element][3]
        vcur.goal_y = local_nm[vcur.element][4]
        vcur.x = local_nm[vcur.element][3]
        vcur.y = local_nm[vcur.element][4]
      end
    end
  end

  -- If the element is out of bounds somehow, reset it.
  if vcur.element > #local_nm or vcur.element < 1 then
    vcur.element = 1
  end


  -- We're going to animate the cursor by giving it a goal and asking the sprite to follow it
  -- that way the animation is not blocking and someone can fast menu.

  -- Update the cursor goal position based on element.
  vcur.goal_x = local_nm[vcur.element][3]
  vcur.goal_y = local_nm[vcur.element][4]

  -- Only bother animating if the goal is different
  if ((vcur.goal_x ~= vcur.x) or (vcur.goal_y ~= vcur.y)) then
    -- Get direction we should move in 
    local vecx, vecy = 0, 0

    -- Get the vector, with - being if matching.
    if vcur.goal_x > vcur.x then vecx = 1 end
    if vcur.goal_x < vcur.x then vecx = -1 end
    if vcur.goal_y > vcur.y then vecy = 1 end
    if vcur.goal_y < vcur.y then vecy = -1 end

    -- Import our speed 
    local speed = vcur.speed

    -- Move towards the goal 
    vcur.x = vcur.x + (vecx * (dt * speed))
    vcur.y = vcur.y + (vecy * (dt * speed))

    -- Set moving unless we're in the goal range.
    vcur.is_moving = true

    -- No Shaking when moving, snap where possible.
    if math.abs(math.abs(vcur.y) - math.abs(vcur.goal_y)) < half_goal_bubble then
      vcur.y = vcur.goal_y
    end

    if math.abs(math.abs(vcur.x) - math.abs(vcur.goal_x)) < half_goal_bubble then
      vcur.x = vcur.goal_x
    end

    -- Checking if we're in the goal-range for the cursor.     
    if isover(vcur.x, vcur.y, 1, 1, vcur.goal_x-half_goal_bubble, vcur.goal_y-half_goal_bubble, goal_bubble, goal_bubble) or vcur.timer > 0.05 then
      vcur.x = vcur.goal_x
      vcur.y = vcur.goal_y
      vcur.is_moving = false
      vcur.timer = 0
    end
  end

  -- Width and Height for Rectangle Selection.
  vcur.w = local_nm[vcur.element][5]
  vcur.h = local_nm[vcur.element][6]

  -- Set the name of the current element 
  vcur.element_name = local_nm[vcur.element][1]

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Cursor Press
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.vcursor_press_confirm(key)
  m.vcursor_key = key
end
function m.vcursor_press_left(key)
  m.vcursor_left = key
end
function m.vcursor_press_right(key)
  m.vcursor_right = key
end
function m.vcursor_press_up(key)
  m.vcursor_up = key
end
function m.vcursor_press_down(key)
  m.vcursor_down = key
end

return m