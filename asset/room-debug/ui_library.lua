
local room = { __name = "ui_library", __desc = "Test of ''''''simple'''''' UI Controller" }
local timer = 0
local toggle = true

function room:update(dt)
  if Help.update.stop_runaway_dt(dt) then return end 
  timer = timer + dt
----[==[--
  local adjustt = math.floor(((math.sin(timer) + 1)/2) * 32)
  adjustt = adjustt + 0
  adjustt = 0

  --[[ START UI ]]--
  PatchUI.define(
    -- Name, Grid Size, Active, x, y, w, h, mousex/y (in case ui scale), mouse buttons accepted, theme 
    "UI_One", 8, 0, 0, __BASE_WIDTH__, __BASE_HEIGHT__, Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y(), 1
  )


  PatchUI.solid("100%w", "100%h", "9f9f9f")
  PatchUI.pen_reset(); PatchUI.pen_right(10); PatchUI.pen_down(10)
  for i = 1, 12 do
    if  PatchUI.button_basic("" .. i, "b" .. i, nil, 30, 15) then PatchUI.vcursor.type = "outline" end
    --PatchUI.text_format("Hello!", 30, "left")
    if i % 6 == 0 then PatchUI.pen_newline() PatchUI.pen_down(4) PatchUI.pen_right(10) else PatchUI.pen_right_and(4) end
  end


  PatchUI.change_font(Font.ack_recall)
  if  PatchUI.button_basic("Nor", "x1", nil, 50) then PatchUI.vcursor.type = "outline" end
  PatchUI.change_font(Font.default)

  PatchUI.pen_right_and(4)
  if toggle then 
    if  PatchUI.button_basic("Ena", "x2", true, 50, 15) then toggle = false end
    
  else 
    if  PatchUI.button_basic("Ena", "x2", nil, 50, 15) then toggle = true end
  end
  PatchUI.pen_right_and(4)
  if  PatchUI.button_basic("Dis", "x3", false, 50, 15) then PatchUI.vcursor.type = "outline" end

  PatchUI.add_tooltip_basic("Oh fuck oh shit I've droped", "x2", 80,"right" )
  PatchUI.add_tooltip_basic("oh help me", "x3", 80,"left" )
  PatchUI.add_tooltip_basic("never going to ", "b1", 80,"right" )
  PatchUI.add_tooltip_basic("give you up", "b2", 80,"right" )
  PatchUI.add_tooltip_basic("let you down", "b3", 80,"right" )
  PatchUI.add_tooltip_basic("desert you.", "b3", 80,"bottom" )



  PatchUI.define(
    -- Name, Grid Size, Active, x, y, w, h, mousex/y (in case ui scale), mouse buttons accepted, theme 
    "UI_Two", 8, 0, 0, __BASE_WIDTH__, __BASE_HEIGHT__, Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y(), 1
  )

  PatchUI.pen_reset();  PatchUI.pen_down(100)
  PatchUI.pen_right(10);
  for i = 1, 2 do
    if  PatchUI.button_basic("x" .. i, "q" .. i, nil, 30, 30) then print ("AAAAAAAAAAAAAAA") PatchUI.vcursor.type = "basic_arrow" end
    if i % 8 == 0 then PatchUI.pen_newline() PatchUI.pen_right(10) else PatchUI.pen_right() end
  end


    --[[ END UI ]]--
  


  --PatchUI.set_active("UI_Two")
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

  PatchUI.draw_defined("UI_One")
  PatchUI.draw_defined("UI_Two")
  PatchUI.cursor_draw(true)
  Pixelscreen.stop()
end


function room:keypressed(key, scan, isrepeat)
  if key =="escape" then 
  Gamestate.pop()
  end
  if key =="q" then 
  Gamestate.switch(Room.menu)
  end
  if key =="d" then 
    PatchUI.create_node_map("UI_One")
  PatchUI.create_node_map("UI_Two")
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
  if key =="0" then 
    PatchUI.active_ui_clear()
  end
  if key =="1" then 
    PatchUI.active_ui_set("UI_One")
  end
  if key =="2" then 
    PatchUI.active_ui_set("UI_Two")
  end
  if key =="3" then 
    PatchUI.active_ui_push("UI_Two")
  end
  if key =="4" then 
    PatchUI.active_ui_pop()
  end
end

return room