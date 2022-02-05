local shader_invert = love.graphics.newShader[[ vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) { vec4 col = texture2D( texture, texture_coords ); return vec4(1-col.r, 1-col.g, 1-col.b, col.a); } ]]


local scene = {}
local screens = {
  "Scale",
  "Shader",
  "VSYNC",
  "Capture",
}
local current = 1

local function scale_up()
  current = current + 1

end

local function scale_down()
  current = current - 1
end

local vtable = {
[-1] = "Adaptive",
[0] = "Off",
[1] = "On"
}




local BASE_WIDTH = BASE_WIDTH or love.graphics.getWidth()
local BASE_HEIGHT = BASE_HEIGHT or love.graphics.getHeight()

function scene:update(dt)
  if current == 1 then 
    for i = 1, 9 do
      if love.keyboard.isDown(i) then 
        Utilities.pixel_scale.resize_window(i)
      end
    end
  end


end

function scene:draw(dt)
  Utilities.pixel_scale.start()
    love.graphics.setColor(0.2,0.2,0.2,1)
    love.graphics.rectangle("fill",0,0,BASE_WIDTH,20)
    love.graphics.rectangle("fill",0,BASE_HEIGHT - 20,BASE_WIDTH,20)
    love.graphics.setColor(0.4,0.4,0.4,1)
    love.graphics.rectangle("fill",0,20,BASE_WIDTH,BASE_HEIGHT-40)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("Utilities - Pixel Scale - Test " .. screens[current],0, 0, BASE_WIDTH, "center")
    love.graphics.printf("Z - Previous Screen   X - Menu   C - Next Screen",0, BASE_HEIGHT - 20, BASE_WIDTH, "center")
    --
    if current == 1 then 
      love.graphics.printf("1-9: Test Scale / 0: Full Screen / -: (When Full Screen) Toggle Scale Type",0, 20, BASE_WIDTH, "center")
      local scales = ""
      for i=1, #Utilities.pixel_scale.config.size_details do
        scales = scales .. Utilities.pixel_scale.config.size_details[i] .. " "
      end
      love.graphics.printf(scales,0, 60, BASE_WIDTH, "center")
    end
    if current == 3 then 
      love.graphics.printf("1: VSYNC ON / 0: VSYNC OFF / 2: ADAPTIVE VSYNC",0, 20, BASE_WIDTH, "center")

      love.graphics.printf("Current VSYNC: " .. vtable[Utilities.pixel_scale.config.vsync],0, 40, BASE_WIDTH, "center")
    end
  Utilities.pixel_scale.stop({})
  if love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
  end
end


function scene:keypressed(key, scan, isrepeat)
  if current == 1 then 
    if key == "0" then 
      Utilities.pixel_scale.resize_fullscreen()
    end
    if key == "-" then 
      Utilities.pixel_scale.resize_scale_fullscreen()
    end
  end

  if current == 2 then 
  end

  if current == 3 then 
    if key == "0" then 
      Utilities.pixel_scale.change_vsync(0)
    end
    if key == "1" then 
      Utilities.pixel_scale.change_vsync(1)
    end
    if key == "2" then 
      Utilities.pixel_scale.change_vsync(-1)
    end
  end

  if key == "x" then 
    Gamestate.switch(Debug_screen.menu)
  end
  if key == "z" then 
    scale_up()
  end
  if key == "c" then 
    scale_down()
  end
  if current > #screens then current = #screens end
  if current <= 0 then current = 1 end
end

return scene