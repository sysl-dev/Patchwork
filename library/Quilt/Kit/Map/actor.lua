local m = {
  __NAME        = "Quilt-Kit-Map-Sprite-Load",
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
-- So we should reserve some sprites
-- 1 - Camera 
-- 2 - Player 
-- 3 - 9 / Party Slots
-- 10+ - Map NPCS

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
  * Setup 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.load(current_map)
  m.unload(current_map)
  current_map = current_map or Map.current.map
  current_map = Map.map_files[current_map]
  for map_layer = 1, #current_map.layers do
    local layer = current_map.layers[map_layer]
    local layer_type = layer.type
    local layer_properties = layer.properties
    if layer_type == "objectgroup" and layer_properties.object_type == "sprite" then
      local cobj = layer.objects
      for i=1, #cobj do
        print(cobj[i].name)
      end
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.unload(current_map)
  current_map = current_map or Map.current.map
  current_map = Map.map_files[current_map]
  for map_layer = 1, #current_map.layers do
    local layer = current_map.layers[map_layer]
    local layer_type = layer.type
    local layer_properties = layer.properties
    
  end
end



function m.draw_debug_names(current_map, scale, cx, cy)
  current_map = current_map or Map.current.map
  current_map = Map.map_files[current_map]
  for map_layer = 1, #current_map.layers do
    local layer = current_map.layers[map_layer]
    local layer_type = layer.type
    local layer_properties = layer.properties
    if layer_type == "objectgroup" and layer_properties.object_type == "sprite" then
      local cobj = layer.objects
      for i=1, #cobj do
        love.graphics.setColor(0,0,0,1)
        love.graphics.print(cobj[i].name, cobj[i].x * scale + cx * scale + 1, cobj[i].y * scale + cy * scale)
        love.graphics.print(cobj[i].name, cobj[i].x * scale + cx * scale - 1, cobj[i].y * scale + cy * scale)
        love.graphics.print(cobj[i].name, cobj[i].x * scale + cx * scale, cobj[i].y * scale + cy * scale + 1)
        love.graphics.print(cobj[i].name, cobj[i].x * scale + cx * scale, cobj[i].y * scale + cy * scale - 1)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(cobj[i].name, cobj[i].x * scale + cx * scale, cobj[i].y * scale + cy * scale)
      end
    end
  end
end

function m.draw_debug_collision(current_map, scale, cx, cy)
  current_map = current_map or Map.current.map
  current_map = Map.map_files[current_map]
  for map_layer = 1, #current_map.layers do
    local layer = current_map.layers[map_layer]
    local layer_type = layer.type
    local layer_properties = layer.properties
    if layer_type == "objectgroup" and layer_properties.object_type == "sprite" then
      local cobj = layer.objects
      for i=1, #cobj do
        love.graphics.setColor(0.5,0.5,0.5,0.7)
        love.graphics.rectangle("fill", cobj[i].x, cobj[i].y, cobj[i].width, cobj[i].height)
        love.graphics.rectangle("fill", cobj[i].x, cobj[i].y, cobj[i].width, 1)
        love.graphics.rectangle("fill", cobj[i].x, cobj[i].y + cobj[i].height - 1, cobj[i].width, 1)
        love.graphics.rectangle("fill", cobj[i].x, cobj[i].y, 1, cobj[i].height)
        love.graphics.rectangle("fill", cobj[i].x + cobj[i].width - 1, cobj[i].y, 1, cobj[i].height)
        love.graphics.setColor(1,1,1,1)
      end
    end
  end
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Draw curent map

--------------------------------------------------------------------------------------------------------------------------------------------------]]--


return m