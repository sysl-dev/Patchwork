
local scene = {}
local mode = 0
local timer = 0
local timer2 = 0
local tilescale = Utilities.number.tile_scale

-- Mode 0/1 Setup
Utilities.repeating_bg.create("x32", 32, 32)
Utilities.repeating_bg.set_repeat(Texture.system.background.pattern_01, "repeat")
Utilities.repeating_bg.set_repeat(Texture.system.background.paper, "repeat")
  Utilities.repeating_bg.create("x5", 5, 5) -- Forcing scaling can have fun effects

function scene:update(dt)
  timer = timer + dt * 32
  timer2 = timer2 + dt
  if timer > 64 then 
    timer = timer - 64 
  end
end


function scene:draw()
  Pixelscreen.start()

  if mode == 0 then 
    Utilities.repeating_bg.draw(Texture.system.background.pattern_01, "x32", math.floor(-timer), math.floor(-timer))
    Utilities.slice9.draw("peanut", 0, 0, 32 + math.sin(timer/20)*32, 32+ math.sin(timer/20)*32)
    Utilities.slice9.draw_tiled("peanut", 128, 0, 32 + math.sin(timer/20)*32, 32+ math.sin(timer/20)*32)
    Utilities.slice9.draw("rainbow", 0, 80, 16 + math.sin(timer/20)*48, 16+ math.sin(timer/20)*48)
    Utilities.slice9.draw_tiled("pattern", 128, 80, tilescale(33 + math.sin(timer/20)*32, 8), tilescale(33 + math.sin(timer/20)*32, 8), {tile_center = true})
  end
  if mode == 1 then 
    Utilities.repeating_bg.draw(Texture.system.background.pattern_01, "x5", math.floor(-timer), math.floor(-timer))
  end
  if mode == 2 then 
    Utilities.repeating_bg.draw(Texture.system.background.paper, "x32", math.floor(-timer/2), math.floor(-timer/2))
    love.gfx.disk(49, 49, 26, math.sin(timer2) - 0.015 , -90+2, 12)
    love.gfx.colorDisk(50, 50, 25, math.sin(timer2), -90, {1,0,0,1}, {0,0,1,1}, 10, "c", 16)

    love.gfx.disk(199, 49, 26, math.sin(timer2) - 0.015 , -90+2, 12)
    love.gfx.colorDisk(200, 50, 25, 60, -90, {0.5,0.5,0.5,1}, {0,0,0,1}, 10, "c", math.sin(timer/256) * 256)

    love.gfx.colorRectangle(120, 50, 50, 10, {0,0.8,0.2,1}, {0,0.4,0.2,1}, "c")
    love.gfx.colorRectangle(120, 61, 50, 10, {0,0.8,0.2,1}, {0,0.4,0.2,1}, "x")
    love.gfx.colorRectangle(120, 72, 50, 10, {0,0.8,0.2,1}, {0,0.4,0.2,1}, "y")
    love.gfx.colorRectangle(120, 83, 50, 10, {1,0.2,0.2,1}, {0,0.4,0.2,1}, "xy")
    
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