
local room = { __name = "ui_library", __desc = "Test of ''''''simple'''''' UI Controller" }
local show = 7
local timer = 0
local moving = 0
local show6xs = 0
local show6ys = 0

local test_spider_graph = {
  name = "contest",
  cache = true,
  line_style = "smooth",
  line_width = 3,
  internal_line_width = 1,
  background_color = "77bbdd",
  line_color = "114488",
  end_colors = {"f89860","f8f038","8098f8","70e070","f8a8d0"},
  text_colors = {"f89860","f8f038","8098f8","70e070","f8a8d0"},
  plot_colors = {"44AA4430", "00ff0033", "0000ff33", "ff00ff33"},
  plot_outline_colors = {"44AA4430", "00ff0033", "0000ff33", "ff00ff33"},
  font = Font.menu_card,
  max = 255,
  data = {
    axis_name = {"Cool", "Tough", "Beauty", "Smart", "Cute", show = true},
    axis_adjust = {0, -11, 10, -15, 5, 0, -5, 0, -7, -15},
    plots = {
      {20, 255, 100, 150, 255},
    },
  },
}

local test_spider_graph2 = {
  name = "elements",
  cache = true,
  line_style = "rough",
  line_width = 2,
  internal_line_width = 0,
  background_color = "3f3f3f90",
  line_color = "114488",
  text_colors = {"f86060","f8f038","8098f8","70e070"},
  end_colors = {"f86060","f8f038","8098f8","70e070"},
  plot_colors = {"ff000050", "00ff0050", "0000ff50", "ffff0050"},
  plot_outline_colors = {"ff000030", "00ff0030", "0000ff30", "ffff0030"},
  font = Font.ack_recall,
  max = 100,
  data = {
    axis_name = {"Fire", "Water", "Earth", "Wind", show = true},
    axis_adjust = {0, -14, 19, -8, 0, -2, -14, -8},
    plots = {
      {100, 25, 25, 25},
      {25, 25, 100, 25},
      {25, 100, 25, 25},
      {25, 25, 25, 100},

    },
  },
}

local s2_example = "Click The Button"
local s2_state = nil
local s2_funbut = {
function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  love.graphics.rectangle("line", x,y,w,h)
  y = y + h/2 - love.graphics.getFont():getHeight("W")/2
  love.graphics.printf(text,x,y,w,"center")
end,
function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  Help.color.capture()
  Help.color.set("ff0000")
  love.graphics.rectangle("line", x,y,w,h)
  Help.color.set("ff9000")
  y = y + h/2 - love.graphics.getFont():getHeight("W")/2
  love.graphics.printf(text,x,y,w,"center")
  Help.color.restore()
end,
function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  Help.color.capture()
  Help.color.set("00ff00")
  love.graphics.rectangle("fill", x,y,w,h)
  Help.color.set("ff9000")
  y = y + h/2 - love.graphics.getFont():getHeight("W")/2
  love.graphics.printf(text,x,y,w,"center",math.sin(timer*3) * 0.1)
  Help.color.restore()
end,
function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  Help.color.capture()
  Help.color.set("00ff00")
  love.graphics.rectangle("fill", x,y,w,h)
  Help.color.set("224422")
  y = y + h/2 - love.graphics.getFont():getHeight("W")/2
  love.graphics.printf(text,x,y,w,"center",math.sin(timer*9) * 0.1)
  Help.color.restore()
end,
function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
  Help.color.capture()
  Help.color.set("222222")
  love.graphics.rectangle("fill", x,y,w,h)
  Help.color.set("555555")
  y = y + h/2 - love.graphics.getFont():getHeight("W")/2
  love.graphics.printf(text,x,y,w,"center")
  Help.color.restore()
end,
}

local s2_funbut2 = {
  function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
    y = y + h/2 - love.graphics.getFont():getHeight("W")/2
    love.graphics.printf(text,x,y,w,"center")
  end,
  function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
    y = y + h/2 - love.graphics.getFont():getHeight("W")/2
    love.graphics.printf(text,x,y,w,"center")
  end,
  function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
    y = y + h/2 - love.graphics.getFont():getHeight("W")/2
    love.graphics.printf(text,x,y,w,"center")
  end,
  function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
    y = y + h/2 - love.graphics.getFont():getHeight("W")/2
    love.graphics.printf(text,x,y,w,"center")
  end,
  function(col_bg, col_border, x, y, w, h, text,text_x,text_y,text_w,theme_align,col_txt,state,extra)
    y = y + h/2 - love.graphics.getFont():getHeight("W")/2
    love.graphics.printf(text,x,y,w,"center")
  end,
}

