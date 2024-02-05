local m = {
  __NAME        = "Patchwork-UI",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Only slightly cursed UI Library.",
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
  __LICENSE_TITLE = "MIT LICENSE"
}
--[[

To Do
  VEGETABLES:
    Start Basic Documentation [Started]

  CURSOR:
    cursor memory [Figure out how to do this best]
    change cursor per button/set of buttons 
    MOUSE - Can't click inactive UI

  NODE MAPPING
    Jump to NAMED NODE when a direction is pressed.

  UI SETTINGS:
    UI Flag - Do not draw unless active

  BUTTONS:
    image_button - In style of basic button but with less color pain 
    function_button - Where there is a draw function provided for each state
    toggle_button (Basic, Image, Function)
      Check Box
      Choice Circle 
    grab_move_button (Basic, Image, Function)

  MORE FEATURES
    Line Graph
    Bar Graph
    Comparison Graphs
    Spider Graph 
    Standard Torus
    Text Box (Simple, no advanced editing)
    Number Picker
    Color Picker
    Whatever this style of UI is called: [<]   00    [>]

  GRADIENT
    Gradient Limit Colors 
      Gradient Rectangle
      Gradient Circle
      Gradient Torus 
      
  PAINFUL ITEMS
    Fake Scrolling Window, Shows X Items, changes what items are in slots when move
    Real Scrolling Window, Items out of view do not render

]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Debug Mode

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.debug = true
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Resources

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Capture the exposed base width/height if avaiable, if not grab the love graphics value.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.basewidth = __BASE_WIDTH__ or love.graphics.getWidth()
m.baseheight = __BASE_HEIGHT__ or love.graphics.getHeight()

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
  -- Grid to lock to 
  __grid = 8,
  -- If width and height are not defined take whole screen.
  __width = m.basewidth,
  __height = m.baseheight,
  -- Cache, last w/h of what we drew 
  __last_width = 0,
  __last_height = 0,
  -- Theme 
  __theme = "default",
  -- Active UI 
  __ui_active = {},
  -- MODE mouse, cursor, both
  __mode = "both"
}

m.vcursor = {
  ui_active_check = "",
  -- default-arrow, outline, custom function, custom image
  default_type = "outline",
  type = "outline",
  -- bounce, bounce-x, bounce-y, ???
  animation = "bounce-x",
  outline_spacing = 2,
}

local function vcursor_reset()
  m.vcursor.active = false
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
   
    -- TOOLTIP STYLE --
    tooltip = {
      color = "0f0f0f",
      background = "ffffcc",
      border = "663300"
    },

    -- BUTTON STYLE --
    button = {
      normal = {
        background = "c0c0c0",
        color = "0f0f0f",
        align = "center",
        border_thickness = 2,
        border_color = {top = "efefef", right = "3f3f3f", bottom = "3f3f3f", left = "efefef",},
        padding = {top = 3, right = 3, bottom = 2, left = 3},
      },
      hover = {
        background = "d0d0d0",
      },
      active = {
        border_color = {top = "3f3f3f", right = "efefef", bottom = "efefef", left = "3f3f3f",},
      },
      enabled = {
        background = "a0c0a0",
        border_color = {top = "3f3f3f", right = "efefef", bottom = "efefef", left = "3f3f3f",},
      },
      disabled = {
        background = "b0b0b0",
        color = "3f3f3f9f",
        border_color = {top = "3f3f3fBf", right = "3f3f3fBf", bottom = "3f3f3fBf", left = "3f3f3fBf",},
      },
    },
  },
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Local Functions 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Convert special string values for size into context values.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function string_to_number(value, value2)
  -- Got a nil? Don't bother. 
  if type(value) == "nil" then return end
  -- Strings are work.
  if type(value) == "string" then 
    -- Calc, crap.
    if string.sub(value, 1,5) == "calc(" then 
      error("Not defined yet: TODO")
    -- % Positioning X
    elseif string.sub(value, -2, -1) == "%w" then 
      return math.floor((tonumber(string.sub(value, 1, -3))/100 * m.storage.__width))
    -- % Positioning Y
    elseif string.sub(value, -2, -1) == "%h" then 
      return math.floor(tonumber(string.sub(value, 1, -3))/100 * m.storage.__height)
    -- Grid Pos
    elseif string.sub(value, -1, -1) == "#" then 
      return math.floor(tonumber(string.sub(value, 1, -2)) * m.storage.__grid)
    -- Center Positioning X
    elseif string.sub(value, -2, -1) == "cw" then 
      return math.floor(m.storage.__width/2 - value2/2)
    -- Center Positioning Y
    elseif string.sub(value, -2, -1) == "ch" then 
      return math.floor(m.storage.__height/2 - value2/2)
    end
    error("Command Not Understood: " .. tostring(value) .. " " .. tostring(value2))
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
  * Lazy Lerping
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function lerp(a, b, c) 
  return a + (b - a) * c;
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Blend Colors 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function color_blend(color1, color2, scale)
  scale = math.min(1, scale)
  scale = math.max(0, scale)
  return    lerp(color1[1], color2[1], scale),
            lerp(color1[2], color2[2], scale), 
            lerp(color1[3], color2[3], scale),
            lerp(color1[4], color2[4], scale)
        
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create a rectangle from an image to allow for lazy shaders.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function draw_1px_rectangle(color, x, y, w, h)
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
  * Create a rectangle from an image to allow for lazy shaders.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function draw_text_capture_color_and_restore(text, x, y, w, align, color)
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
  * Draw a square with a border around it. The border will blend with the background color.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--  
