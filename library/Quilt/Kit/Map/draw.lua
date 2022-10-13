local m = {
  __NAME        = "Quilt-Kit-Map-Draw",
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

  * Draw curent map

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw the background color of the map.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function layer_background_color(current_map)
  if current_map.backgroundcolor then 
    return {0, function()
      love.graphics.setColor(current_map.backgroundcolor[1]/255,current_map.backgroundcolor[2]/255,current_map.backgroundcolor[3]/255,1) 
      love.graphics.rectangle("fill",
        -current_map.width * current_map.tilewidth / 2,
        -current_map.height * current_map.tileheight / 2,
        current_map.width * current_map.tilewidth * 2,
        current_map.height * current_map.tileheight * 2
      )
      love.graphics.setColor(1,1,1,1)
    end}
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Group Layers - I will not use it, so not supported unless I get around to it!
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function layer_group(current_map, layer)
  error("Group layers are currently not supported.")
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Images are behind everything or in front of everything.
  * Repeating images are not supported.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function layer_image(current_map, layer, x, y)
  local image = layer.image
  -- This is terrible, but it works! 
  image = image:gsub("../texture/", "Texture/")
  image = image:gsub(".png", "")
  image = image:gsub("/", ".")
  image = get_lua_table_from_string(image)

  -- If this is not a repeating background then:
  if not layer.repeatx and not layer.repeaty then
    if layer.properties.render_as == "background" then 
      return {0, function()
        love.graphics.draw(image, layer.offsetx, layer.offsety)
      end}
    end 

    if layer.properties.render_as == "y_sort" then 
      return {layer.offsety + image:getHeight(), function()
        love.graphics.draw(image, layer.offsetx, layer.offsety)
      end}
    end 

    if layer.properties.render_as == "over_top" then 
      return {-1, function()
        love.graphics.draw(image, layer.offsetx, layer.offsety)
      end}
    end 
  end

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw the collision as debug information.
  * Text not supported.
  * Polygon not supported
  * Circle not supported.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function layer_object(current_map, layer, x, y)
  return {-1, function()
    local _r, _g, _b, _a = love.graphics.getColor()
    for i=1, #layer.objects do 
      local object = layer.objects[i]
      local shape = object.shape
        if shape == "rectangle" then 
          love.graphics.setColor(Map.current.collision_color)
          love.graphics.rectangle("fill", object.x, object.y, object.width, object.height)
          love.graphics.setColor(Map.current.collision_color_outline)
          love.graphics.rectangle("line", object.x+1, object.y+1, object.width-1, object.height-1)
        end
    end
    love.graphics.setColor(_r, _g, _b, _a)
  end}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Layer Tile Rendering
  -- Changes to tiles on the map stay even if we leave and come back. Consider making a copy of the map data table when loaded in?
  -- This is for full flat layers 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function layer_no_sort(current_map, layer, level, x, y)
  return {level, function()
    -- We only support one tileset.
    local tileset_name = current_map.tilesets[1].name 
    local tileset_quads = Map.tileset_quads["open_rpg"]
    local has_animation = current_map.properties.animation_settings

    local x_range_low  = 1 
    local x_range_high = current_map.width
    local y_range_low  = 1 
    local y_range_high = current_map.height
    -- Range of rendering 
    if x and y then 
      y_range_low = y - Map.current.y_render_distance
      y_range_high = y + Map.current.y_render_distance
      x_range_low = x - Map.current.x_render_distance
      x_range_high = x + Map.current.x_render_distance
      x_range_low = math.max(1, x_range_low)
      x_range_high = math.max(current_map.width, x_range_high)
      y_range_low = math.max(1, y_range_low)
      y_range_high = math.max(current_map.height, y_range_high)
    end
    -- Range of rendering 


    -- limit this to restrict how much we draw.
    for y = y_range_low, y_range_high do 
      for x = x_range_low, x_range_high do 
        -- Getting the current index uses this format. (X Position) + (Y Position - 1) * width of the map. 
        local current_tile = x + (y-1) * current_map.width -- Lua starts at 1, so we take it away here 

        -- Pull the current tile out of the index.
        local tile_value = layer.data[current_tile]

        -- We may go outside of the bounds if we're restricting what we draw.
        -- We also want to reduce effort if there's no tile to draw
        if tileset_quads[tile_value] then
          local animation_position = 0
          if has_animation then 
            if tile_value >= has_animation.start_tile_animation_on then 
              animation_position = Map.current.animation_frame
              --print(has_animation.start_tile_animation_on)
            end
          end
          -- Organize and draw. -- Lua starts at 1, so we take it away here 
          local xpos = 0 + (x - 1) + (x - 1) * (current_map.tilewidth - 1)
          local ypos = 0 + (y - 1) + (y - 1) * (current_map.tileheight - 1)
          love.graphics.draw(Texture.tileset[tileset_name], tileset_quads[tile_value + animation_position], xpos, ypos)
        end
      end
    end
  end}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Layer Tile Rendering
  -- Changes to tiles on the map stay even if we leave and come back. Consider making a copy of the map data table when loaded in?
  -- This is for Y-Sorted Layers
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function layer_slice(current_map, layer, map_y, x, y)
  return {map_y * current_map.tileheight, function()
    -- We only support one tileset.
    local tileset_name = current_map.tilesets[1].name 
    local tileset_quads = Map.tileset_quads["open_rpg"]
    local has_animation = current_map.properties.animation_settings
    local x_range_low  = 1 
    local x_range_high = current_map.width
    -- Range of rendering 
    if x then 
      x_range_low = x - Map.current.x_render_distance
      x_range_high = x + Map.current.x_render_distance
      x_range_low = math.max(1, x_range_low)
      x_range_high = math.max(current_map.width, x_range_high)
    end

    -- limit this to restrict how much we draw.
    for x = x_range_low, x_range_high do 
      -- Getting the current index uses this format. (X Position) + (Y Position - 1) * width of the map. 
      local current_tile = x + (map_y-1) * current_map.width -- Lua starts at 1, so we take it away here 

      -- Pull the current tile out of the index.
      local tile_value = layer.data[current_tile]

      -- We may go outside of the bounds if we're restricting what we draw.
      -- We also want to reduce effort if there's no tile to draw
      if tileset_quads[tile_value] then
        local animation_position = 0
        if has_animation then 
          if tile_value >= has_animation.start_tile_animation_on then 
            animation_position = Map.current.animation_frame
            --print(has_animation.start_tile_animation_on)
          end
        end
        -- Organize and draw. -- Lua starts at 1, so we take it away here 
        local xpos = 0 + (x - 1) + (x - 1) * (current_map.tilewidth - 1)
        local ypos = 0 + (map_y - 1) + (map_y - 1) * (current_map.tileheight - 1)
        love.graphics.draw(Texture.tileset[tileset_name], tileset_quads[tile_value + animation_position], xpos, ypos)
      end
    end
  end}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Sends tiles to the top or bottom of the stack.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function layer_tile(current_map, layer, x, y)
  if layer.properties.render_as == "over_top" then 
    return layer_no_sort(current_map, layer, Map.RENDER_ABOVE, x, y)

  elseif layer.properties.render_as == "background" then 
    return layer_no_sort(current_map, layer, Map.RENDER_BACKGROUND, x, y)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Return a list of draw commands to be used by a y-sort rendering function.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local draw_commands = {}
function m.area(x, y)
  -- Start fresh when drawing.
  draw_commands = {}

  -- If no map is loaded just return.
  if not Map.current.map then return end 

  -- Create a local to hold the current map
  local current_map = Map.map_files[Map.current.map]

  -- Background Color 
  draw_commands[#draw_commands+1] = layer_background_color(current_map)
  if x and y then 
    x = math.floor(x/16)
    y = math.floor(y/16)
  end

  -- Walk though all the layers 
  for map_layer = 1, #current_map.layers do
    local layer = current_map.layers[map_layer]
    local layer_type = layer.type
    local layer_properties = layer.properties
    if layer_type == "group" then 
      draw_commands[#draw_commands+1] = layer_group(current_map, layer)

    elseif layer_type == "imagelayer" then 
      draw_commands[#draw_commands+1] = layer_image(current_map, layer, x, y)

    elseif layer_type == "tilelayer" and layer_properties.render_as ~= "y_sort" then 
      draw_commands[#draw_commands+1] = layer_tile(current_map, layer, x, y)

    elseif layer_type == "tilelayer" and layer_properties.render_as == "y_sort" then 
      for map_y = y - Map.current.y_render_distance, y + Map.current.y_render_distance do 
        draw_commands[#draw_commands+1] = layer_slice(current_map, layer, map_y, x, y)
      end

      -- We only draw collision if we are debugging.
    elseif layer_type == "objectgroup" and layer_properties.object_type == "collision" and Map.current.show_collision then 
      draw_commands[#draw_commands+1] = layer_object(current_map, layer)
    end
  end

  -- Returns a table of draw functions that can be used by a rendering library.
  -- Format: {Render Number, Render Function}
  return draw_commands
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update map animations
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.update(dt, current_map)
  -- Does this map have the animation property?
  local has_animation = current_map.properties.animation_settings
  if has_animation then
    local animation_frames = has_animation.animation_frames or 0 -- If no frames, disable
    local animation_time = has_animation.animation_speed or (0.1) -- If no speed, set to reasonable default
    Map.current.timer_animation = Map.current.timer_animation + dt -- Timer advances at time
    -- advance per animation_time
    if Map.current.timer_animation > animation_time then 
      Map.current.animation_frame = Map.current.animation_frame + 1
      Map.current.timer_animation = 0
    end
    -- Advance until >= animation tiles. (So we can say 4 frames and have it go back to 0 without counting at 0)
    if Map.current.animation_frame >= animation_frames then 
      Map.current.animation_frame = 0 
    end
  end
end

return m