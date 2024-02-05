local room = {__name = "map_actor_render", __desc = "Testing Map Viewer/Controller"}
local test_control = 1

local function update_map_render_queue() 
  local current_map_draw_commands = Map.draw.area(math.floor(Map.actor[test_control].x), math.floor(Map.actor[test_control].y))
  --local current_map_draw_commands = Map.draw.area()
  if current_map_draw_commands then 
      for i = 1, #current_map_draw_commands do 
          Draw_order.queue(current_map_draw_commands[i][1], current_map_draw_commands[i][2])
      end
  end
end

function room:update(dt)
  if Help.update.stop_runaway_dt(dt) then return end 
  Controller.player1:update(dt)
  Controller.character("PLAYER", dt)
  Map.update(dt)
  Map.actor.update(dt)
  update_map_render_queue()
end

function room:draw()
  Pixelscreen.start()
  Camera.record(Map.actor[test_control].x+6, Map.actor[test_control].y-4)
  love.graphics.setColor(1,1,1,1)
  love.graphics.setBlendMode( "alpha", "alphamultiply" )
  Draw_order.execute()
  room.scale_debug()
  Camera.stop_record()
  Pixelscreen.stop()
  room.unscale_debug()
end


function room:keypressed(key, scan, isrepeat)
  room.keypress_debug(key)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * DEBUG STUFF 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function room.scale_debug()
  if love.keyboard.isDown("0") then
    Map.collision.draw()
    Map.actor.draw_debug_collision()
  end
end

function room.unscale_debug()
  if not love.keyboard.isDown("`") then
    love.graphics.print(Pixelscreen.mouse.get_x() .. " " .. Pixelscreen.mouse.get_y() .. " " .. Map.tileindex_from_pixels(Pixelscreen.mouse.get_x(),Pixelscreen.mouse.get_y()), 200, 200)
  end
  if love.keyboard.isDown("0") then
    Map.actor.draw_debug_names(Pixelscreen.config.current_scale, Camera.current.x, Camera.current.y)
    Map.actor.draw_debug_eggs(Pixelscreen.config.current_scale, Camera.current.x, Camera.current.y)
  end
end

function room.keypress_debug(key)
  if key == "1" then
    Map.load("AAAA_debug0000")
    collectgarbage("collect")
  end
  if key == "2" then
    Map.actor.teleport(Map.actor.get_by_name("PLAYER"), 15, 15, true, false)
  end
  if key == "3" then
    Map.actor.teleport(Map.actor.get_by_name("PLAYER"), 15, 9, true, false)
  end
  if key == "escape" then
    Gamestate.pop()
  end
  if key == "5" then
    Map.set_tile(1, 46, "OnTop")
  end
  if key == "6" then
    local pm = Pixelscreen.mouse
    local selected_tile = Map.tileindex_from_pixels(pm.get_x()-16, pm.get_y()-16)
    Map.set_tilearea(selected_tile, {3, 0,3,0,3,3,3,0,3,0}, "OnTop")
  end
end

return room