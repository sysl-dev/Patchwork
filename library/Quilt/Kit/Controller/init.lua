local m = {
  __NAME        = "Quilt-Kit-Controller",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Uses Baton as a backbone",
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
  * Vibrate Controller?
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.enable_buzz = true

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

local function stringSplitSingle(str,sep)
  local return_string={}
  local n=1
  for w in str:gmatch("([^"..sep.."]*)") do
      return_string[n] = return_string[n] or w -- only set once (so the blank after a string is ignored)
      if w=="" then
          n = n + 1
      end -- step forwards on a blank but not a string
  end
  return return_string
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update if you call Baton Something Else 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local Baton = Baton

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Debug Information 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.get_all_joysticks() 
  local joysticks = love.joystick.getJoysticks()
  local jdetails = {}
  print("", "Name", "Vibration?", "GUID")
  for _, joystick in ipairs(joysticks) do
      local mapping = stringSplitSingle(tostring(joystick:getGamepadMappingString()) .. "a,padding,string",",")
      --[[
      dprint("Number " .. i .. " --------------------------------" .. tostring(joystick))
      dprint("START JOYSTICK NAME:"..joystick:getName())
      dprint("START JOYSTICK NAME:".. mapping[2])
      dprint("START JOYSTICK INFO:"..joystick:getDeviceInfo())
      dprint("START JOYSTICK Index:"..joystick:getConnectedIndex())
      dprint("START JOYSTICK IsGamepad:".. tostring(joystick:isGamepad()))
      dprint("START JOYSTICK Vibrate?:".. tostring(joystick:isVibrationSupported()))
      dprint("START JOYSTICK Guid:".. tostring(joystick:getGUID()))
      dprint("START JOYSTICK ID:".. tostring(joystick:getID()))
      dprint("START JOYSTICK Connected?:".. tostring(joystick:isConnected()))]]--
      jdetails[#jdetails+1] = {
          tostring(mapping[2]),
          tostring(joystick:getName()),
          tostring(joystick:isVibrationSupported()),
          tostring(joystick:getGUID())
      }
      print(table.concat(jdetails[#jdetails], " | "))
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Vibrate the controller 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.buzz(controller, str, str2)
  if not m.enable_buzz then return end
  str2 = str2 or str 
  if not controller then return end
  print(controller:isVibrationSupported())
  if controller:isVibrationSupported() then 
      local vibe = controller:setVibration( str, str2, 0.2 )
      print(vibe)
  end
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Button Cheat Notes  
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[    XINPUT         XONY           NIN
          Y              🔺           X 
      X       B      🔳    ⭕      Y    A 
          A              ✖            B
      LT L R RT       L2 L1 R1 R2   ZL L R ZR 
      win Start      share options  select start 
]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Define Layout 
  -- Note: Need to find some way to detect controlers, possibly rebind from menu?
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.bind_controls()
  m.player1 = Baton.new {
    controls = {
      left = {'key:left', 'axis:leftx-', 'button:dpleft'},
      right = {'key:right', 'axis:leftx+', 'button:dpright'},
      up = {'key:up', 'axis:lefty-', 'button:dpup'},
      down = {'key:down', 'axis:lefty+', 'button:dpdown'},
      confirm = {'key:a', 'button:a'},
      back = {'key:s', 'button:b'},
      run = {'key:d', 'button:x'},
      menu = {'key:f', 'button:y', 'button:start'},
    },
    pairs = {
      move = {'left', 'right', 'up', 'down'}
    },
    joystick = love.joystick.getJoysticks()[1],
  }
end m.bind_controls()


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Player 1 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--

function m.character(actor_name, dt)
  -- Cache the sprite 
  local current_actor = Map.actor.get_by_name(actor_name)

  -- Update Character Controller Timers 
  current_actor.warp_timer = current_actor.warp_timer - dt

  -- If the character controller is locked just update timers and return.
  if Map.current.is_player_locked then return end

  -- Check what's under the player (Warp/Event)
  if not m.filter_under_player_check then 
    function m.filter_under_player_check(query_actor)
      if query_actor.sprite_type == "warp" or query_actor.sprite_type == "event" then 
        return true
      else
        return false
      end
    end
  end

  -- Check what's under the player (Warp/Event)
  if not m.filter_interaction_check then 
    function m.filter_interaction_check(query_actor)
      if query_actor.sprite_type == "sign" or query_actor.sprite_type == "npc" then 
        return true
      else
        return false
      end
    end
  end
  
  -- Check what's in front of the player (Collision)
  if not m.filter_adjust_player then 
    function m.filter_adjust_player(query_actor)
      if query_actor.collision and query_actor.sprite_type == "wall" then 
        return true
      elseif query_actor.collision_round then 
        return true 
      else
        return false 
      end
    end
  end

  -- If we're cutscene locked, return 
  if current_actor.locked then return end

  -- Process Movement, setting facing manually for responsive movement.
  local move_vector_x, move_vector_y = 0,0
  if Controller.player1:down('up') then
    move_vector_y = -1 
    Map.actor.try_change_facing(current_actor, 4)
  end
  if Controller.player1:down('down') then
    move_vector_y = 1 
    Map.actor.try_change_facing(current_actor, 1)
  end
  if Controller.player1:down('left') then
    move_vector_x = -1 
    Map.actor.try_change_facing(current_actor, 2)
  end
  if Controller.player1:down('right') then
    move_vector_x = 1 
    Map.actor.try_change_facing(current_actor, 3)
  end

  ---------------------------------------------------------------
  -- This whole mess of code is just for nudging the player    --
  -- around corners to make the controls feel good.            --
  -- It's always going to be a little messy because we         -- 
  -- have to check the sensors depending on direction          --
  ----------------------------------------------------------------
  -- Locals 
  local found_actors, number_of_items_found, cx, cy, adjcx, adjcy
  local check_if_we_are_touching_both_sensors = 0

  -- Are we moving or are we stopped?
  local move_direction_or_stopped = 0

  -- Depending on our vector, pass along our facing as a short hand to access the direction table.
  if move_vector_y == -1 then move_direction_or_stopped = 4 end
  if move_vector_y == 1  then move_direction_or_stopped = 1 end
  if move_vector_x == -1 then move_direction_or_stopped = 2 end
  if move_vector_x == 1  then move_direction_or_stopped = 3 end

  -- We check around the character depending our direction.
  --     . .
  --    :[p]:
  --     . .
  
  -- Table is based on characters height/width adding 1 where requried. 
  if not m.sensor_direction_table then 
    m.sensor_direction_table = {0,current_actor.height/2 + 1,-(current_actor.width/2 + 1),0,current_actor.width/2 + 1,0,0,-(current_actor.height/2 + 1)}
  end

  -- Are we moving? Great! 
  if move_direction_or_stopped ~= 0 then 
    -- movement_facing_fixed is a special flag that is used along side of fixed facing
    -- so we don't override locked facing if we're using it for 
    -- something else 
    current_actor.movement_facing_fixed = false

    -- Generate out adjustment values 
    cx = current_actor.x+current_actor.width/2
    cy = current_actor.y+current_actor.height/2
    cx = cx + m.sensor_direction_table[move_direction_or_stopped*2 - 1]
    cy = cy + m.sensor_direction_table[move_direction_or_stopped*2]

    -- Moving up or down - Check left and right x in facing direction.
    if move_direction_or_stopped == 1 or move_direction_or_stopped == 4 then 
      adjcx = cx - current_actor.width/2
      found_actors, number_of_items_found = Map.world:queryPoint(adjcx, cy, m.filter_adjust_player)
      if number_of_items_found > 0 then   
        move_vector_x = move_vector_x + 1
        current_actor.movement_facing_fixed = true
        check_if_we_are_touching_both_sensors = check_if_we_are_touching_both_sensors + 1
      end
      adjcx = cx + current_actor.width/2
      found_actors, number_of_items_found = Map.world:queryPoint(adjcx, cy, m.filter_adjust_player)
      if number_of_items_found > 0 then  
        move_vector_x = move_vector_x - 1
        current_actor.movement_facing_fixed = true
        check_if_we_are_touching_both_sensors = check_if_we_are_touching_both_sensors + 1
      end
    else -- We do the same, but north and south 
      adjcy = cy - current_actor.height/2
      found_actors, number_of_items_found = Map.world:queryPoint(cx, adjcy, m.filter_adjust_player)
      if number_of_items_found > 0 then   
        move_vector_y = move_vector_y + 1
        current_actor.movement_facing_fixed = true
        check_if_we_are_touching_both_sensors = check_if_we_are_touching_both_sensors + 1
      end
      adjcy = cy + current_actor.height/2
      found_actors, number_of_items_found = Map.world:queryPoint(cx, adjcy, m.filter_adjust_player)
      if number_of_items_found > 0 then   
        move_vector_y = move_vector_y - 1
        current_actor.movement_facing_fixed = true
        check_if_we_are_touching_both_sensors = check_if_we_are_touching_both_sensors + 1
      end
    end
    -- If both sensors are touching, animate as normal. Let the player move along a wall without locking animation.
    if check_if_we_are_touching_both_sensors >1 then current_actor.movement_facing_fixed = false end
  end

  -- We finally send the final goal position to the actor.
  current_actor.goal_x = current_actor.x + move_vector_x
  current_actor.goal_y = current_actor.y + move_vector_y


  -- Running (Actor has a run speed that can be set)
  if Controller.player1:down('run') then
    current_actor.is_running = true
  else 
    current_actor.is_running = false
  end

  -- Open Menu 
  if Controller.player1:down('menu') then
    Gamestate.switch(Debug_screen.menu)
  end

  -- Interact With Actors 
  if Controller.player1:down('confirm') then
    if not m.interaction_sensor_table then 
      m.interaction_sensor_table = { -- DLRU
        current_actor.width/2,current_actor.height + 1,
        -1,current_actor.height/2,
        current_actor.width+1,current_actor.height/2,
        current_actor.width/2, -1
      }
    end
    local adjx = 0
    local adjy = 0
    if current_actor.facing > 0 and current_actor.facing < 5 then 
      adjx = m.interaction_sensor_table[current_actor.facing*2-1]
      adjy = m.interaction_sensor_table[current_actor.facing*2]
    end

    found_actors, number_of_items_found = Map.world:queryPoint(
      math.floor(current_actor.x)+adjx,
      math.floor(current_actor.y)+adjy,
       m.filter_interaction_check)
    if number_of_items_found > 0 then
      local found_actor = found_actors[1]
      print(found_actor.name)
    end
  end

  -- Check for Event and Warp Actors
  found_actors, number_of_items_found = Map.world:queryPoint(current_actor.x+current_actor.width/2,current_actor.y+current_actor.height/2, m.filter_under_player_check)
  if number_of_items_found > 0 then
    --print(found_actors[1].name, found_actors[1].sprite_type, current_actor.warp_lock)
    --[[--
    -- WARPS
    --]]--
    if found_actors[1].sprite_type == "warp" and not current_actor.warp_lock and current_actor.warp_timer < 0 then 
      local x = found_actors[1].warp_x
      local y = found_actors[1].warp_y
      -- If we use a - value for the warp then keep the current position 
      if found_actors[1].warp_x < 0 then x = current_actor.x end 
      if found_actors[1].warp_y < 0 then y = current_actor.y end 
      -- Warp type 1 - Intermap
      if not found_actors[1].warp_map then 
        -- If the speed of the effect is 0, then instant warp 
        if found_actors[1].warp_effect_speed < 0 then 
          --[[--
          -- Warp without effect
          --]]--
          Map.actor.teleport(current_actor, x, y, false, true)
          current_actor.warp_lock = true
          current_actor.warp_timer = 0.01
          if found_actors[1].warp_facing > 0 then 
            current_actor.facing = found_actors[1].warp_facing
          end
        else
          --[[--
          -- Warp with effect 
          --]]--
          Timer.script(function(wait)
            Pixelscreen.fade_image(Texture.system.fade[found_actors[1].warp_effect])
            -- Lock the player 
            Map.current.is_player_locked = true
            -- Run and wait for the screen to fade 
            Pixelscreen.fade_out(8)
            while not Pixelscreen.config.fade_done do
              wait(0.1)
            end
            -- Change position on the 
            Map.actor.teleport(current_actor, x, y, false, true)
            current_actor.warp_lock = true
            current_actor.warp_timer = 0.01
            if found_actors[1].warp_facing > 0 then 
              current_actor.facing = found_actors[1].warp_facing
            end
            wait(0.1)
            -- Run and wait for the screen to restore 
            Pixelscreen.fade_in(8)
            while not Pixelscreen.config.fade_done do
              wait(0.1)
            end
            -- Release the player
            Map.current.is_player_locked = false
          end)
        end
      else
        -- Warp type 2 - Other Maps 
        -- Lock warps so we do not bounce back and forward 
        current_actor.warp_lock = true
        current_actor.warp_timer = 0.01
        Map.current.starting_x = x
        Map.current.starting_y = y
        if found_actors[1].warp_facing > 0 then current_actor.facing = found_actors[1].warp_facing end
        Map.current.starting_facing = current_actor.facing
        Map.load_with_effect(found_actors[1].warp_map, Texture.system.fade[found_actors[1].warp_effect], found_actors[1].warp_effect_speed)
      end
    elseif found_actors[1].sprite_type == "event" then 
      print("E") 
      
    end
  else
    current_actor.warp_lock = false
  end

end



return m