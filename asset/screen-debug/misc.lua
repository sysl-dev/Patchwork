
local scene = {}
local mode = 0
local timer = 0
local tilescale = Utilities.number.tile_scale

-- Mode 0/1 Setup
Utilities.repeating_bg.create("x32", 32, 32)
Utilities.repeating_bg.set_repeat(Texture.system.background.pattern_01, "repeat")
  Utilities.repeating_bg.create("x5", 5, 5) -- Forcing scaling can have fun effects

function scene:update(dt)
  timer = timer + dt * 32
  if timer > 64 then 
    timer = timer - 64 
  end
end


function scene:draw()
  Pixelscreen.start()

  if mode == 0 then 
    Utilities.repeating_bg.draw(Texture.system.background.pattern_01, "x32", math.floor(-timer), math.floor(-timer))
    Utilities.slice9.draw("complex", 0, 0, 32 + math.sin(timer/20)*32, 32+ math.sin(timer/20)*32)
    Utilities.slice9.draw_tiled("complex", 128, 0, 32 + math.sin(timer/20)*32, 32+ math.sin(timer/20)*32)
    Utilities.slice9.draw("rainbow", 0, 80, 64, 64)
    Utilities.slice9.draw_tiled("pattern", 128, 80, tilescale(33 + math.sin(timer/20)*32, 8), tilescale(33 + math.sin(timer/20)*32, 8), {tile_center = true})
  end
  if mode == 1 then 
    Utilities.repeating_bg.draw(Texture.system.background.pattern_01, "x5", math.floor(-timer), math.floor(-timer))
  end

  Pixelscreen.stop()
  love.graphics.print(" FPS: " .. love.timer.getFPS())
end


function scene:keypressed(key, scan, isrepeat)
  if key == "x" then 
    Gamestate.switch(Debug_screen.menu)
  end
  if key =="z" then 
    mode = mode - 1 
  end
  if key == "c" then 
    mode = mode + 1
  end
end

return scene