local m = {
  __NAME        = "Quilt-Kit-Map-Actor",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Lights, Camera, Overloaded Tables, Action.",
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
  * If you import Anim8 as something else, change here 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local Animation = Animation
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Cache for getting actor by name
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.get_by_name_cache = {}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Monkeypatch Print 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local print = print
local debugprint = print
local function print(...)
  if m.debug then
    debugprint(m.__NAME .. ": ", unpack({...}))
  end
end print(m.__DESCRIPTION)

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Shallow copy a table 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function shallowcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in pairs(orig) do
          copy[orig_key] = orig_value
      end
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Player speical collision table 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local player_filter = function(item, other)
  --for k,v in pairs(other) do print(k,v) end print("") for k,v in pairs(item) do print(k,v) end print("")
 if other.collision == false then return 'cross'
  --elseif love.keyboard.isDown("rctrl") then return 'cross'
  elseif love.keyboard.isDown("rctrl") then return 'cross'
    
  elseif item.collision_z < other.collision_z then return 'cross'
  else return 'slide' 
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * NPC speical collision table 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local npc_filter = function(item, other)
  --for k,v in pairs(other) do print(k,v) end print("") for k,v in pairs(item) do print(k,v) end print("")
  if other.collision == false then return 'cross'
  else return 'slide' 
  end
end

local event_filter = function(item, other)
  return 'cross'
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Default Actor Information 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local actor_value_table = {
  _type = "actor",
  id = 0,
  name = "",
  x = 0,
  y = 0,
  z = 0,
  width = 0,
  height = 0,
  rotation = 0,
  goal_x = nil,
  goal_y = nil,
  is_moving = false,
  is_running = false,
  move_filter = event_filter,
  wall_hit_counter = 0,
  --
  wander_pause = false,
  wander_timer_wait = 0,
  movement = "",
  wander_update = true,
  -- 
  animation_speed = 0.2,
  animation_force = false,
  collision = false,
  collision_round = false,
  collision_z = 0,
  disable_reflection = false,
  draw_on_top = false,
  draw_below_all = false,
  facing = 1,
  facing_fixed = false,
  movement_facing_fixed = false,
  flag_hide = "",
  flag_talk = "",
  n = true,
  s = true,
  e = true,
  w = true,
  item_count = 0,
  item_name = "",
  item_special = "",
  light_source = false,
  light_color = "#FFFFFFFF",
  light_type = "square",
  light_image = "",
  script_name = "",
  speed = 64,
  run_speed = 100,
  run_animate_speed = 2,
  sprite_image = nil,
  sprite_image_number = 1,
  sprite_image_type = "normal",
  sprite_type = "warp",
  text_string = "",
  warp_effect = "normal",
  warp_effect_speed = 8,
  warp_timer = 0,
  warp_lock = true,
  warp_map = nil,
  warp_facing = 0,
  warp_x = 0,
  warp_y = 0,
}


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Set up diferent types of animation maps depending on sprite data
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Standard Map (Down, Right, Left Up, 3 Frames of animation.)
local function create_animation_map_3x4(current_actor)
  local img = Texture.sprite[current_actor.sprite_image]
  current_actor["animation_idle_frame"] = 2
  current_actor["animation_grid"] = Animation.newGrid(img:getWidth()/3, img:getHeight()/4, img:getWidth(), img:getHeight())
  current_actor["animation"] = {
    Animation.newAnimation(current_actor["animation_grid"]('1-3',1, 2,1), current_actor["animation_speed"]), -- Down
    Animation.newAnimation(current_actor["animation_grid"]('1-3',2, 2,2), current_actor["animation_speed"]), -- Right 
    Animation.newAnimation(current_actor["animation_grid"]('1-3',3, 2,3), current_actor["animation_speed"]), -- Up 
    Animation.newAnimation(current_actor["animation_grid"]('1-3',4, 2,4), current_actor["animation_speed"]), -- Left
    Animation.newAnimation(current_actor["animation_grid"](2,1,2,2,2,3,2,4), current_actor["animation_speed"]), -- Center-Middle
  }
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup()
 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function create_player_sprite()

  Map.actor[#Map.actor + 1] = shallowcopy(actor_value_table)
  Map.actor[#Map.actor].name = "PLAYER"
  Map.actor[#Map.actor].move_filter = player_filter
  Map.actor[#Map.actor].collision = true
  Map.actor[#Map.actor].x = Map.current.starting_x
  Map.actor[#Map.actor].y = Map.current.starting_y
  Map.actor[#Map.actor].facing = Map.current.starting_facing
  Map.actor[#Map.actor].width = Map.current.player_width + Map.current.resize_sprite_hitbox_value
  Map.actor[#Map.actor].height = Map.current.player_height + Map.current.resize_sprite_hitbox_value
  Map.actor[#Map.actor].sprite_type = "player"
  Map.actor[#Map.actor].sprite_image = "xmasf"
  if Map.actor[#Map.actor].sprite_image_type == "normal" then 
    create_animation_map_3x4(Map.actor[#Map.actor])
  end
  Map.world.add(Map.world, Map.actor[#Map.actor],Map.actor[#Map.actor].x,Map.actor[#Map.actor].y,Map.actor[#Map.actor].width,Map.actor[#Map.actor].height)
end

function m.load(current_map)
  print("#### HIRING ACTORS ####")
  print(string.format("Current: %d actor objects", #Map.actor))
  print(string.format("Loading actor objects for %s", current_map))
  current_map = current_map or Map.current.map
  current_map = Map.map_files[current_map]
  -- Player 
  create_player_sprite()

  -- Other Sprites
  for map_layer = 1, #current_map.layers do
    local layer = current_map.layers[map_layer]
    local layer_type = layer.type
    local layer_properties = layer.properties
    if layer_type == "objectgroup" and layer_properties.object_type == "sprite" then
      local cobj = layer.objects
      for i=1, #cobj do
        -- Get the base actor settings
        Map.actor[#Map.actor + 1] = shallowcopy(actor_value_table)
        -- Update it with changed values [Base]
        Map.actor[#Map.actor].name = cobj[i].name
        Map.actor[#Map.actor].id = cobj[i].id
        Map.actor[#Map.actor].x = cobj[i].x
        Map.actor[#Map.actor].y = cobj[i].y
        Map.actor[#Map.actor].z = cobj[i].properties.z or 0 
        Map.actor[#Map.actor].width = cobj[i].width 
        Map.actor[#Map.actor].height = cobj[i].height 
        Map.actor[#Map.actor].rotation = cobj[i].rotation
        -- Changed values - Properties in the map export 
        Map.actor[#Map.actor].animation_speed = cobj[i].properties.animation_speed or Map.actor[#Map.actor].animation_speed
        Map.actor[#Map.actor].animation_force = cobj[i].properties.animation_force or Map.actor[#Map.actor].animation_force
        Map.actor[#Map.actor].collision = cobj[i].properties.collision or Map.actor[#Map.actor].collision
        Map.actor[#Map.actor].collision_round = cobj[i].properties.collision_round or Map.actor[#Map.actor].collision_round
        Map.actor[#Map.actor].disable_reflection = cobj[i].properties.disable_reflection or  Map.actor[#Map.actor].disable_reflection 
        Map.actor[#Map.actor].draw_on_top = cobj[i].properties.draw_on_top or  Map.actor[#Map.actor].draw_on_top 
        Map.actor[#Map.actor].draw_below_all = cobj[i].properties.draw_below_all or  Map.actor[#Map.actor].draw_below_all 
        Map.actor[#Map.actor].facing = cobj[i].properties.facing or Map.actor[#Map.actor].facing
        Map.actor[#Map.actor].facing_fixed = cobj[i].properties.facing_fixed or Map.actor[#Map.actor].facing_fixed
        Map.actor[#Map.actor].flag_hide = cobj[i].properties.flag_hide or Map.actor[#Map.actor].flag_hide
        Map.actor[#Map.actor].flag_talk = cobj[i].properties.flag_talk or Map.actor[#Map.actor].flag_talk
        -- These are in a sub table in the export and they default true, requires light touch.
        if cobj[i].properties.interact_direction then 
          if cobj[i].properties.interact_direction.n == false then Map.actor[#Map.actor].n = false end
          if cobj[i].properties.interact_direction.s == false then Map.actor[#Map.actor].s = false end
          if cobj[i].properties.interact_direction.e == false then Map.actor[#Map.actor].e = false end
          if cobj[i].properties.interact_direction.w == false then Map.actor[#Map.actor].w = false end
        end
        -- End 
        Map.actor[#Map.actor].is_running = cobj[i].properties.is_running or Map.actor[#Map.actor].is_running
        Map.actor[#Map.actor].item_count = cobj[i].properties.item_count or Map.actor[#Map.actor].item_count
        Map.actor[#Map.actor].item_name = cobj[i].properties.item_name or Map.actor[#Map.actor].item_name
        Map.actor[#Map.actor].item_special = cobj[i].properties.item_special or Map.actor[#Map.actor].item_special
        -- These are in a sub table in the export
        if cobj[i].properties.light_properties then 
          Map.actor[#Map.actor].light_source = cobj[i].properties.light_properties.light_source or Map.actor[#Map.actor].light_source
          Map.actor[#Map.actor].light_color = cobj[i].properties.light_properties.light_color or Map.actor[#Map.actor].light_color
          Map.actor[#Map.actor].light_type = cobj[i].properties.light_properties.light_type or Map.actor[#Map.actor].light_type
          Map.actor[#Map.actor].light_image = cobj[i].properties.light_properties.light_type or Map.actor[#Map.actor].light_image
        end
        -- End
        Map.actor[#Map.actor].movement = cobj[i].properties.movement or Map.actor[#Map.actor].movement
        Map.actor[#Map.actor].script_name = cobj[i].properties.script_name or Map.actor[#Map.actor].script_name
        Map.actor[#Map.actor].speed = cobj[i].properties.speed or Map.actor[#Map.actor].speed
        Map.actor[#Map.actor].run_speed = cobj[i].properties.run_speed or Map.actor[#Map.actor].run_speed
        Map.actor[#Map.actor].run_animate_speed = cobj[i].properties.run_animate_speed or Map.actor[#Map.actor].run_animate_speed
        Map.actor[#Map.actor].sprite_image = cobj[i].properties.sprite_image or Map.actor[#Map.actor].sprite_image
        Map.actor[#Map.actor].sprite_image_type = cobj[i].properties.sprite_image_type or Map.actor[#Map.actor].sprite_image_type
        Map.actor[#Map.actor].sprite_image_number = cobj[i].properties.sprite_image_number or Map.actor[#Map.actor].sprite_image_number
        Map.actor[#Map.actor].sprite_type = cobj[i].properties.sprite_type or Map.actor[#Map.actor].sprite_type
        Map.actor[#Map.actor].text_string = cobj[i].properties.text_string or Map.actor[#Map.actor].text_string
        Map.actor[#Map.actor].warp_effect = cobj[i].properties.warp_effect or Map.actor[#Map.actor].warp_effect
        Map.actor[#Map.actor].warp_effect_speed = cobj[i].properties.warp_effect_speed or Map.actor[#Map.actor].warp_effect_speed
        Map.actor[#Map.actor].warp_lock = cobj[i].properties.warp_lock or Map.actor[#Map.actor].warp_lock
        Map.actor[#Map.actor].warp_map = cobj[i].properties.warp_map or Map.actor[#Map.actor].warp_map
        Map.actor[#Map.actor].warp_x = cobj[i].properties.warp_x or Map.actor[#Map.actor].warp_x
        Map.actor[#Map.actor].warp_y = cobj[i].properties.warp_y or Map.actor[#Map.actor].warp_y
        Map.actor[#Map.actor].warp_facing = cobj[i].properties.warp_facing or Map.actor[#Map.actor].warp_facing

        -- Adjust Hitboxes for NPCS and update event filter
        if Map.actor[#Map.actor].sprite_type == "npc" then 
          Map.actor[#Map.actor].width = Map.actor[#Map.actor].width + Map.current.resize_sprite_hitbox_value
          Map.actor[#Map.actor].height = Map.actor[#Map.actor].height + Map.current.resize_sprite_hitbox_value
          Map.actor[#Map.actor].move_filter = npc_filter
          Map.actor[#Map.actor].goal_x = Map.actor[#Map.actor].x
          Map.actor[#Map.actor].goal_y = Map.actor[#Map.actor].y
        end
        --print(cobj[i].name)
        --print(Utilities.debug_tools.dump_table_clean(Map.actor[#Map.actor]))
        if Map.actor[#Map.actor].sprite_image then 
          if Map.actor[#Map.actor].sprite_image_type == "normal" then 
            create_animation_map_3x4(Map.actor[#Map.actor])
          end
        end

        -- Load the wander table as a clone 
        Map.actor[#Map.actor].movement = cobj[i].properties.movement or Map.actor[#Map.actor].movement
        if Map.actor[#Map.actor].movement ~= "" then 
          Map.actor[#Map.actor].movement = shallowcopy(Map.resources.movement[Map.actor[#Map.actor].movement])
          print("Loaded WQ: ", cobj[i].properties.movement, Map.actor[#Map.actor].movement)
        end

        Map.world.add(Map.world, Map.actor[#Map.actor],Map.actor[#Map.actor].x,Map.actor[#Map.actor].y,Map.actor[#Map.actor].width,Map.actor[#Map.actor].height)
      end
    end
  end
  print(string.format("Loaded: %d actor objects \n", #Map.actor))
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.unload()
  print("#### UNLOADING ALL ACTORS ####")
  local _, number_of_items = Map.world:getItems()
  print(string.format("Unloading: %d collision objects / %d in world", #Map.actor, number_of_items))
  for i = #Map.actor, 1, -1  do 
    Map.world.remove(Map.world, Map.actor[i])
    Map.actor[i] = nil
  end
  local _, number_of_items = Map.world:getItems()
  print(string.format("Remaining: %d collision objects / %d in world\n", #Map.actor, number_of_items))
end



--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Update and related parts 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * special player code 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function check_if_walking_into_wall(dt, current_actor, move_x, move_y, vector_x, vector_y, collisions, collision_count)
  -- Wall Bonking 
  for i=1,collision_count do
    --debugprint('collided with ' .. tostring(collisions[i].other.name))
    if collisions[i].other.collision then 
      current_actor.wall_hit_counter = current_actor.wall_hit_counter + dt
      -- We don't want the player to stop
      if not (current_actor.name == "PLAYER") then 
        current_actor.is_moving = false
      end
    end
    if current_actor.wall_hit_counter > 1 then 
      debugprint(current_actor.name .. "has bonk") 
      current_actor.wall_hit_counter = 0 
    end
  end
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Move
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function update_move(dt, current_actor, move_x, move_y, vector_x, vector_y)
  -- No image, no movement
  if not current_actor.sprite_image then return end

  -- Capture the collision information for later
  local collisions, collision_count

  -- Enable or disable animations / Yes if moving / No if not
  current_actor.is_moving = true
  if (vector_x == 0) and (vector_y == 0) then current_actor.is_moving = false end

  -- Get the speed value
  local speed = current_actor.speed
  if current_actor.is_running then speed = current_actor.run_speed end
  move_x = vector_x * speed * dt 
  move_y = vector_y * speed * dt

  -- Move the sprite (ONLY MOVE FOR THE SPRITES)
  current_actor.x, current_actor.y, collisions, collision_count = Map.world:move(current_actor, current_actor.x + move_x, current_actor.y + move_y, current_actor.move_filter)

  -- Special Player Code 
  --if current_actor.sprite_type == "player" then 
    check_if_walking_into_wall(dt, current_actor, move_x, move_y, vector_x, vector_y, collisions, collision_count)
  --end

end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update looking direction based on vectors
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function update_facing(current_actor, vector_x, vector_y)
  if not current_actor.sprite_image then return end
  if current_actor.facing_fixed then return end
  if current_actor.movement_facing_fixed then return end
  if not (current_actor.facing < 5) then return end
  if vector_y == -1 then 
    current_actor.facing = 4
  end
  if vector_y == 1 then 
    current_actor.facing = 1
  end
  if vector_x == -1 then 
    current_actor.facing = 2
  end
  if vector_x == 1 then 
    current_actor.facing = 3
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update vectors based on goal
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function follow_currently_set_goal(current_actor, vector_x, vector_y)
  -- If goals are nil, don't bother
  if not current_actor.goal_x then return 0, 0 end 
  if not current_actor.goal_y then return 0, 0 end

  if math.floor(current_actor.goal_x) > math.floor(current_actor.x) then 
      vector_x = 1
  end 

  if math.floor(current_actor.goal_x) < math.floor(current_actor.x) then 
      vector_x = -1
  end 

  if math.floor(current_actor.goal_y) > math.floor(current_actor.y) then 
      vector_y = 1
  end 

  if math.floor(current_actor.goal_y) < math.floor(current_actor.y) then 
      vector_y = -1
  end 
  return vector_x, vector_y
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Sprite Image
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function place_sprite_image_actors_in_draw_queue(dt, current_actor)
  if not current_actor.sprite_image then return end

  -- Update the animation in the draw queue, we only need to update the current facing animation
  if current_actor.is_moving or current_actor.animation_force then 
    -- If we're running, animate faster ;
    local animate_speed = dt 
    if current_actor.is_running then animate_speed = animate_speed * current_actor.run_animate_speed end
    current_actor.animation[current_actor.facing]:update(animate_speed)
  else
    current_actor.animation[current_actor.facing]:gotoFrame(current_actor.animation_idle_frame)
  end

  -- Place the animation in the draw queue 
  Draw_order.queue(math.floor(current_actor.y + 1), 
    function() 
      local img = Texture.sprite[current_actor.sprite_image]
      local adjx = math.floor(img:getWidth()/2/3 - current_actor.width/2)
      local adjy = math.floor(img:getHeight()/4 - current_actor.height)
      current_actor.animation[current_actor.facing]:draw(img, math.floor(current_actor["x"] - adjx), math.floor(current_actor["y"] - adjy)) 
    end
  )

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Process Wander Scripts from Map.Resources
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function wander_around(current_actor, dt) 
  if not current_actor.sprite_image then return end
  -- If we have told the sprite to stop wandering, return 
  if current_actor.wander_pause then return end
  -- This is checking if a movement exists, if not then don't bother
  if type(current_actor.movement) ~= "table" then return end
  -- If the wait timer is below zero 
  if current_actor.wander_timer_wait <= 0 then
      -- and we're waiting for an update then 
      if current_actor.wander_update  then 
          -- stop waiting for the update 
          current_actor.wander_update = false
          -- Check the queue for what action we're on.
          if type(current_actor.movement[1][1]) == "string" then 
              -- If it's string, it's a command and we can update right away
              current_actor.wander_update = true
              -- WAIT - sets a wait timer before the next action 
              if current_actor.movement[1][1] == "wait" then 
                  current_actor.wander_timer_wait = current_actor.movement[1][2]
              end
              -- FACE - look in a certain direction
              if current_actor.movement[1][1] == "face" then 
                  current_actor.facing = current_actor.movement[1][2]
                  current_actor.animation[current_actor.facing]:gotoFrame(2)
              end
              -- FORCE ANIMATION - turns on/off the animation
              if current_actor.movement[1][1] == "force_animation" then 
                  current_actor.animation_force = current_actor.movement[1][2]
              end
              -- SET - Powerful Direct Control 
              if current_actor.movement[1][1] == "set" then 
                current_actor[current_actor.movement[1][2]]  = current_actor.movement[1][3] 
            end
              -- SPRITE - change the image the sprite uses for animation, does not update hitbox 
              if current_actor.movement[1][1] == "sprite" then 
                  current_actor.sprite_image = current_actor.movement[1][2]
                  create_animation_map_3x4(current_actor)
              end
          else
              -- We're setting a goal in tile increments based on location.
              local tw, th = Map.get_current_tile_sizes()
              m.set_pixel_goal(current_actor, current_actor.x+current_actor.movement[1][1]*tw, current_actor.y+current_actor.movement[1][2]*th) 
          end
      end
      if (math.floor(current_actor.goal_x) == math.floor(current_actor.x)) and (math.floor(current_actor.goal_y) == math.floor(current_actor.y)) then 
          current_actor.wander_update = true
          current_actor.movement[#current_actor.movement +1] = shallowcopy(current_actor.movement[1])
          table.remove(current_actor.movement, 1) 
      end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update all timers
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function update_timers(current_actor, dt)
  if not current_actor.sprite_image then return end
  -- unlikely to stay on the map long enough to roll over.
  current_actor.wander_timer_wait = current_actor.wander_timer_wait - dt
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Main Update
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.update(dt)
  if dt > 1/12 then return end
  for i = #Map.actor, 1, -1  do 
    -- Reset any vectors in play
    local vector_x, vector_y = 0,0 
    local move_x, move_y = 0,0 
    -- Get our current actor
    local current_actor = Map.actor[i]

    -- Update Actor Wander Timers 
    update_timers(current_actor, dt)
    -- Process Wander Scripts 
    wander_around(current_actor, dt)
    -- Update our Vectors  
    vector_x, vector_y = follow_currently_set_goal(current_actor, vector_x, vector_y)
    -- Process Movement 
    update_move(dt, current_actor, move_x, move_y, vector_x, vector_y)
    -- Face our new directions 
    update_facing(current_actor, vector_x, vector_y)
    -- If we have a sprite image, we get drawn
    place_sprite_image_actors_in_draw_queue(dt, current_actor)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Helper Functions 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Get Actor
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_by_name(name)
  -- TODO - cache finds based on map 
  for i = #Map.actor, 1, -1  do 
    if name == Map.actor[i].name then 
      return Map.actor[i]
    end
  end
  error("No Actor Found By Name: " ..  name)
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Teleport
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.teleport(current_actor, x,y, in_tiles, unsafe)
  print("Trying to teleport:", current_actor.name)
  in_tiles = in_tiles or false 
  unsafe = unsafe or false 
  if in_tiles then 
    x = x * Map.get_current().tilewidth
    y = y * Map.get_current().tileheight
  end
  print("Position: x/y", x, y)
  Map.world:update(current_actor, x, y)
  current_actor.x, current_actor.y = x, y
  current_actor.goal_x, current_actor.goal_y = x, y
  if unsafe then return end
  current_actor.goal_x = current_actor.goal_x + 1
end

function m.set_pixel_goal(current_actor, x, y) 
  current_actor.goal_x = x 
  current_actor.goal_y = y
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Change Facing (Safe)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.try_change_facing(current_actor, facing_number)
  if current_actor.facing_fixed then return false end 
    current_actor.facing = facing_number
    return facing_number
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Debug

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw Names on the real scale.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw_debug_names(scale, cx, cy)
  for i = #Map.actor, 1, -1  do 
    local x = math.floor(Map.actor[i].x)
    local y = math.floor(Map.actor[i].y)
    love.graphics.setColor(0,0,0,1)
    local pos = string.format("\nfPosition: x: %s y: %s", Map.actor[i].x, Map.actor[i].y)
    local posf = string.format("\nPosition: x: %i y: %i", Map.actor[i].x, Map.actor[i].y)
    local goals = string.format("\nGoal: x: %s y: %s", tostring(Map.actor[i].goal_x), tostring(Map.actor[i].goal_y)) 
    local timers = string.format("\nWander Timer: %s", Map.actor[i].wander_timer_wait) 
    local astring = Map.actor[i].name .. goals .. posf .. pos .. timers
    love.graphics.print(astring, x * scale + cx * scale + 1, y * scale + cy * scale)
    love.graphics.print(astring, x * scale + cx * scale - 1, y * scale + cy * scale)
    love.graphics.print(astring, x * scale + cx * scale, y * scale + cy * scale + 1)
    love.graphics.print(astring, x * scale + cx * scale, y * scale + cy * scale - 1)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(astring, x * scale + cx * scale, y * scale + cy * scale)
  end
  
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw Collision shapes
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw_debug_collision()
  for i = #Map.actor, 1, -1  do 
    local x = math.floor(Map.actor[i].x)
    local y = math.floor(Map.actor[i].y)
    local w = math.floor(Map.actor[i].width)
    local h = math.floor(Map.actor[i].height)
    love.graphics.setColor(0.5,0.5,0.5,0.7)
    love.graphics.rectangle("fill", x, y, w, h)
    
    love.graphics.rectangle("fill", x, y, w, 1)
    love.graphics.rectangle("fill", x, y + h - 1, w, 1)
    love.graphics.rectangle("fill", x, y, 1, h)
    love.graphics.rectangle("fill", x + w - 1, y, 1, h)
    love.graphics.setColor(1,1,1,1)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw Debug Eggs
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw_debug_eggs(scale, cx, cy)
  ---@diagnostic disable: need-check-nil
  if not Map.current.actor_collision_image and not Map.current.actor_collision_image_size then return end
  local size = Map.current.actor_collision_image_size
  local image = Map.current.actor_collision_image

  if not m.debug_quads then 
    m.debug_quads = {}
    m.debug_quads.warp = love.graphics.newQuad( 0, 0, size, size, image:getWidth(), image:getHeight() )
    m.debug_quads.sign = love.graphics.newQuad( size, 0, size, size, image:getWidth(), image:getHeight() )
    m.debug_quads.event = love.graphics.newQuad( 0, size, size, size, image:getWidth(), image:getHeight() )
    m.debug_quads.npc = love.graphics.newQuad( size, size, size, size, image:getWidth(), image:getHeight() )
    m.debug_quads.player = love.graphics.newQuad( 0, size*2, size, size, image:getWidth(), image:getHeight() )
    m.debug_quads.camera = love.graphics.newQuad( size, size*2, size, size, image:getWidth(), image:getHeight() )
    m.debug_quads.ally = love.graphics.newQuad( 0, size*2, size, size, image:getWidth(), image:getHeight() )
    m.debug_quads.unknown = love.graphics.newQuad( size, size*2, size, size, image:getWidth(), image:getHeight() )
  end
  
  for i = #Map.actor, 1, -1  do 
    local x = math.floor(Map.actor[i].x)
    local y = math.floor(Map.actor[i].y)
    local w = math.floor(Map.actor[i].width)
    local h = math.floor(Map.actor[i].height)
    local stype = Map.actor[i].sprite_type
    if not stype then stype = "unknown" end
    love.graphics.draw(Map.current.actor_collision_image, m.debug_quads[stype], x * scale + cx * scale + (w*scale/2 - w/4), y * scale + cy * scale+ (h*scale/2 - h/4))
  end
end

return m