function room:update(dt)
  if Help.update.stop_runaway_dt(dt) then return end 
  UI.update(dt)

  timer = timer + dt
----[==[--
  local adjustt = math.floor(((math.sin(timer) + 1)/2) * 32)
  adjustt = adjustt * moving

  --[[ START UI ]]--
  UI.define(
    -- Name, Grid Size, Active, x, y, w, h, mousex/y (in case ui scale), mouse buttons accepted, theme 
    "UI_One", 0 + adjustt, 0 + adjustt, __BASE_WIDTH__, __BASE_HEIGHT__, Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y()
  )
  --[[--------------------------------------------------------------------------------------------------------------------------------------------------
  *
  *   1
  *   Rectangle, scaling 
  --------------------------------------------------------------------------------------------------------------------------------------------------]]--
  if show == 1 then 
    UI.solid_rectangle("c0ffee", "50%w", "50%h")
    UI.pen_right("50%w")
    UI.solid_rectangle("00beef", "50%w", "50%h")
    UI.pen_down("50%h")
    UI.solid_rectangle("D0ED0E", "50%w", "50%h")
    UI.pen_left("50%w")
    UI.solid_rectangle("face55", "50%w", "50%h")
    UI.pen_reset()
    for i=0,7 do 
      if i%2 == 0 then 
        UI.solid_rectangle("FFFFFF", "12.5%w", "2%h")
      else 
        UI.solid_rectangle("000000", "12.5%w", "2%h")
      end
      UI.pen_right("12.5%w")
    end
    UI.pen_left("2%w")
    for i=0,9 do 
      if i%2 == 0 then 
        UI.solid_rectangle("FFFFFF", "2%w", "12.5%h")
      else 
        UI.solid_rectangle("000000", "2%w", "12.5%h")
      end
      UI.pen_down("12.5%h")
    end
    UI.pen_reset()
    UI.solid_rectangle("ff000099", "100%", "10%h")
    UI.pen_down()
    UI.solid_rectangle("00ff0099", "100%w", "10%h")
    UI.pen_down()
    UI.solid_rectangle("00ff0099", "3#8", "1#8")
    UI.pen_right("10#8")
    UI.solid_rectangle("00ff0099", "3#8", "1#8")
    UI.pen_right("20#8")
    UI.solid_rectangle("00ff0099", "1#8", "1#8")
    UI.pen_newline()
    UI.solid_rectangle("0000ff99", "100%w", "10%h")
    UI.pen_down()
    UI.pen_reset()
    UI.pen_down("half height")
    UI.pen_up("5%h")
    UI.solid_rectangle("ff00ff99", "100%", "10%h")
    UI.pen_reset()
    UI.pen_right("half width")
    UI.pen_left("5%w")
    UI.solid_rectangle("ff00ff99", "10%w", "100%h")
    UI.pen_right()
    UI.solid_rectangle("ffff0099", "last width", "last height")
    UI.pen_reset()
    UI.pen_down("55%h")
    UI.solid_rectangle("ff000099", "calc 50%w + 25%w - 100px end", "10%h")
    UI.pen_down("10%h")
    UI.solid_rectangle("ff000099", "calc 10px * 10px / 20px end", "10%h")
    UI.pen_set("100fx", "100fy")
    UI.solid_rectangle("ff000099", 10, 10)
    UI.pen_set(100,100)
    UI.solid_rectangle("ff000099", 10, 10)


  end

  --[[-------------------------------------------------------------------------------- l------------------------------------------------------------------
  *
  *   2
  *
  --------------------------------------------------------------------------------------------------------------------------------------------------]]--
  if show == 2 then 
    UI.solid_rectangle("1f1f1f", "100%w", "100%h")
    UI.pen_reset()
    UI.pen_down("2%w")
    UI.pen_right("2%w")
    local was_clicked, b1, b2, b3, vc = UI.button_basic("Button Click Test", "mousetest", "44%w", nil, 40)
    if was_clicked then
      if b1 then s2_example = "Clicked with Mouse1" end
      if b2 then s2_example = "Clicked with Mouse2"  end
      if b3 then s2_example = "Clicked with Mouse3"  end
      if vc then s2_example = "Clicked with Gamepad Button"  end
    end
    UI.pen_right()
    UI.solid_rectangle("0f0f0f", "48%w", 40)
    UI.text_color(s2_example,"48%w",40,"center","aaaaff")

    UI.pen_reset()
    UI.pen_down("35%h")
    UI.button_quad(Texture.system.ztest.button_quad,"imgtest11", nil)
    UI.pen_right()
    UI.button_quad(Texture.system.ztest.button_quad,"imgtest12", true)
    UI.pen_right()
    UI.button_quad(Texture.system.ztest.button_quad,"imgtest13", false)
    UI.pen_right()
    UI.button_quad(Texture.system.ztest.button_quad2,"imgtest2", true, " ")
    UI.pen_right()
    UI.button_quad(Texture.system.ztest.button_quad2,"imgtest3", nil, "Wow!", 2)
    UI.pen_right()
    UI.button_quad(Texture.system.ztest.button_quad2,"imgtest4", nil, "Wow cool", -2, "330000", "004400", "000055")
    UI.pen_right()
    UI.button_quad(Texture.system.ztest.button_quad2,"imgtest5", false, "wow cool test", 2)
    
    UI.pen_reset()
    UI.pen_down("65%h")
    UI.pen_right("2%w")
    UI.button_function("Test!", "funbut1z", nil, 50, 20, s2_funbut[1], s2_funbut[2], s2_funbut[3], s2_funbut[4], s2_funbut[5])
    UI.pen_right()
    UI.button_function("Test!", "funbut2z", true, 50, 20, unpack(s2_funbut))
    UI.pen_right()
    UI.button_function("Test!", "funbut3z", false, 50, 20, unpack(s2_funbut))
    UI.pen_right()
    if UI.button_function("Test!", "funbut4z", s2_state, 50, 20, unpack(s2_funbut)) then if s2_state then s2_state = nil else s2_state = true end end
    UI.pen_right()
    if UI.button_function("Test!", "funbut5z", nil, 50, 20, unpack(s2_funbut2)) then if s2_state then s2_state = nil else s2_state = true end end
  end

 --[[--------------------------------------------------------------------------------------------------------------------------------------------------
  *
  *   3
  *  
  --------------------------------------------------------------------------------------------------------------------------------------------------]]--
  if show == 3 then 
    UI.solid_rectangle("333333", "100%w", "100%h")
    UI.pen_reset()
    UI.pen_down("2%w")
    UI.pen_right("2%w")
    UI.progress_x_basic("ff0000",math.sin(timer*2)*2, 100, 20, false, false, "aaaaaa", "333388",Shader.color_basic_grad_x)
    UI.text_color("Health?", 100, 20, "center")
    UI.pen_right_and(2)
    UI.progress_x_basic("0000ff",math.sin(timer*2)*2, 100, 20, false, false, "aaaaaa", "333388",Shader.color_basic_grad_y)
    UI.text_color("Mana?", 100, 20, "center")
    UI.pen_right_and(2)
    UI.progress_y_basic("ffa500",(math.sin(timer*3) + 1)/2, 6, 20)
    UI.pen_right_and(1)
    UI.progress_y_basic("ffff00",(math.sin(timer*3+0.2) + 1)/2, 6, 20)
    UI.pen_right_and(1)
    UI.progress_y_basic("008000",(math.sin(timer*3+0.4) + 1)/2, 6, 20)
    UI.pen_right_and(1)
    UI.progress_y_basic("0000ff",(math.sin(timer*3+0.6) + 1)/2, 6, 20)
    UI.pen_right_and(1)
    UI.progress_y_basic("4b0082",(math.sin(timer*3+0.8) + 1)/2, 6, 20)
    UI.pen_right_and(1)
    UI.progress_y_basic("0f0f0f",(math.sin(timer*3+1) + 1)/2, 6, 120)
    UI.pen_reset()
    UI.pen_down("2%w")
    UI.pen_right("2%w")
    UI.pen_down(22)
    UI.progress_x_basic("306f5e",0.75, 236, 6)
    UI.pen_newline()
    UI.pen_down("2%w")
    UI.pen_right("2%w")
    UI.progress_x_quad(Texture.system.ztest.progress_quadx,(math.sin((timer*2)+1)/2)*2)
    UI.pen_right()
    UI.pen_right(2)
    UI.progress_y_quad(Texture.system.ztest.progress_quady,(math.sin((timer*2.1)+1)/2)*2)
    UI.pen_set("50%w", "50%h")
    UI.image(Texture.system.ztest.pattern_02, timer*(math.pi))
    UI.pen_right_and(-5)
    UI.image(Texture.system.ztest.pattern_02, -timer*(math.pi)+0.5, 1, "center")
    UI.pen_newline()
    UI.progress_x_image(Texture.system.ztest.an_icon, math.floor(((math.sin(timer * 2)) + 1)/2 * 5), 10)
    UI.pen_right_and(2)
    UI.progress_x_image(Texture.system.ztest.an_icon, math.floor(((math.sin(timer * 4)) + 1)/2 * 5))
    UI.pen_right_and(2)
    UI.progress_x_image(Texture.system.ztest.an_icon, 5)
    UI.pen_newline()
    UI.progress_y_image(Texture.system.ztest.an_icon, 2)

  end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  *
  *   4
  *  
  --------------------------------------------------------------------------------------------------------------------------------------------------]]--
  if show == 4 then 
    UI.solid_rectangle("444", "100%w", "100%h")
    UI.pen_down("85%h")
    UI.solid_rectangle("222", "100%w", "16%h")
    UI.pen_set(10,10)
    UI.scrollbar_basic("wow_slider", dt, 10,10, 100, 10, 0, 0)
    UI.pen_down_and(2)
    UI.scrollbar_basic("wow_slider2", dt, 10,10, 100, 10, 0.5, 0.5)
    UI.pen_right_and(2)
    UI.scrollbar_basic("wow_slider3", dt, 10,10, 100, 10, 1, 1)
    UI.pen_newline()
    UI.pen_down(2)
    local gcx, gcy = UI.scrollbar_basic("wow_slider4", dt, 10,10, 50, 50, 0, 0)
    if gcx > 0.5 and gcy > 0.5 then 
      UI.pen_right_and(2)
      UI.scrollbar_basic("wow_slider5", dt, 10,10, 100, 50, 0, 0)
    end
    UI.pen_right_and(2)
    UI.scrollbar_basic("wow_slider6", dt, 10,10, 10, 50, 0, 0)
    UI.pen_right_and(2)
    UI.scrollbar_image(Texture.system.ztest.grab_back, Texture.system.ztest.grab_back_active, Texture.system.ztest.grab_icon, "image_test", dt, 0.5)
  end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  *
  *   5
  *  
  --------------------------------------------------------------------------------------------------------------------------------------------------]]--
  if show == 5 then 
    UI.solid_rectangle("0000ff", "100%w", "100%h", false, false, Shader.color_basic_grad_y)
    UI.pen_down("85%h")
    UI.solid_rectangle("222", "100%w", "16%h")
    UI.pen_set(10,10)
    UI.slice9(Texture.system.ztest.windowpeanut, 42, 42, false)
    UI.pen_right_and(2)
    UI.slice9(Texture.system.ztest.windowpeanut, 20, 42, false)
    UI.pen_right_and(2)
    UI.slice9(Texture.system.ztest.windowpeanut, 42, 20, false)
    UI.pen_right_and(2)
    UI.slice9(Texture.system.ztest.windowpeanut, 39  + math.sin(timer) * 40, 39  + math.sin(timer) * 40, true)
    UI.pen_right_and(2)
    UI.slice9(Texture.system.ztest.windowpeanut, 42, 20, true)
    UI.pen_right_and(2)
    UI.slice9(Texture.system.ztest.windowpeanut, 20, 42, true)
    UI.pen_newline()
    UI.pen_right(10)
    UI.pen_down(25)
    UI.solid_disk("fff", 20, math.sin(timer * 5))
    UI.pen_right_and(5)
    UI.solid_disk("fff", 20, 0.25)
    UI.pen_right_and(5)
    UI.solid_disk("fff", 20, 0.5)
    UI.pen_right_and(5)
    UI.solid_disk("fff", 20, 0.75)
    UI.pen_right_and(5)
    UI.solid_disk("fff", 20, 1)
    UI.pen_right_and(5)
    UI.solid_disk("aa9faa", 20, math.sin(timer * 2), 20, 180, false, false, Shader.color_basic_grad_y)
    UI.pen_right_and(5)
    UI.solid_disk("aa9faa", 20, math.sin(timer * 1), 20, 180, false, false, Shader.color_basic_grad_x)
    UI.pen_right_and(5)
    UI.solid_disk("aa9faa", 20, math.sin(timer * 0.5), 20, 180, false, false, Shader.color_basic_grad_xy)
    UI.pen_newline()
    UI.pen_right(10)
    UI.pen_down(2)
    UI.solid_disk("aa9faa", 30, math.sin(timer * 2), 20, 180, false, false, Shader.color_basic_grad_circ)

  end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  *
  *   6
  *  
  --------------------------------------------------------------------------------------------------------------------------------------------------]]--

  if show == 6 then 
    UI.repeating_background(Texture.system.ztest.repeat_test, "repeat01", show6xs, show6ys, dt, false, false, false, false, Shader.color_basic_grad_y)
    UI.pen_reset()
    UI.pen_down(2)
    UI.pen_right(2)
    show6xs, show6ys = UI.scrollbar_basic("sppedslider", dt, 6, 6, 30, 30, 0, 0)
    show6xs, show6ys = show6xs - 0.5, show6ys - 0.5
    show6xs, show6ys = show6xs * 240, show6ys * 240
    show6xs, show6ys = math.floor(show6xs), math.floor(show6ys)

  end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  *
  *   7
  *  
  --------------------------------------------------------------------------------------------------------------------------------------------------]]--

  if show == 7 then 
    UI.solid_rectangle("2299aa", "100%w", "100%h", false, false, Shader.color_basic_grad_y)
    UI.pen_reset()
    UI.pen_down(15)
    UI.pen_right(20)
    UI.graph_spider(test_spider_graph, "80%h", false, false, false, Shader.color_basic_grad_x)
    UI.pen_right_and(26)
    UI.pen_down("20%h")
    UI.graph_spider(test_spider_graph2, "40%h")
  end



  UI.define(
    -- Name, Grid Size, Active, x, y, w, h, mousex/y (in case ui scale), mouse buttons accepted, theme 
    "UI_Two", 0, 0, __BASE_WIDTH__, __BASE_HEIGHT__, Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y()
  )

  UI.pen_down("90%h")
  UI.pen_right("2%w")
  for i=1, 11 do 
    if show == i then 
      if UI.button_basic(i, "set1" .. i, true) then show = i  end
    else 
    if UI.button_basic(i, "set1" .. i, nil) then show = i  end
    end
    UI.pen_right()
  end
  if UI.button_basic("M", "mmm", nil, 20) then if moving == 0 then moving = 1 else moving = 0 end  end
    --[[ END UI ]]--
  
  if love.keyboard.isDown("space") then 
    UI.vcursor_press_confirm("space")
  else 
    UI.vcursor_press_confirm()
  end

  if love.keyboard.isDown("up") then 
    UI.vcursor_press_up("up")
  else 
    UI.vcursor_press_up()
  end

  if love.keyboard.isDown("down") then 
    UI.vcursor_press_down("down")
  else 
    UI.vcursor_press_down()
  end

  if love.keyboard.isDown("right") then 
    UI.vcursor_press_right("right")
  else 
    UI.vcursor_press_right()
  end

  if love.keyboard.isDown("left") then 
    UI.vcursor_press_left("left")
  else 
    UI.vcursor_press_left()
  end

  --PatchUI.set_active("UI_Two")


  ----]==]--
end

function room:draw(dt)
  Pixelscreen.start()
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("fill", 0, 0, 500, 500)
  love.graphics.setColor(1,1,1,1)

  UI.draw_defined("UI_One")
  UI.draw_defined("UI_Two")
  UI.cursor_draw(true)
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
    UI.create_node_map("UI_One")
  UI.create_node_map("UI_Two")
  end

  if key=="up" then 
    UI.cursor_move_up(key)
  end
  if key=="down" then 
    UI.cursor_move_down(key)
  end
  if key=="left" then 
    UI.cursor_move_left(key)
  end
  if key=="right" then 
    UI.cursor_move_right(key)
  end

  if key =="0" then 
    UI.active_ui_clear()
  end
  if key =="1" then 
    UI.active_ui_set("UI_One")
  end
  if key =="2" then 
    UI.active_ui_set("UI_Two")
  end
  if key =="3" then 
    UI.active_ui_push("UI_Two")
  end
  if key =="4" then 
    UI.active_ui_pop()
  end
end

return room