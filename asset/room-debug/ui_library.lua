
local room = { __name = "ui_library", __desc = "Test of simple UI Controller" }
local timer = 0


function room:update(dt)
  timer = timer + dt
----[==[--
  local adjustt = math.floor(((math.sin(timer) + 1)/2) * 32)
  adjustt = adjustt + 0
  adjustt = 0

  --[[ START UI ]]--
  PatchUI.define(
    -- Name, Grid Size, Active, x, y, w, h, mousex/y (in case ui scale), mouse buttons accepted, theme 
    "UI_Full_Screen", 8, true, 0, 0, __BASE_WIDTH__, __BASE_HEIGHT__, Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y(), 1, "boring"
  )

  PatchUI.solid("100%w", "100%h", "9f9f9f")
  PatchUI.pen_reset(); PatchUI.pen_right(10); PatchUI.pen_down(10)
  for i = 1, 30 do
    if  PatchUI.button_basic("" .. i, "b" .. i, nil, "30", "30") then print("COOL BUTTON DUDE") end
    if i % 8 == 0 then PatchUI.pen_newline() PatchUI.pen_right(10) else PatchUI.pen_right() end
  end

    --[[ END UI ]]--
  
  PatchUI.create_node_map("UI_Full_Screen", PatchUI.create_simple_grid_node_map(8))

  PatchUI.cursor_update(dt) 

  if love.keyboard.isDown("return") then 
    PatchUI.vcursor.active = true
  end
  ----]==]--
end

function room:draw(dt)
  Pixelscreen.start()
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("fill", 0, 0, 500, 500)
  love.graphics.setColor(1,1,1,1)
  PatchUI.draw_defined("UI_Full_Screen")
  PatchUI.cursor_draw()
  Pixelscreen.stop()
  love.graphics.setColor(0,0,0,1)
  love.graphics.print(tostring(love.timer.getFPS()))
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(tostring(love.timer.getFPS()),0, 10)
end


function room:keypressed(key, scan, isrepeat)
  if key =="escape" then 
  Gamestate.pop()
  end

  if key=="up" then 
    PatchUI.cursor_move_up(key)
  end
  if key=="down" then 
    PatchUI.cursor_move_down(key)
  end
  if key=="left" then 
    PatchUI.cursor_move_left(key)
  end
  if key=="right" then 
    PatchUI.cursor_move_right(key)
  end
  if key=="space" then 
    PatchUI.cursor_move_click()
    print("SPACE")
  end
end

return room