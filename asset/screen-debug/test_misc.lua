
local scene = {}
local mode = 0
local timer = 0
local timer2 = 0
local tilescale = Utilities.number.tile_scale
local shader_selected = Shader.cross_wave
local shader_pixlate_size = {2,2}

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
  Shader["cross_wave"]:send("timer", timer/10)
  Shader["wave"]:send("timer", timer/10)
  Shader["cross_y_wave"]:send("timer", timer/10)
  Shader["batter_wave"]:send("timer", timer/10)
  Shader["cross_3d"]:send("timer", timer/5)
  Shader["simple_blur"]:send("blur_value", 0.008 * math.sin(timer2))
  Shader["pixelate"]:send("screen_size", BASE_WIDTH_AND_HEIGHT)
  Shader["pixelate"]:send("size", shader_pixlate_size)
  Shader["color_bleed"]:send("power", 10 * math.sin(timer2))
  Shader["scaning_noise"]:send("scan_y", math.abs(1 * math.sin(timer2)))
  Shader["scaning_noise"]:send("scan_height", 0.05 + (0.01 * math.sin(timer2)))
  Shader["scaning_noise"]:send("scan_light", 1.5 + (0.2 * math.sin(timer2)))
  Shader["scaning_noise"]:send("scan_rnd", 0+ (0.2 * math.sin(timer2)))
  Shader["crt"]:send("distort", 0.5)
  Shader["crt"]:send("x_distort", -0.5)
  Shader["crt"]:send("y_distort", -0.5)
end


function scene:draw()
  Pixelscreen.start()

  if mode == 0 then 
    
    Utilities.repeating_bg.draw(Texture.system.background.pattern_01, "x32", math.floor(-timer), math.floor(-timer))

    Utilities.slice9.draw("rainbow", 0, 80, 16 + math.sin(timer/20)*48, 16+ math.sin(timer/20)*48)
    Utilities.slice9.draw_tiled("pattern", 128, 80, tilescale(33 + math.sin(timer/20)*32, 8), tilescale(33 + math.sin(timer/20)*32, 8), {tile_center = true})
   
    Utilities.slice9.draw_tiled("peanut", 128, 0, 32, 32+ math.sin(timer/20)*128)
    Utilities.slice9.draw_tiled("peanut", 0, 0, 32 + math.sin(timer/20)*150, 32)
    
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
  
  if mode == 3 then 
    
    love.graphics.setShader(shader_selected)
    love.graphics.draw(Texture.system.slice9.rainbow_8_32_8_8_32_8, 0, 0, 0, 5, 2.5)
    love.graphics.draw(Texture.system.slice9.rainbow_8_32_8_8_32_8, 100, 50, 0, 1, 1)
    love.graphics.setShader()
    love.gfx.outlinePrint(nil, "Shader 1 - 9 / q - w", 10, 10)
    if love.keyboard.isDown("0") then 
      shader_selected = nil
    end
    if love.keyboard.isDown("1") then 
      shader_selected = Shader.cross_wave
    end
    if love.keyboard.isDown("2") then 
      shader_selected = Shader.cross_y_wave
    end
    if love.keyboard.isDown("3") then 
      shader_selected = Shader.cross_3d
    end
    if love.keyboard.isDown("4") then 
      shader_selected = Shader.batter_wave
    end
    if love.keyboard.isDown("5") then 
      shader_selected = Shader.simple_blur
    end
    if love.keyboard.isDown("6") then 
      shader_selected = Shader.pixelate
    end
    if love.keyboard.isDown("7") then 
      shader_selected = Shader.invert
    end
    if love.keyboard.isDown("8") then 
      shader_selected = Shader.color_bleed
    end
    if love.keyboard.isDown("9") then 
      shader_selected = Shader.scaning_noise
    end
    if love.keyboard.isDown("q") then 
      shader_selected = Shader.crt
    end
    if love.keyboard.isDown("w") then 
      shader_selected = Shader.water_reflection
    end
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