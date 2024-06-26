local m = {
  __NAME = "Quilt-Help",
  __VERSION = "2.0",
  __AUTHOR = "C. Hall (Sysl)",
  __DESCRIPTION = "This is a library that injects a whole bunch of extra functions into Love2D to make development easier.",
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
m.debug = true

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * MonkeyPatch print for the library so we can do some error checking on the fly from the console
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

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Debug Mode

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.love_overrides = true

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Pixel art games can set a bunch of things to make life easier.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
if m.love_overrides then
  -- Pixel Art Drawing Changes 
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  print("nearest_filter: ON")
  love.graphics.setLineStyle("rough")
  print("line_rough: ON")

  -- Faster Debugging 
  io.output():setvbuf("no")
  print("faster_print: ON")

  -- Library Compatability
  table.unpack = unpack
  print("table_unpack: ON")
  string.gfind = string.gmatch
  print("gfind_fix: ON")
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Color 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define the section for the library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.color = {}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Turn a hex string into a Love2D Color 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local color_convert_cache = {}
function m.color.read_hex(color_string)
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
  * Transform a Love2D color's alpha and return it.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.alpha(color, value)
  assert(type(color) == "table", "Color must be in the format {r, g, b, a}.")
  assert(type(value) == "number", "Alpha value must be a number")
  return {color[1], color[2], color[3], value}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Blend two colors.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.blend(color1, color2, scale)
  assert(type(color1) == "table", "First color must be in the format {r, g, b, a}.")
  assert(type(color2) == "table", "Second color must be in the format {r, g, b, a}.")
  scale = math.min(1, scale)
  scale = math.max(0, scale)
  return {
            m.number.lerp(color1[1], color2[1], scale),
            m.number.lerp(color1[2], color2[2], scale), 
            m.number.lerp(color1[3], color2[3], scale),
            m.number.lerp(color1[4], color2[4], scale)
        }
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Returns a table containing a palette from an image, created left to right, top to bottom.  
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.create_palette_table(path_to_image, square_size, named_colors)
  -- Data Check
  assert(type(path_to_image) == "string", "This must be the path to the image, not a love userdata image.")
  assert(type(square_size) == "number", "You must define the size of your colored squares in the palette image.")
  named_colors = named_colors or {}
  assert(type(named_colors) == "table", "named_colors must be a table if defined")

  -- Set up locals
  local image = love.image.newImageData(path_to_image)
  local r, g, b, a = 0, 0, 0, 0
  local i = 1
  local palette_table = { get = {} }


  -- Process Image
  for y = 0, image:getHeight() - 1, square_size do
    for x = 0, image:getWidth() - 1, square_size do
      r, g, b, a = image:getPixel(x, y)
      palette_table[i] = {r, g, b, a}
      i = i + 1
    end
  end

  -- Assign Named Colors
  for k, v in pairs(named_colors) do palette_table.get[k] = palette_table[v] end

  -- Return the final table
  return palette_table
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * RGB -> HSL # Some code from https://github.com/Wavalab/rgb-hsl-rgb/issues/1 | Note: Code free to use.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.convert_rgb_hsl(r, g, b, a)
  -- We can take a table or values
  if type(r) == "table" then
    a = r[4];
    b = r[3];
    g = r[2];
    r = r[1]
  end
  -- We pass alpha along
  a = a or 1
  -- Get the highest/lowest RGB value
  local max, min = math.max(r, g, b), math.min(r, g, b)

  -- Set the base HSL
  local temphsl = (max + min) / 2
  local h, s, l = temphsl, temphsl, temphsl
  -- Achromatic if max = min (Final will be Black-to-White)
  if max == min then
    h = 0
    s = 0
  else -- This has a hue of some sort
    local diff = max - min
    if l > 0.5 then
      s = diff / (2 - max - min)
    else
      s = diff / (max + min)
    end
    -- color size check 
    if max == r then
      h = (g - b) / diff
      if g < b then h = h + 6 end
    elseif max == g then
      h = (b - r) / diff + 2
    elseif max == b then
      h = (r - g) / diff + 4
    end
    -- h is 0-100 (0.0-1.0)
    h = h / 6
  end

  return {h, s, l, a}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * HSL -> RGB # Some code from https://github.com/Wavalab/rgb-hsl-rgb/issues/1 | Note: Code free to use.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.convert_hsl_rgb(h, s, l, a)
  local r, g, b
  -- We can take a table or values
  if type(h) == "table" then
    a = h[4];
    l = h[3];
    s = h[2];
    h = h[1]
  end
  -- We pass alpha along
  a = a or 1

  if s == 0 then
    r = l;
    g = l;
    b = l; -- Color will be white-black
  else
    local function convert(p, q, t)
      if t < 0 then t = t + 1 end
      if t > 1 then t = t - 1 end
      if t < 1 / 6 then return p + (q - p) * 6 * t end
      if t < 1 / 2 then return q end
      if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
      return p
    end
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = convert(p, q, h + 1 / 3)
    g = convert(p, q, h);
    b = convert(p, q, h - 1 / 3)
  end

  return {r, g, b, a}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Reset the color to white
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.reset()
  love.graphics.setColor(1, 1, 1, 1)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Control Color Setting 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.set(value)
  if type(value) == "table" then 
    love.graphics.setColor(value)
  end
  if type(value) == "string" then 
    love.graphics.setColor(m.color.read_hex(value))
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Reset Blend Mode  
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.blend_reset() 
  love.graphics.setBlendMode("alpha", "alphamultiply") 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Capture Color 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.color.previous = {}
function m.color.capture() 
  local r,g,b,a = love.graphics.getColor()
  m.color.previous[1] = r
  m.color.previous[2] = g
  m.color.previous[3] = b
  m.color.previous[4] = a
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Restore Color
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.color.restore() 
  love.graphics.setColor(m.color.previous)
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Content Loader

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define the section for the library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.load = {}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Get all items in a folder, rewrite of:
  * https://love2d.org/wiki/love.filesystem.getDirectoryItems#Recursively_find_and_display_all_files_and_folders_in_a_folder_and_its_subfolders.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.load.get_file_list(folder, settings)
  settings = settings or {}

  local final_file_list = {}
  local filesTable = love.filesystem.getDirectoryItems(folder)
  for i = 1, #filesTable do
    local file = folder .. "/" .. filesTable[i]
    local info = love.filesystem.getInfo(file)
    if info.type == "file" then
      final_file_list[#final_file_list + 1] = {file, "file", file:match("^.+(%..+)$")}
      if final_file_list[#final_file_list][3]:find("/") then final_file_list[#final_file_list][3] = false end
    elseif info.type == "directory" then
      final_file_list[#final_file_list + 1] = {file, "directory", false}
      local table = m.load.get_file_list(file)
      for dir_table = 1, #table do final_file_list[#final_file_list + 1] = table[dir_table] end
    end
  end

  -- This could likely be wrote so it only have to loop through once to check
  -- the conditions. TODO: Consider fixing this // Priority: Low 

  -- Keep only files
  if settings.file_only then
    for i = #final_file_list, 1, -1 do
      if final_file_list[i][2] == "directory" then table.remove(final_file_list, i) end
    end
  end

  -- Keep only the file types in the sent table
  if settings.keep then
    for i = #final_file_list, 1, -1 do
      local keepfile = false
      for keep = 1, #settings.keep do
        local keeptest = final_file_list[i][3] == settings.keep[keep]
        keepfile = keepfile or keeptest
      end
      if not keepfile then table.remove(final_file_list, i) end
    end
  end

  -- Remove the file types in the sent table
  if settings.remove then
    for i = #final_file_list, 1, -1 do
      local remove = false
      for keep = 1, #settings.remove do
        local remove_test = final_file_list[i][3] == settings.remove[keep]
        remove = remove or remove_test
      end
      if remove then table.remove(final_file_list, i) end
    end
  end

  -- Remove no extension
  if settings.has_file_extension then
    for i = #final_file_list, 1, -1 do if final_file_list[i][3] == false then table.remove(final_file_list, i) end end
  end

  return final_file_list
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Image Loader
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.load.texture(name_of_global_table, path)

  -- Create the global table to hold the image assets if not made.
  if not _G[name_of_global_table] then _G[name_of_global_table] = {} end

  -- Grab only the image files
  local image_list = m.load.get_file_list(path, {
    keep = {".png", ".jpg", ".gif", ".bmp"},
  })

  -- For each file
  for i = 1, #image_list do
    -- Remove the path prefix and change all / into .
    local string_without_start_of_path = image_list[i][1]:gsub(path .. "/", "")
    string_without_start_of_path = string_without_start_of_path:gsub("/", ".")

    -- Split into a table of path parts, add the global table start, remove the file extension
    local folder_bits = m.text.split_by(string_without_start_of_path, ".")
    table.insert(folder_bits, 1, name_of_global_table)
    table.remove(folder_bits, #folder_bits)

    m.table.walk_global_assignment(folder_bits, love.graphics.newImage(image_list[i][1]))
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Lua Loader
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.load.flat_lua(name_of_global_table, path)

  -- Create the global table to hold the image assets if not made.
  if not _G[name_of_global_table] then _G[name_of_global_table] = {} end

  -- Grab only the lua files
  local lua_list = m.load.get_file_list(path, {
    keep = {".lua"},
  })

  -- For each file
  for i = 1, #lua_list do

    -- Split into a table of path parts, add the global table start, remove the file extension
    local folder_bits = m.text.split_by(lua_list[i][1], "/")

    -- Remove Extension
    folder_bits[#folder_bits] = folder_bits[#folder_bits]:sub(1, -5)

    -- Flat require the folder, don't worry about levels
    -- TABLE[LAST TABLE NAME] = Require 
    _G[name_of_global_table][folder_bits[#folder_bits]] = require(table.concat(folder_bits, "."))

  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Shader Loader
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.load.flat_shader(name_of_global_table, path)

  -- Create the global table to hold the image assets if not made.
  if not _G[name_of_global_table] then _G[name_of_global_table] = {} end

  -- Grab only the lua files
  local lua_list = m.load.get_file_list(path, {
    keep = {".glsl"},
  })

  -- For each file
  for i = 1, #lua_list do

    -- Split into a table of path parts, add the global table start, remove the file extension
    local folder_bits = m.text.split_by(lua_list[i][1], "/")

    -- Remove glsl extension~
    local shader_name = folder_bits[#folder_bits]:sub(1, -6)

    -- Flat require the folder, don't worry about levels
    -- TABLE[LAST TABLE NAME] = Require 
    _G[name_of_global_table][shader_name] = love.graphics.newShader(table.concat(folder_bits, "/"))

    -- Yell at me if shaders are not valid.
    -- Allow this yell even if debug is turned off.
    local pass, message = love.graphics.validateShader(true, table.concat(folder_bits, "/"))
    if not pass then debugprint("WARNING: \n", table.concat(folder_bits, "/"), "\n", pass, message) end

  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Debug

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define the section for the library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.debug_tools = {}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Check for leaky globals (can't trust libraries as far as you can throw them)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.debug_tools.print_globals()
  local known_globals = {
    "_G",
    "_VERSION",
    "arg",
    "bit",
    "coroutine",
    "debug",
    "io",
    "jit",
    "love",
    "math",
    "module",
    "os",
    "package",
    "require",
    "string",
    "table",
  }

  -- Create to sort later
  local global_list_table = {}

  -- Step though the global namespace items, ignore built in functions
  for name_of_global, value_of_global in pairs(_G) do
    if not string.match(tostring(value_of_global), "builtin#") then
      global_list_table[name_of_global] = #global_list_table + 1
    end
  end

  -- Look at everything and sort it
  local global_list_sorted_table = {}
  for n in pairs(global_list_table) do table.insert(global_list_sorted_table, n) end
  table.sort(global_list_sorted_table)

  -- Print the final list, removing any default globals.
  print("---- Globals ----")
  for _, n in ipairs(global_list_sorted_table) do
    for i = 1, #known_globals do if n == known_globals[i] then n = nil end end
    if n then print("GLOBAL-ITEM: " .. n) end
  end
  print("---- Globals ----")
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Check if shaders are valid.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.debug_tools.test_shader(code)
  local status, message = love.graphics.validateShader( true, code )
  debugprint(status,message,code,"SHADER-------------------")
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * On Screen Debug Details 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.debug_tools.screen_info(settings)
  settings = settings or {}
  local x = settings.x or 5
  local y = settings.y or 5
  local mx = settings.mouse_x or love.mouse.getX
  local my = settings.mouse_y or love.mouse.getY
  local fps = tostring(love.timer.getFPS())
  local draw_calls = tostring(love.graphics.getStats().drawcalls)
  local batch_calls = tostring(love.graphics.getStats().drawcallsbatched)
  local canvas_switches = tostring(love.graphics.getStats().canvasswitches)
  local texture_memory = tostring(love.graphics.getStats().texturememory / 1024 / 1024)
  local infostring = "FPS: " .. fps .. " Draw Calls: " .. draw_calls .. " Batched Calls: " .. batch_calls
  local moreinfo = " texturememory: " .. texture_memory .. "MB canvasswitches: " .. canvas_switches
  local extraline = tostring("Mouse X: " .. mx() .. " Mouse Y: " .. my())
  local string_length = (love.graphics.getWidth()) - 10
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x, y - 1, string_length)
  love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x, y + 1, string_length)
  love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x - 1, y, string_length)
  love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x + 1, y, string_length)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x, y, string_length)
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Mouse 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define the section for the library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.mouse = {}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Quick and dirty mouse_over checker 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.mouse.over(local_x, local_y, local_width, local_height, mouse_x, mouse_y, mouse_width, mouse_height)
  mouse_width = mouse_width or 1
  mouse_height = mouse_height or 1
  return local_x < mouse_x + mouse_width and 
          mouse_x < local_x + local_width and 
          local_y < mouse_y + mouse_height and
          mouse_y < local_y + local_height
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Number 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define the section for the library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.number = {}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Genetic lerp function 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.number.lerp(a, b, c) 
  return a + (b - a) * c;
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  *  Format to match a digital clock view. 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.number.format_timer(time_seconds, settings)
  -- Checking User Input
  assert(type(time_seconds) == "number", "Time sent to clock format must be a number.")
  settings = settings or "all"

  -- Lazy hack for negitive numbers
  local unit = ""
  if time_seconds < 0 then unit = "-" end
  time_seconds = math.abs(time_seconds)

  local hour = string.format("%02.f", math.floor(time_seconds / 3600))
  local minute = string.format("%02.f", math.floor(time_seconds / 60 - (hour * 60)))
  local second = string.format("%02.f", math.floor(time_seconds - hour * 3600 - minute * 60))

  local final_result = unit .. hour .. ":" .. minute .. ":" .. second
  if settings == "hour_minute" then final_result = unit .. hour .. ":" .. minute end
  if settings == "minute_second" then final_result = unit .. minute .. ":" .. second end
  if settings == "second" then final_result = unit .. second end
  return final_result
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Format to match a cash view. (1,000,000.00) 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.number.format_cash(money_value, cents)
  -- Checking User Input
  money_value = tonumber(money_value)
  assert(type(money_value) == "number", "Time sent to cash format must be a number.")

  -- Round to two places
  local final_result = string.format("%.2f", money_value)
  -- Reverse, add commas in groups of three.
  -- This way we get it starting from the end without more work.
  -- (Capture), (Return Capture)(Add Comma)
  final_result = final_result:reverse():gsub("(%d%d%d)", "%1,")
  -- Return the string to normal and return it
  final_result = final_result:reverse()
  -- If we are removing cents, remove the end.
  if not cents then final_result = final_result:sub(1, -4) end
  return final_result
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Return the nearest grid/tile value | Base: 8 / 1-7 = 0, 8-15 = 1, 16... etc
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.number.fix_grid(num, base) 
  return math.floor(num / base) * base 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Get the current time with some lazy formating 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.number.format_current_time()
  --[[
    %a	abbreviated weekday name (e.g., Wed)
    %A	full weekday name (e.g., Wednesday)
    %b	abbreviated month name (e.g., Sep)
    %B	full month name (e.g., September)
    %c	date and time (e.g., 09/16/98 23:48:10)
    %d	day of the month (16) [01-31]
    %H	hour, using a 24-hour clock (23) [00-23]
    %I	hour, using a 12-hour clock (11) [01-12]
    %M	minute (48) [00-59]
    %m	month (09) [01-12]
    %p	either "am" or "pm" (pm)
    %S	second (10) [00-61]
    %w	weekday (3) [0-6 = Sunday-Saturday]
    %x	date (e.g., 09/16/98)
    %X	time (e.g., 23:48:10)
    %Y	full year (1998)
    %y	two-digit year (98) [00-99]
    %%	the character `%´
    ]]--
  local current_time = os.time()
  local default_format = os.date("%A", current_time) -- Wednesday
  local date_format = os.date("%x", current_time) -- "01/14/22"
  local time_format = os.date("%X", current_time) -- "22:03:09"
  local time_format_12h = os.date("%I:%M:%S %p", current_time) -- 07:30:41 PM
  return default_format, date_format, time_format_12h, time_format
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Text 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define the section for the library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.text = {}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Split text into a table by value
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.text.split_by(text_str, text_value)
  local return_table_of_string_parts = {}
  local count_up_string = 1
  for word in text_str:gmatch("([^" .. text_value .. "]*)") do
    return_table_of_string_parts[count_up_string] = return_table_of_string_parts[count_up_string] or word -- only set once (ignore blank after a string)
    -- step forwards only on a blank but not a string
    if word == "" then count_up_string = count_up_string + 1 end
  end
  return return_table_of_string_parts
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Outline Text 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.text.print_outline(settings, ...)
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
  x = x + 1 -- Outline Correction 
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
  * Outline Text (Formatted) 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.text.printf_outline(settings, ...)
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

  limit = limit - 2 -- 1 px shadow, both sides
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

  * Table 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define the section for the library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.table = {}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Walk a table of strings to set a global value
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.table.walk_global_assignment(ordered_table, value)
  -- Walk down the path parts and create the tables as required
  local global_start = _G
  for walk_down_table = 1, #ordered_table do
    if walk_down_table ~= #ordered_table then
      global_start[ordered_table[walk_down_table]] = global_start[ordered_table[walk_down_table]] or {}
      global_start = global_start[ordered_table[walk_down_table]]
    else
      global_start[ordered_table[walk_down_table]] = value
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Dump a table to a string 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.table.dump(atable) 
  if type(atable) == 'table' then
     local s = '{ '
     for k,v in pairs(atable) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. m.table.dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(atable)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Dump a table to a string, but nicer.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.table.dump_clean(atable) 
  if type(atable) == 'table' then
     local s = '\n { '
     for k,v in pairs(atable) do
        if type(k) ~= 'number' then k = '\t'..k..'' end
        s = s .. k ..' = ' .. m.table.dump(v) .. ',\n'
     end
     return s .. '} '
  else
     return tostring(atable)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Graphics 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define the sections for the library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.art = {}
m.art.storage = {}
-- Image for shapes to apply shaders and colors to for new shapes.
m.art.storage.pixel_imagdata_x1 = love.image.newImageData(1, 1); m.art.storage.pixel_imagdata_x1:setPixel(0, 0, 1, 1, 1, 1)
m.art.storage.pixel_image_x1 = love.graphics.newImage(m.art.storage.pixel_imagdata_x1)
local pixel_image_x1 = m.art.storage.pixel_image_x1 -- let's just cache this.
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Hooking and Fallback - If using this in patchwork, grab the background directly, if not do a best guess.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local base = {
  width = __BASE_WIDTH__ or love.graphics.getWidth(),
  height = __BASE_HEIGHT__ or love.graphics.getHeight(),
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Fill Background
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.art.fill_background(padding)
  padding = padding or 0
  love.graphics.rectangle("fill", 0 - padding, 0 - padding, base.width + padding * 2, base.height + padding * 2)
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw a Disk
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.art.draw_disk(x, y, r, total, rotate, dwidth)
  dwidth = dwidth or r / 2

  local function xc()
    love.graphics.arc("fill", x + r, y + r, r, 0 + math.rad(rotate), math.rad(total * 360) + math.rad(rotate), 128)
    love.graphics.arc("fill", x + r, y + r, r, 0 + math.rad(rotate), math.rad(total * 360) + math.rad(rotate), 128)
    love.graphics.circle("fill", x + r, y + r, r -  dwidth)
  end

  love.graphics.stencil(xc, "increment", 1)
  love.graphics.setStencilTest("equal", 2)
  local w, h = r * 2, r * 2
  love.graphics.draw(pixel_image_x1, x + w / 2, y + h / 2, math.rad(0), w, h, w / w / 2, h / h / 2)
  love.graphics.setStencilTest()
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Update 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.update = {}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Stop runaway DT 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.update.stop_runaway_dt(dt, val)
  val = val or (1/10)
  if dt > val then 
    return true
  else 
    return false
  end
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m