local frame_square_cache = {1,1,1,1} 
local function draw_frame_square(col_bg, col_top, col_right, col_left, col_bottom, frame_width, x, y, w, h)
    draw_1px_rectangle(col_bg, x, y, w, h)
    col_bg = color_read_hex(col_bg)
    col_left = color_read_hex(col_left)
    col_top = color_read_hex(col_top)
    col_right = color_read_hex(col_right)
    col_bottom = color_read_hex(col_bottom)
    for border_calculator=1, frame_width do
      local adj_size = border_calculator - 1
      local adj_over_fw = adj_size/frame_width
      frame_square_cache[1], frame_square_cache[2], frame_square_cache[3], frame_square_cache[4] = color_blend(col_right, col_bg, adj_over_fw)
      draw_1px_rectangle(frame_square_cache,  x+w-1-adj_size,    y+adj_size,      1,    h-adj_size*2)
      frame_square_cache[1], frame_square_cache[2], frame_square_cache[3], frame_square_cache[4] = color_blend(col_left, col_bg, adj_over_fw)
      draw_1px_rectangle(frame_square_cache,   x+adj_size,        y+adj_size,      1,    h-adj_size*2)
      frame_square_cache[1], frame_square_cache[2], frame_square_cache[3], frame_square_cache[4] = color_blend(col_top, col_bg, adj_over_fw)
      draw_1px_rectangle(frame_square_cache,    x+adj_size,        y+adj_size,      w-adj_size*2,    1)
      frame_square_cache[1], frame_square_cache[2], frame_square_cache[3], frame_square_cache[4] = color_blend(col_bottom, col_bg, adj_over_fw)
      draw_1px_rectangle(frame_square_cache, x+adj_size,        y+h-1-adj_size,  w-adj_size*2,    1)
    end
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
function m.define(name, grid, x, y, w, h, mousex, mousey, mouse_buttons_accepted, theme)
  -- Define and update the table settings, we can't use the special string numbers here. 
  name = tostring(name)
  grid = grid or 8
  x = x or 0
  y = y or 0
  w = w or love.graphics.getWidth()
  h = h or love.graphics.getHeight()
  mousex = mousex or love.mouse.getX()
  mousey = mousey or love.mouse.getY()
  mouse_buttons_accepted = mouse_buttons_accepted or 1

  -- Cache our menu, so we can toggle active/inactive for cursor
  if not m.storage.__uis[name] then 
    m.storage.__uis[name] = { 
      settings = {
      active = false,
      mouse_buttons_accepted = mouse_buttons_accepted,
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
  m.storage.__grid = 8
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
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  color = color or m.get_current_theme().background

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      draw_1px_rectangle(color, x, y, w, h)
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
function m.text_format(text,w,align,color,x,y)
  -- Update these values 
  w = string_to_number(w)

  align = align or "left"
  color = color or m.get_current_theme().color
  x = x or 0
  y = y or 0
  x = string_to_number(x, w)
  y = string_to_number(y)
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y
  local h = get_character_height_include_linebreaks(text, w)

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      draw_text_capture_color_and_restore(text, x, y, w, align, color)
    end,
    -- Can the cursor land on this?
    false
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
end



--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * """Basic""" Button States: nomral, hover, active, enabled, disabled
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.button_basic(text, id, button_active, w, h, theme, cursor_type, x, y)

  -- We cache the button state if it's down, that way clicks can happen only once.
  local button_cache = m.get_current_button_cache()
  local cacheid = id 
  if type(button_cache[cacheid]) == "nil" then button_cache[cacheid] = false end 

  local width_set_by_user, height_set_by_user = true, true

  -- Being careful in case this changes in the future. 
  if type(w) == "nil" then 
    width_set_by_user = false
  end

  -- Being careful in case this changes in the future. 
  if type(h) == "nil" then 
    height_set_by_user = false
  end

  -- Update these values 
  w = string_to_number(w)
  h = string_to_number(h)

  -- Button Width and Height can be calculated from the text.
  w = w or (get_character_width(text))

  -- X/Y Position Offsets 
  x = x or 0
  y = y or 0
  x = string_to_number(x, w)
  y = string_to_number(y, h)

  -- Add in the state of the pen 
  x = x + m.storage.__pen.x
  y = y + m.storage.__pen.y

  -- Set aside Text w/x/y for adjustment later 
  local text_w, text_x, text_y = w, x, y

  -- State Management 
  local state = "normal"
  local theme = m.get_current_theme(theme)
  local cursor_type = cursor_type or m.vcursor.default_type
  local state_normal = theme.button["normal"]

  -- Required after grabbing the state  [We don't recalc the hitbox, use at own risk]
  local sn_padding = theme.button[state].padding or  state_normal.padding
  local sn_borderthickness = theme.button[state].border_thickness or state_normal.border_thickness
  local butt_bor_thickness = sn_borderthickness
  
   -- We can accept multiline text for the button, or update the height if the width is too small.
  if width_set_by_user then 
    text_w = text_w - sn_borderthickness * 2 - sn_padding.left - sn_padding.right
  else 
    w = w + sn_borderthickness * 2 + sn_padding.left + sn_padding.right
  end

  -- Center text Y 
  if height_set_by_user then 
    text_y = text_y + (h/2) - (get_character_height_include_linebreaks(text,w)/2)
  else 
    text_y = text_y + sn_padding.top + sn_borderthickness
  end

  -- We can always move the text a set distance, we are using printf.
  text_x = text_x + sn_padding.left + sn_borderthickness

  h = h or (get_character_height_include_linebreaks(text,text_w) + sn_borderthickness * 2 + sn_padding.top + sn_padding.bottom)

  -- Is the mouse over?
  local is_mouse_over = isover(x,y,w,h,m.storage.mousex, m.storage.mousey)
  local is_vcursor_over = (m.vcursor.element_name == id) and (m.active_ui_name_get() == m.vcursor.ui_active_check)
  local is_mouse_down = love.mouse.isDown(m.get_active_ui_settings().mouse_buttons_accepted)
  local is_cursor_button_active = (is_vcursor_over and m.vcursor.active)

  -- Are we over the button? Then we hover!
  if is_mouse_over or is_vcursor_over then 
    state = "hover"
  end 

  -- Buttons are active unless they are not.
  if type(button_active) == "boolean" then 
    if button_active then 
      state = "enabled"
    end
  end


  -- Are we over the button and the mouse buttons accepted are down? We set to active!
  if (is_mouse_over and is_mouse_down or is_cursor_button_active) then
    state = "active"
  else 
    button_cache[cacheid] = false
  end

  -- If the button is disabled throw away hover/active 

  -- Buttons are active unless they are not.
  if type(button_active) == "boolean" then 
    if not button_active then 
      state = "disabled"
    end
  end
  
  -- If we're still active, adjust the text.
  if state == "active" or state == "enabled" then 
    text_y = text_y + 1
  end

  -- Grab the button (butt) colors 
  local state_theme = theme.button[state] or theme.button.normal
  local butt_bg_color = state_theme.background or state_normal.background
  local butt_color = state_theme.color or state_normal.color
  local butt_align = state_theme.align or state_normal.align
  local border_color = state_theme.border_color or state_normal.border_color
  local butt_bor_top = border_color.top  
  local butt_bor_right = border_color.right  
  local butt_bor_bottom = border_color.bottom  
  local butt_bor_left = border_color.left  

  -- Grab the current UI we're working on
  local draw_queue = m.get_active_ui_draw_queue()
  -- Throw all our work in the draw queue.
  draw_queue[#draw_queue + 1] = {
    -- Do a function.
    function()
      draw_frame_square(butt_bg_color, butt_bor_top, butt_bor_right, butt_bor_left,butt_bor_bottom, butt_bor_thickness, x, y, w, h)
      draw_text_capture_color_and_restore(text,text_x,text_y,text_w,butt_align,butt_color)
    end,
    -- Can the cursor land on this? [2]
    true,
    -- Node ID [3]
    id,
    -- Cursor Type [4] 
    cursor_type,
    -- Size of element hitbox [5,6,7,8] 
    x,
    y,
    w,
    h
  }

  -- Store the sizes 
  m.storage.__last_width = w
  m.storage.__last_height = h
  if (state == "active") and (not button_cache[cacheid]) then 
    button_cache[cacheid] = true
    return true 
  else
    return false
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Bar Graph
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.bar_graph(table, w, h, color_table, x, y)
-- Table should be 
-- { x-name = y-plot (int) }
-- Sort by x name, get higest and lowest value, display 

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Line Graph
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.line_graph(table, w, h, color_table, x, y)
-- Table should be 
-- { x-name = y-plot (int) }
-- Sort by x name, get higest and lowest value, display 

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Spider Graph
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.spider_graph(table, w, h, color_table, x, y)
-- Table should be 
-- { x-name = y-plot (0.0 - 100) }
-- Sort by x name, get higest and lowest value, display 
-- Draw Polygon 

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
        draw_1px_rectangle(theme.tooltip.border, x, y, tooltip_width, box_h+6)
        draw_1px_rectangle(theme.tooltip.background, x+1, y+1, tooltip_width-2, box_h+4)
        draw_text_capture_color_and_restore(text, x+4, y+4, tooltip_width-8, "left", theme.tooltip.color)
      end
    end,
    -- Can the cursor land on this?
    false
  }
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Advanced Tooltip 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.add_tooltip_function(text, id_attach_tooltip, myfun, tooltip_width, tooltip_pos, theme)
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
        myfun(text,x,y,w,h,box_h,tooltip_width,theme,tooltip_pos,id_attach_tooltip)
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
  * Move the drawing pen to the south and move X to 0, based on the height of the last thing added to the UI.
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
function m.cursor_move_click()
  m.vcursor.active = true
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Grab the element from the node map and process it.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_element_from_node_map(key_dir, details)
  -- Grab the Node Map of the active ui
  local local_nm = m.get_node_map(m.active_ui_name_get())
  if m.vcursor.active then return end

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
  local vcur = m.vcursor
  local pad = vcur.outline_spacing
  local x = vcur.x - pad
  local y = vcur.y - pad
  local w = vcur.w + pad*2
  local h = vcur.h + pad*2
  local white = {1,1,1,0.2}
  local black = {0,0,0,10.75}

  draw_1px_rectangle(white, x+anix, y+aniy, w, h)
  draw_1px_rectangle(black, x+anix, y+aniy, w, 1)
  draw_1px_rectangle(black, x+anix, y+aniy, 1, h)
  draw_1px_rectangle(black, x+anix, y+aniy+h-1, w, 1)
  draw_1px_rectangle(black, x+anix+w-1, y+aniy, 1, h)
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

  if m.active_ui_name_get() and vcur.visible then
    if vcur.type == "basic_arrow" then 
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
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.cursor_update(dt)
  -- Cache the cursor 
  local vcur = m.vcursor

  -- Timer
  vcur.timer = vcur.timer + dt
  vcur.timer_ani = vcur.timer_ani + dt

  -- Is the cursor currently clicking something 
  m.vcursor.active = false

  -- If there is no UI active, reset the cursor and stop processing
  if (not m.active_ui_name_get()) then
    vcursor_reset()
    return 
  end

  -- Grab the Node Map of the active ui
  local local_nm = m.get_node_map(m.active_ui_name_get())

  -- If there is no node map then exit
    if not local_nm then return end

  -- Empty?
  if #local_nm == 0 then return end

  -- If we've changed UIs, reset index.
  if m.active_ui_name_get() ~= vcur.ui_active_check then 
    vcur.ui_active_check = m.active_ui_name_get()
    vcursor_reset()
  end

  -- If the node map is empty, leave.
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


    local speed = vcur.speed

    -- Move towards the goal 
    vcur.x = vcur.x + (vecx * (dt * speed))
    vcur.y = vcur.y + (vecy * (dt * speed))

    -- Set moving unless we're in the goal range.
    vcur.is_moving = true 

    -- No Shaking when moving, snap where possible.
    if math.abs(math.abs(vcur.y) - math.abs(vcur.goal_y)) < 2 then 
      vcur.y = vcur.goal_y 
    end

    if math.abs(math.abs(vcur.x) - math.abs(vcur.goal_x)) < 2 then 
      vcur.x = vcur.goal_x 
    end

    if isover(vcur.x, vcur.y, 1, 1, vcur.goal_x, vcur.goal_y, 3, 3) then 
      vcur.x = vcur.goal_x
      vcur.y = vcur.goal_y
      vcur.is_moving = false
    end
  end

  -- Width and Height for Rectangle Selection.
  vcur.w = local_nm[vcur.element][5]
  vcur.h = local_nm[vcur.element][6]

  -- Set the name of the current element 
  vcur.element_name = local_nm[vcur.element][1]

end




return m