
local scene = {}
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

local function remove(dt)

  local hyjack = "test2" --test2
  local hx = 0
  local hy = 0
  if love.keyboard.isDown("up")then
    hy = -1 
  end
  if love.keyboard.isDown("down") then
    hy = 1 
  end
  if love.keyboard.isDown("left") then
    hx = -1 
  end
  if love.keyboard.isDown("right") then
    hx = 1    
  end
  Map.actor.get_by_name(hyjack).goal_x = math.floor(Map.actor.get_by_name(hyjack).x + hx)
  Map.actor.get_by_name(hyjack).goal_y = math.floor(Map.actor.get_by_name(hyjack).y + hy)

  -- TODO: Make this a map.control thing or something
  -- TODO: Interaction stuff (A Button, lol)
  -- TODO: Heck yes, split it off. Makes more sense and removes noice from the actor
  hyjack = "PLAYER" --test2
  hx = 0
  hy = 0
  if love.keyboard.isDown("w")then
    hy = -1 
  end
  if love.keyboard.isDown("s") then
    hy = 1 
  end
  if love.keyboard.isDown("a") then
    hx = -1 
  end
  if love.keyboard.isDown("d") then
    hx = 1    
  end
  if love.keyboard.isDown("rshift") then
    Map.actor.get_by_name(hyjack).speed = 128
  else 
    Map.actor.get_by_name(hyjack).speed = 64
  end
  Map.actor.get_by_name(hyjack).goal_x = math.floor(Map.actor.get_by_name(hyjack).x + hx)
  Map.actor.get_by_name(hyjack).goal_y = math.floor(Map.actor.get_by_name(hyjack).y + hy)

end

function scene:update(dt)

  Map.update(dt)
  Map.actor.update(dt)
  update_map_render_queue() 
  remove(dt)
end

function scene:draw()
  Pixelscreen.start()
  Camera.record(Map.actor[test_control].x, Map.actor[test_control].y)
  --Camera.record(Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y())

  love.graphics.setColor(1,1,1,1)
  love.graphics.setBlendMode( "alpha", "alphamultiply" )
  Draw_order.execute()

  if love.keyboard.isDown("0") then
    Map.collision.draw()
    Map.actor.draw_debug_collision()
  end



  Camera.stop_record()
  Pixelscreen.stop()
  if not love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
    love.graphics.print(Pixelscreen.mouse.get_x() .. " " .. Pixelscreen.mouse.get_y() .. " " .. Map.tileindex_from_pixels(Pixelscreen.mouse.get_x(),Pixelscreen.mouse.get_y()), 200, 200)
  end
  if love.keyboard.isDown("0") then
    Map.actor.draw_debug_names(Pixelscreen.config.current_scale, Camera.current.x, Camera.current.y)
    Map.actor.draw_debug_eggs(Pixelscreen.config.current_scale, Camera.current.x, Camera.current.y)
  end
end


function scene:keypressed(key, scan, isrepeat)
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


  if key == "x" then
    Gamestate.switch(Debug_screen.menu)
  end
  if key == "y" then
    Map.set_tile(1, 46, "OnTop")
  end
  if key == "z" then
    local pm = Pixelscreen.mouse
    local selected_tile = Map.tileindex_from_pixels(pm.get_x()-16, pm.get_y()-16)
    Map.set_tilearea(selected_tile, {3, 0,3,0,3,3,3,0,3,0}, "OnTop")
  end
end

return scene