local m = {
  __NAME        = "Quilt-Kit-Map-Collision",
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
  * If you import map as something else, change here 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local Map = Map

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


local function get_lua_table_from_string(f)
  local v = _G    -- start with the global table
  for w in string.gmatch(f, "[%w_-]+") do
    --print(w)
    v = v[w]
  end
  return v
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup()
 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Load all collision into the Map.world_collision table
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.load(current_map)
  print("#### BUILDING COLLISION ####")
  print(string.format("Current: %d collision objects", #Map.world_collision))
  print(string.format("Loading collision objects for %s", current_map))
  current_map = current_map or Map.current.map
  current_map = Map.map_files[current_map]
  for map_layer = 1, #current_map.layers do
    local layer = current_map.layers[map_layer]
    local layer_type = layer.type
    local layer_properties = layer.properties

    -- Standard Collision 
    if layer_type == "objectgroup" and layer_properties.object_type == "collision" then 
      local cobj = layer.objects
      for i=1, #cobj do
        if cobj[i].name == "" then cobj[i].name = "collision" end
        Map.world_collision[#Map.world_collision + 1] = {name = tostring(cobj[i].id .. "_" .. cobj[i].name), _type = cobj[i].name, collision = true}
        Map.world.add(Map.world, Map.world_collision[#Map.world_collision],cobj[i].x,cobj[i].y,cobj[i].width,cobj[i].height)
      end
    end
  end
  print(string.format("Loaded: %d collision objects \n", #Map.world_collision))
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Unload all collision out of the Map.world_collision table
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.unload()
  print("#### UNLOADING ALL COLLISION ####")
  local _, number_of_items = Map.world:getItems()
  print(string.format("Unloading: %d collision objects / %d in world", #Map.world_collision, number_of_items))
  for i = #Map.world_collision, 1, -1  do 
    Map.world.remove(Map.world, Map.world_collision[i])
    Map.world_collision[i] = nil
  end
  local _, number_of_items = Map.world:getItems()
  print(string.format("Remaining: %d collision objects / %d in world\n", #Map.world_collision, number_of_items))
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw the currenty loaded collision (Includes Sprites/Fields)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw()
  local collision_items, number_of_items = Map.world:getItems()
  for i = 1, number_of_items do
    local x, y, w, h = Map.world:getRect(collision_items[i])
    if collision_items[i]._type == "collision" then 
      love.graphics.setColor(0.667,0,0,0.4)
    end
    if collision_items[i]._type == "water" then 
      love.graphics.setColor(0,0,0.667,0.4)
    end
    if collision_items[i]._type == "bridge" then 
      love.graphics.setColor(0.66,0,0.667,0.9)
    end
    if collision_items[i]._type == "under_bridge" then 
      love.graphics.setColor(0.76,0,0.767,0.9)
    end
    if collision_items[i]._type == "water" then 
      love.graphics.setColor(0,0,0.667,0.4)
    end
    if collision_items[i]._type == "actor" then 
      love.graphics.setColor(0,0,0.0,0.0)
    end
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.rectangle("fill", x, y, w, 1)
    love.graphics.rectangle("fill", x, y+h-1, w, 1)
    love.graphics.rectangle("fill", x, y, 1, h)
    love.graphics.rectangle("fill", x+w-1, y, 1, h)
    love.graphics.setColor(1,1,1,1)
  end
end

return m