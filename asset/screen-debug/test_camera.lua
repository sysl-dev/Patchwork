-- Not 100% accurate on deep floats, but close enough.
local function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local function lerp(a,b,t)
  return a + (b - a) * t
end

local scene = {}

local movecount = 0
local timer = 200
local walk_timer = 0
local camera_timer = 0
local mode = 3
local character = love.graphics.newQuad(16*28, 16*24, 16, 32, Texture.tileset.open_rpg:getDimensions())
local qtest = love.graphics.newQuad(16*1, 16*1, 16, 16, Texture.tileset.open_rpg:getDimensions())
local CAX, CAY = 0, 0
local spritex = 0
local spritey = 0

local camerax = 0
local cameray = 0
local cameraman = false
local vx = 0
local vy = 0

local count = 0

local s = 0

local float_speed_move_x, float_speed_move_y = 0, 0
local bankx, banky = 0, 0
local lastmode = 0
function scene:update(dt)
  --Camera.current.zoom = math.abs(math.sin(timer/20) * 1.1)
  timer = timer + dt * 5
  movecount = movecount + dt
  camera_timer = camera_timer + dt
  walk_timer = walk_timer + dt 

  if love.keyboard.isDown("q") then 
    timer = timer + dt * 50
  end
  if timer > 64 + 200 then timer = timer - 64  end
  if lastmode ~= mode then 
    lastmode = mode
    walk_timer = 0
  end
  if mode >= 1 then 
    vx, vy = 0, 0
    s = 1
    if love.keyboard.isDown("lshift") then 
      s = 3
    end
    if love.keyboard.isDown("rshift") then 
      movecount = 0
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

  
    local move_x, move_y = 0,0
    
    if mode == 1 then 
      if walk_timer > 1/60 then 
          move_x = (vx) * s
          move_y = (vy) * s
          walk_timer = walk_timer - 1/60
      end
    end

    if mode == 2 then 
      if walk_timer > 1/60 then 
        count = count + 1
        move_x = (vx) * s 
        move_y = (vy) * s 
        walk_timer = walk_timer - 1/30
      end
    end
    if mode == 3 then 
        --// works fine, but sprite jitters when camera moves
        move_x = (vx) * s * 40 * dt
        move_y = (vy) * s * 40 * dt

    end
    if mode == 4 then 
      -- 60 FPS -- Note // Does not work / slower on faster fps

      -- Capture Subpixel
      -- Save it
      -- if > 1 worth, give it to movement 
      -- Does not work with - numbers at the moment
        -- Get Movement 
        local basespeed = 64
        float_speed_move_x = (vx) * s * basespeed * dt
        float_speed_move_y = (vy) * s * basespeed * dt

        -- Bank the Remainder 
        bankx = bankx + math.fmod(float_speed_move_x, 1)
        banky = banky + math.fmod(float_speed_move_y, 1)

        -- Remove the remainer from movement 
        move_x = float_speed_move_x - math.fmod(float_speed_move_x, 1)
        move_y = float_speed_move_y - math.fmod(float_speed_move_y, 1)
  
        -- If we've banked enough, then we can add it to the move
        if bankx >= 1 or bankx <= -1 then 
          move_x = move_x + bankx - math.fmod(bankx, 1)
          bankx = bankx - bankx - math.fmod(bankx, 1)
        end
        if banky >= 1 or banky <= -1 then 
          move_y = move_y + banky - math.fmod(banky, 1)
          banky = banky - banky - math.fmod(banky, 1)
        end

        --print(float_speed_move_x, float_speed_move_y, bankx, banky)
    end

    spritex = spritex + move_x
    spritey = spritey + move_y
  end


 

  if cameraman  then 
    local lerpmax = 0.2
      camerax = lerp(camerax, spritex, lerpmax)
      cameray = lerp(cameray, spritey, lerpmax)
  else 
    if mode == 0 then 
      camerax, cameray = timer, timer
    end
    if mode == 1 then 
      camerax, cameray = spritex, spritey
    end
    if mode >= 2 then 
      camerax, cameray = spritex, spritey
    end
    if mode == 400 then 
      camerax, cameray = spritex + bankx, spritey + banky
    end
  end


  --print(camerax, cameray)
end



function scene:draw()
  Pixelscreen.start()
  love.graphics.rectangle("fill", 0,0, BASE_WIDTH+1, BASE_HEIGHT+1)
  



  if mode <= 6 then 
    --Camera.record(x + math.sin(timer) * 16, y+ math.cos(timer) * 16)
    Camera.record(camerax, cameray)
  else 

  end

  love.graphics.draw(Texture.tileset.open_rpg)
  love.graphics.draw(Texture.tileset.open_rpg, character, math.floor(spritex), math.floor(spritey))

  for xx = 1, 5 do 
    for yy = 1, 5 do
      love.graphics.draw(Texture.tileset.open_rpg, qtest, math.floor(xx*16), math.floor(yy*16))
    end
  end


  if mode <= 6 then 
    Camera.stop_record()
   
    CAX = Camera.get_smoothstep_x()*Pixelscreen.config.current_scale
    CAY = Camera.get_smoothstep_y()*Pixelscreen.config.current_scale
   -- print(CAX, CAY)
  else 

  end

  Pixelscreen.stop(CAX, CAY)
  if love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
  end
  love.graphics.print("SMOOTHSCROLLING: " .. tostring(Camera.current.smoothstep) .. " FPS: " .. love.timer.getFPS())
  love.gfx.outlinePrint(nil, math.floor(movecount), 10, 10)
  love.gfx.resetColor()
end


function scene:keypressed(key, scan, isrepeat)
  if key == "x" then 
    Gamestate.switch(Debug_screen.menu)
  end
  if key == "z" then 
    Camera.current.smoothstep = not Camera.current.smoothstep
  end
  if key == "b" then 
    cameraman = not cameraman
  end
  if key == "r" then 
    spritex = 0
    spritey = 0
    camerax = 0
    cameray = 0
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

  if key == "i" then 
    Pixelscreen.change_vsync(0) -- Off
  end
  if key == "o" then 
    Pixelscreen.change_vsync(1) -- On 
  end
  if key == "p" then 
    Pixelscreen.change_vsync(-1) -- Adabt 
  end
end

return scene