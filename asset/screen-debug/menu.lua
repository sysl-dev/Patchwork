
local scene = {}
local timer = 0
local screens = {
  "test_pixel_scale",
  "test_box2d",
  "test_camera",
  "test_misc",
}

local ascreens = {
  "Test Screen Scaling Features",
  "Test Box2d Library",
  "Camera Scroll",
  "Random Tests",
}
local current = 1

local function scale_up()
  current = current + 1

end

local function scale_down()
  current = current - 1
end


local BASE_WIDTH = BASE_WIDTH or love.graphics.getWidth()
local BASE_HEIGHT = BASE_HEIGHT or love.graphics.getHeight()

function scene:update(dt)
  timer = timer + dt
end

function scene:draw(dt)
  Pixelscreen.start()
    love.graphics.setColor(0.2,0.2,0.2,1)
    love.graphics.rectangle("fill",0,0,BASE_WIDTH,20)
    love.graphics.rectangle("fill",0,BASE_HEIGHT - 20,BASE_WIDTH,20)
    love.graphics.setColor(0.4,0.4,0.4,1)
    love.graphics.rectangle("fill",0,20,BASE_WIDTH,BASE_HEIGHT-40)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("Z - Previous Screen   X - Switch Scene   C - Next Screen",0, BASE_HEIGHT - 20, BASE_WIDTH, "center")
    love.graphics.printf(ascreens[current], 0, BASE_HEIGHT/2-8, BASE_WIDTH, "center")

    love.gfx.disk(49, 49, 26, math.sin(timer) - 0.015 , -90+2, 12)
    love.gfx.colorDisk(50, 50, 25, math.sin(timer), -90, {0,0.3,0.15,1}, {0,0.0,0.0,1}, 10, "c")

    love.gfx.colorRectangle(120, 50, 50, 10, {0,0.8,0.2,1}, {0,0.4,0.2,1}, "c")
    


  Pixelscreen.stop()
  if love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
  end
end


function scene:keypressed(key, scan, isrepeat)

  if key == "x" then 
    Gamestate.switch(Debug_screen[screens[current]])
  end
  if key == "c" then 
    scale_up()
  end
  if key == "z" then 
    scale_down()
  end
  if current > #screens then current = 1 end
  if current <= 0 then current = #screens end
end

return scene