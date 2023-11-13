
local scene = {}
local timer = 0


function scene:update(dt)
  timer = timer + dt

  Gui.start("Wow!", 8, 0, 0, __BASE_WIDTH__, __BASE_HEIGHT__)
  Gui.solid("100%w", "100%h", "9f9f9f")
  Gui.set_cursor(0,0)
  Gui.solid("10#", "1#", nil, "cw", "1#")
  Gui.newline()
  Gui.solid("10#", "1#", "f00", "cw")
  Gui.down()
  Gui.right()
  Gui.solid("2#","2#","#00f")

  Gui.start("Window", 8, 0, 0, 50, 50)
  Gui.solid("100%w", "100%h", "00aaaa")
  Gui.solid("100%w", "10%h", "aa00aa")
  Gui.newline()
  Gui.up(6)
  Gui.text_format("Wow,you can fit a lot of text in this bad boy.","100%w","left","ff0000")
  Gui.newline()
  Gui.text_format("Neat!\ncookies and cream and all inbetween","100%w","left","ffff0f")
  Gui.newline()
  Gui.text_format("Neat!\ncookies and cream and all inbetween","100%w","left","00ff0f")
end

function scene:draw(dt)
  Pixelscreen.start()
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("fill", 0, 0, 500, 500)
  love.graphics.setColor(1,1,1,1)
  Gui.draw("Wow!")
  Gui.draw("Window")
  Pixelscreen.stop()
end


function scene:keypressed(key, scan, isrepeat)
  if key =="x" then 
  Gamestate.switch(Debug_screen.menu)
  end
end

return scene