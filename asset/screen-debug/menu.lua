
local scene = {}
local timer = 0
local screens = {
  "test_pixel_scale",
  "test_box2d",
  "test_camera",
  "test_misc",
  "test_all_map",
}

local ascreens = {
  "Test Screen Scaling Features",
  "Test Box2d Library",
  "Camera Scroll",
  "Random Tests",
  "Map Rendering and Movement",
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
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("fill", 0, 0, 500, 500)
  Pixelscreen.stop()
  love.graphics.setColor(1,1,1,1)
  for i=1, #screens do 
    love.graphics.print(screens[i] .. " -- " .. ascreens[i], 32, i * 16)
  end
  love.graphics.rectangle("fill", 2, 8 + current * 16, 8, 8)
  if love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
  end
end


function scene:keypressed(key, scan, isrepeat)

  if key == "return" then 
    Gamestate.switch(Debug_screen[screens[current]])
  end
  if key == "up" then 
    scale_down()
  end
  if key == "down" then 
    scale_up()
  end
  if current > #screens then current = 1 end
  if current <= 0 then current = #screens end
end

return scene