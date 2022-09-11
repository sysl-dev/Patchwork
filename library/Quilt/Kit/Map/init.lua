local m = {
  __NAME        = "Quilt-Kit-Map",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Let's do this whole tiled map thing a little better this time. Note: Still does not support all the features of tiled.",
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

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Load these modules 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local sub_modules = {"draw", }

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Magic Numbers 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.RENDER_ABOVE = -1
m.RENDER_COLOR = 0
m.RENDER_REFLECTIONS = 1
m.RENDER_BACKGROUND = 2
m.RENDER_SPRITE = 3

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Settings
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.current = {
  -- Setup Items
  tileset_table = nil,
  starting_map = nil,
  starting_x = nil,
  starting_Y = nil,

  -- We save this to SRAM
  x = nil,
  y = nil, 
  map = nil,

  -- Debug 
  show_collision = true,
  collision_color = {1,0,0,0.25},
  collision_color_outline = {1,0,0,0.5},

  -- timer
  timer_animation = 0,

  -- animation 
  animation_frame = 0,

  -- Render Distance 
  x_render_distance = 4,
  y_render_distance = 4,

  
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Tileset Quads, created by library
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.tileset_quads = {}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Load all maps into memory
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.map_files = {}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup / We take the path and load all the libraries. 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(path, settings)
  -- Map settings, let's try not to hard code this stuff this time!
  assert(type(settings) == "table", "There must be a settings table!")

  -- Make tileset quads 
  m.create_tilesets(settings.tileset_table, m.tileset_quads)

  -- Load all map files 
  m.map_file_loader(settings.map_folder_path, m.map_files)

  -- Set the active map 
  m.current.map = settings.starting_map

  -- Load all of map's sub modules and run their setup function if it exists.
  for sub = 1, #sub_modules do 
    m[sub_modules[sub]] = require(path .. "." .. sub_modules[sub])
    print("Required:", sub_modules[sub])
    if m[sub_modules[sub]].setup then 
      m[sub_modules[sub]].setup() 
      print("Run Setup:", sub_modules[sub])
    end 
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * update / mostly timers and things
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.update(dt)
  if not Map.current.map then return end 
  local current_map = Map.map_files[Map.current.map]

  -- Does this map have the animation property?
  local has_animation = current_map.properties.animation_settings
  if has_animation then
    local animation_frames = has_animation.animation_frames or 0 -- If no frames, disable
    local animation_time = has_animation.animation_speed or (0.1) -- If no speed, set to reasonable default
    m.current.timer_animation = m.current.timer_animation + dt -- Timer advances at time
    -- advance per animation_time
    if m.current.timer_animation > animation_time then 
      m.current.animation_frame = m.current.animation_frame + 1
      m.current.timer_animation = 0
    end
    -- Advance until >= animation tiles. (So we can say 4 frames and have it go back to 0 without counting at 0)
    if m.current.animation_frame >= animation_frames then 
      m.current.animation_frame = 0 
    end
  end

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Tileset Prep 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Returns a set of quads in a table indexed by number.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.util_tile_slicer(image, tilesize) -- Only supports square tiles.
  local tileset_table = {}
  local counter = 1
  for y = 0, image:getHeight()-1, tilesize do
    for x = 0, image:getWidth()-1, tilesize do
      tileset_table[counter] = love.graphics.newQuad( x, y, tilesize, tilesize, image:getWidth(), image:getHeight())
      counter = counter + 1
    end
  end
  return tileset_table
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Scans the texture folder provided and creates tilesets based on 16x16 blocks OR if the tileset has
  * _# at the end of it it will use that size instead.
  * I don't expect i'll use non x16 tilesets but this is a nice just in case.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.create_tilesets(folder_path, container)
  for k,v in pairs(folder_path) do
    local size = 16
    if type(v) ~= "table" then 
      local _, _, num = string.find(k, "_(%d+)")
      --print(num,  "capture", k) 
      size = num or size
      container[k] = m.util_tile_slicer(v, size)
      print(k)
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Lazy load lua map files in the path provided by setup.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.map_file_loader(folder_path, container)
  folder_path = folder_path or nil
  if folder_path == nil then assert("No Folder Loaded, Exiting.") return end
  local folder_items = love.filesystem.getDirectoryItems(folder_path)
    for i = 1, #folder_items do
      local name = folder_items[i]
      name = name:sub(1, #name-4) -- Strip File Type
      local path = folder_path .. "." .. name
      container[name] = require(path)
    end
end


return m