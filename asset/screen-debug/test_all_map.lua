
local scene = {}

local function update_map_render_queue() 
  local current_map_draw_commands = Map.draw.area(Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y())
  --local current_map_draw_commands = Map.draw.area()
  if current_map_draw_commands then 
      for i = 1, #current_map_draw_commands do 
          Draw_order.queue(current_map_draw_commands[i][1], current_map_draw_commands[i][2])
      end
  end
  -- Remove Later
    Draw_order.queue(Pixelscreen.mouse.get_y(), function() love.graphics.rectangle("fill", Pixelscreen.mouse.get_x() - 8, Pixelscreen.mouse.get_y() - 31, 16, 32)end)
end

function scene:update(dt)
  Map.update(dt)
  update_map_render_queue() 

end

function scene:draw()
  Pixelscreen.start()
  Camera.record(Pixelscreen.mouse.get_x() - 8, Pixelscreen.mouse.get_y() - 32)

  love.graphics.setColor(1,1,1,1)
  love.graphics.setBlendMode( "alpha", "alphamultiply" )
  Draw_order.execute()

  love.graphics.setColor(0.5,0.5,0.5,1)
  love.graphics.setBlendMode( "multiply", "premultiplied" )
  love.graphics.rectangle("fill", 0, 0, 1000, 1000)
  love.graphics.rectangle("fill", 0, 0, 32, 32)



  love.graphics.setColor(1,1,1,1)

  Camera.stop_record()
  Pixelscreen.stop()
  if not love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
    love.graphics.print(Pixelscreen.mouse.get_x() .. " " .. Pixelscreen.mouse.get_y() .. " " .. Map.tileindex_from_pixels(Pixelscreen.mouse.get_x(),Pixelscreen.mouse.get_y()), 200, 200)
  end
end


function scene:keypressed(key, scan, isrepeat)
  if key == "x" then
    Gamestate.switch(Debug_screen.menu)
  end
  if key == "y" then
    Map.set_tile(1, 46, "OnTop")
  end
  if key == "z" then
    Map.set_tilearea(27, {3, 0,3,0,3,3,3,0,3,0}, "OnTop")
  end
end

return scene