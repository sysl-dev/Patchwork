
local scene = {}
local timer = 200
local walk_timer = 0
local mode = 0

local cx = 0
local cy = 0

local vx = 0
local vy = 0

local x, y = 0, 0 
local s = 0

function scene:update(dt)
  --Camera.current.zoom = math.abs(math.sin(timer/20) * 1.1)
  timer = timer + dt * 5
  if love.keyboard.isDown("q") then 
    timer = timer + dt * 50
  end
  if timer > 64 + 200 then timer = timer - 64  end

  if mode >= 1 then 
    vx, vy = 0, 0
    s = 1
    if love.keyboard.isDown("lshift") then 
      s = 2
    end
    if love.keyboard.isDown("w") then 
      vy = -1
    end
    if love.keyboard.isDown("s") then 
      vy = 1
    end
    if love.keyboard.isDown("a") then 
      vx = -1
    end
    if love.keyboard.isDown("d") then 
      vx = 1
    end

    
    walk_timer = walk_timer + dt 
    local move_x, move_y = 0,0
    
    if mode >= 1 then 
      if walk_timer > 1/60 then 
          move_x = vx * s
          move_y = vy * s
          walk_timer = walk_timer - 1/60
      end
    end

    cx = cx + move_x
    cy = cy + move_y
  end
end

local character = love.graphics.newQuad(16*28, 16*24, 16, 32, Texture.tileset.open_rpg:getDimensions())
local qtest = love.graphics.newQuad(16*1, 16*1, 16, 16, Texture.tileset.open_rpg:getDimensions())

function scene:draw()
  local dt = love.timer.getDelta() 
  Pixelscreen.start()
  love.graphics.rectangle("fill", 0,0, BASE_WIDTH+1, BASE_HEIGHT+1)
  
  if mode == 0 then 
    x, y = timer, timer
  end
  if mode == 1 then 
    x, y = cx, cy
  end
  if mode >= 2 then 
    x, y = cx, cy
  end


  if mode <= 1 then 
    Camera.record(x, y)
  else 

  end

  love.graphics.draw(Texture.tileset.open_rpg)
  love.graphics.draw(Texture.tileset.open_rpg, character, math.floor(cx), math.floor(cy))

  for xx = 1, 5 do 
    for yy = 1, 5 do
      love.graphics.draw(Texture.tileset.open_rpg, qtest, math.floor(xx*16), math.floor(yy*16))
    end
  end

  local CAX, CAY = 0, 0
  if mode <= 1 then 
    Camera.stop_record()
    CAX = -Camera.get_smoothstep_x()*Pixelscreen.config.current_scale
    CAY = -Camera.get_smoothstep_y()*Pixelscreen.config.current_scale
  else 

  end

  Pixelscreen.stop({x=CAX, y=CAX})
  if love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
  end
  love.graphics.print("SMOOTHSCROLLING: " .. tostring(Camera.current.smoothstep) .. " FPS: " .. love.timer.getFPS())
end


function scene:keypressed(key, scan, isrepeat)
  if key == "x" then 
    Gamestate.switch(Debug_screen.menu)
  end
  if key == "z" then 
    Camera.current.smoothstep = not Camera.current.smoothstep
  end
  if key == "0" then 
    mode = 0
  end
  if key == "1" then 
    mode = 1
  end
  if key == "2" then 
    mode = 2
  end
  if key == "3" then 
    mode = 3
  end
  if key == "4" then 
    mode = 4
  end

  if key == "-" then 
    Pixelscreen.resize_window(2)
  end
  if key == "=" then 
    Pixelscreen.resize_window(5)
  end

  if key == "]" then 
    Pixelscreen.resize_fullscreen()
  end
  if key == "/" then 
    Camera.current.zoom = Camera.current.zoom + 0.2
  end
end

return scene