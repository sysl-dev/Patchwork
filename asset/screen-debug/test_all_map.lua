
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
    Draw_order.queue(Pixelscreen.mouse.get_y(), function() love.graphics.rectangle("fill", Pixelscreen.mouse.get_x() - 8, Pixelscreen.mouse.get_y() - 32, 16, 32)end)
end

function scene:update(dt)
  Map.update(dt)
  update_map_render_queue() 
end

function scene:draw()
  Pixelscreen.start()
  Camera.record(Pixelscreen.mouse.get_x() - 8, Pixelscreen.mouse.get_y() - 32)
  Draw_order.execute()
  Camera.stop_record()
  Pixelscreen.stop()
  if not love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
  end
end


function scene:keypressed(key, scan, isrepeat)

end

return scene