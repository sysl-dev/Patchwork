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
  * This library requires bump.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local Bump = Bump
assert(Bump, "The bump library is required for this class, please update the library to link to it")

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Create our world
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.world = Bump.newWorld(32)
m.world_collision = {}

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
  x_render_distance = 0,
  y_render_distance = 0,
  fixed_x_render_distance = nil,
  fixed_y_render_distance = nil,
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
local lastmap = nil
local function update_render_distance(current_map)
  m.current.x_render_distance =  m.current.fixed_x_render_distance or m.current.x_render_distance 
  m.current.y_render_distance =  m.current.fixed_y_render_distance or m.current.y_render_distance
  if lastmap == m.current.map then return end 
  local tile_width = current_map.tilewidth
  local tile_height = current_map.tileheight
  local game_width = m.current.game_width or BASE_WIDTH
  local game_height = m.current.game_height or BASE_HEIGHT
  m.current.x_render_distance = math.floor(game_width/tile_width/2) + 1
  m.current.y_render_distance = math.floor(game_height/tile_height/2) + 2
  lastmap = m.current.map
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * update / mostly timers and things
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.update(dt)
  if not m.current.map then error("No Map Loaded") end 
  local current_map = m.map_files[m.current.map]
  -- update render distance
  update_render_distance(current_map)

  -- update tile animations
  m.draw.update(dt, current_map)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * unload a map.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.unload()
  for i = #m.world_collision, 1, -1  do 
    m.world_collision[i] = nil
  end

  m.world_collision = {}

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * load a map.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.load(map_name)
  

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Tile Helpers  

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * X/Y in game scale pixels
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.tileindex_from_pixels(x,y)
  if not m.current.map then error("No Map Loaded") end 
  local current_map = m.map_files[m.current.map]
  local tile_size_x = current_map.tilewidth
  local tile_size_y = current_map.tileheight
  x = math.floor(x/tile_size_x)
  y = math.floor(y/tile_size_y)
  local tileindex = (x + (y * current_map.width)) + 1 -- Lua starts at 1
  return tileindex 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Tiled sets the top left tile at 0/0
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.tileindex_from_tiled_cord(x,y)
  if not m.current.map then error("No Map Loaded") end 
  local current_map = m.map_files[m.current.map]
  x = math.floor(x)
  y = math.floor(y)
  local tileindex = (x + (y * current_map.width)) + 1 -- Lua starts at 1
  return tileindex 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Lua respecting starting top left tile at 1/1
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.tileindex_from_cord(x,y)
  if not m.current.map then error("No Map Loaded") end 
  local current_map = m.map_files[m.current.map]
  x = math.floor(x) - 1
  y = math.floor(y) - 1
  local tileindex = (x + (y * current_map.width)) + 1 -- Lua starts at 1
  return tileindex 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Tileindex to tile 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.tileindex_highlight(tileindex)
  if not m.current.map then error("No Map Loaded") end 
  local current_map = m.map_files[m.current.map]
  local x = math.floor(tileindex % current_map.width - 1) * current_map.tilewidth
  local y = math.floor(tileindex / current_map.width) * current_map.tileheight
  love.graphics.setColor(1,0,0,1)
  love.graphics.rectangle("fill", x, y, current_map.tilewidth, current_map.tileheight)
  love.graphics.setColor(1,1,1,1)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Set a tile based on index 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.set_tile(tileindex, tile, layer)
  assert(tileindex and tile and layer, "A Tileindex, Tile and Layer are required.")
  if not m.current.map then error("No Map Loaded") end 
  local current_map = m.map_files[m.current.map]
  local map_layers = current_map.layers
  for layer_number=1, #map_layers do 
    if map_layers[layer_number].name == layer then 
      local oldtile = map_layers[layer_number].data[tileindex]
      map_layers[layer_number].data[tileindex] = tile
      return oldtile, tile
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Set a tilearea based on formated table {width, tile1, tile2 ...}
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.set_tilearea(tileindex, tile_table, layer)
  assert(tileindex and tile_table and layer, "A Tileindex, Tile and Layer are required.")
  if not m.current.map then error("No Map Loaded") end 
  local current_map = m.map_files[m.current.map]
  local map_layers = current_map.layers
  for layer_number=1, #map_layers do 
    local area_count = 0
    local area_add = 0
    if map_layers[layer_number].name == layer then 
      for insert_tiles=0, #tile_table - 2 do 
        if tile_table[insert_tiles+2] ~= 0 then 
          map_layers[layer_number].data[tileindex + insert_tiles + area_add] = tile_table[insert_tiles+2]
        end
        area_count = area_count + 1
        if area_count == tile_table[1] then 
          area_add = area_add + current_map.width - (area_count)
          area_count = 0
        end
      end
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