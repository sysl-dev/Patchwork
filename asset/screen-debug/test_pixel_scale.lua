local shader_invert = love.graphics.newShader[[ vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) { vec4 col = texture2D( texture, texture_coords ); return vec4(1-col.r, 1-col.g, 1-col.b, col.a); } ]]

local timer = 0

local crt = love.graphics.newShader[[
  extern float distort;
  extern float x_distort;
  extern float y_distort;
  
  vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
  {
      vec2 center_dot = vec2((uv.x - 0.5), (uv.y - 0.5));
      float distort_apply = dot(center_dot, center_dot) * distort;
      // Note, can change 1.0 in uv.x or y to lower the effect and do a rolling background effect.
      uv.x = (uv.x - center_dot.x * (x_distort + distort_apply) * distort_apply);
      uv.y = (uv.y - center_dot.y * (y_distort + distort_apply) * distort_apply);
  
    return Texel(texture, uv) * color;
  }
]]

local scanlines = love.graphics.newShader[[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
  vec4 col = texture2D( texture, texture_coords );
  float derp;
  derp = 0.15 * mod(0.5 * texture_coords.y * love_ScreenSize.y,1.0);

    return vec4(col.r - derp, col.g - derp, col.b - derp, col.a); 

} 
]]

local crtline = love.graphics.newShader[[
  extern float distort;
  extern float x_distort;
  extern float y_distort;
  extern float line_darkness;
vec4 effect(vec4 color, Image texture, vec2 uv, vec2 pixel_coords) {
  vec2 copyuv = uv;
  float derp;
  derp = line_darkness * mod(0.5 * copyuv.y * love_ScreenSize.y,1.0);
  vec2 center_dot = vec2((uv.x - 0.5), (uv.y - 0.5));
  float distort_apply = dot(center_dot, center_dot) * distort;
  // Note, can change 1.0 in uv.x or y to lower the effect and do a rolling background effect.
  uv.x = (uv.x - center_dot.x * (x_distort + distort_apply) * distort_apply);
  uv.y = (uv.y - center_dot.y * (y_distort + distort_apply) * distort_apply);
  vec4 mix = vec4(color.r - derp, color.g - derp, color.b - derp, color.a); 
return Texel(texture, uv) * color * mix;

} 
]]

crt:send("distort", -0.4)
crt:send("x_distort", 1)
crt:send("y_distort", 1)
crtline:send("distort", -0.4)
crtline:send("x_distort", 1)
crtline:send("y_distort", 1)
crtline:send("line_darkness", 0.25)

local scene = {}
local screens = {
  "Scale",
  "Shader",
  "VSYNC",
  "Capture",
  "Image/Particles",
  "SmoothCamera",
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
local t = 0
-- Test Image 
local _test_image = love.image.newImageData(16,16)
for i = 0, 15 do
    _test_image:setPixel(i, 0, 1, .2, .2, 1) 
    _test_image:setPixel(0, i, .2, .2, 1, 1)
    _test_image:setPixel(9, i, .2, 1, .2, 1) 
    _test_image:setPixel(i, 9, 1, 1, .2, 1)
    _test_image:setPixel(i, i, 1, .2, 1, 1)
end
local _img = love.graphics.newImage(_test_image)

-- Test Particle System 
local psmog = love.graphics.newParticleSystem(_img, 500)
    	psmog:setParticleLifetime(1,1.1)
    	psmog:setEmissionRate(25)
    	psmog:setSizes(0, 0.5, 1)
    	psmog:setSizeVariation(0)
    	psmog:setLinearAcceleration(0, -50, 500, 50)
    	psmog:setColors(1, 1, 1, 1)



local BASE_WIDTH = BASE_WIDTH or love.graphics.getWidth()
local BASE_HEIGHT = BASE_HEIGHT or love.graphics.getHeight()

function scene:update(dt)
  if dt > 1/30 then return end
  t = t + dt
  psmog:update(dt)
  if current == 1 then 
    for i = 1, 9 do
      if love.keyboard.isDown(i) then 
        Pixelscreen.resize_window(i)
      end
    end
  end

  timer=timer+dt

end

function scene:draw()
  local offsettest = 0
  Pixelscreen.start()
    love.graphics.setColor(0.2,0.2,0.2,1)
    love.graphics.rectangle("fill",0,0,BASE_WIDTH+1,20)
    love.graphics.rectangle("fill",0,BASE_HEIGHT - 20,BASE_WIDTH+1,20)
    love.graphics.setColor(0.4,0.4,0.4,1)
    love.graphics.rectangle("fill",0,20,BASE_WIDTH+1,BASE_HEIGHT-40)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("Utilities - Pixel Scale - Test " .. screens[current],0, 0, BASE_WIDTH, "center")
    love.graphics.printf("Z - Previous Screen   X - Menu   C - Next Screen",0, BASE_HEIGHT - 20, BASE_WIDTH, "center")
    --
    if current == 1 then 
      love.graphics.printf("1-9: Test Scale / 0: Full Screen / -: (When Full Screen) Toggle Scale Type",0, 20, BASE_WIDTH, "center")
      local scales = ""
      for i=1, #Pixelscreen.config.size_details do
        scales = scales .. Pixelscreen.config.size_details[i] .. " "
      end
      love.graphics.printf(scales,0, 60, BASE_WIDTH, "center")
    end
    if current == 2 then 
      love.graphics.printf("1:Pixel Breaking Shader / 2:Normal Shader / 3: Higher Priorty Shader / 456: Remove Shaders / 7: Clear all shaders / 8: Test removing shader by name from Higher Priorty Shader",0, 20, BASE_WIDTH, "center")

      love.graphics.printf("Current Shaders: " .. (
        Pixelscreen.shader_count(Pixelscreen.scale_breaking_shader) + 
        Pixelscreen.shader_count(Pixelscreen.always_on_shaders) + 
        Pixelscreen.shader_count()
      ),0, 100, BASE_WIDTH, "center")
    end
    if current == 3 then 
      love.graphics.printf("1: VSYNC ON / 0: VSYNC OFF / 2: ADAPTIVE VSYNC",0, 20, BASE_WIDTH, "center")

      love.graphics.printf("Current VSYNC: " .. vtable[Pixelscreen.config.vsync],0, 40, BASE_WIDTH, "center")
    end

    if current == 4 then 
      love.graphics.printf("1: Capture / 2: Clear / 3 View Capture \n Random Number\n" .. tostring(math.floor(math.random() * 100)),0, 20, BASE_WIDTH, "center")
      if love.keyboard.isDown("3") then 
        Pixelscreen.capture_draw()
      end
    end
    if current == 5 then 
      love.graphics.draw(_img, 40, 40, math.sin(t), 2 * math.sin(t), 2* math.sin(t))
      love.graphics.draw(psmog, 80, BASE_HEIGHT/2)
    end
    if current == 6 then 
      for x=0, 20 do 
        for y=0, 10 do 
          love.graphics.draw(_img, x*16, y*16)
        end
      end
      offsettest = (timer - math.floor(timer)) * Pixelscreen.config.current_scale
    end
    
  Pixelscreen.stop({x=-offsettest, y=-offsettest})
  if love.keyboard.isDown("`") then
    Utilities.debug_tools.on_screen_debug_info()
  end
  love.graphics.print(love.timer.getFPS())
end


function scene:keypressed(key, scan, isrepeat)
  if current == 1 then 
    if key == "0" then 
      Pixelscreen.resize_fullscreen()
    end
    if key == "-" then 
      Pixelscreen.resize_scale_fullscreen()
    end
  end

  if current == 2 then 
    if key == "1" then 
      Pixelscreen.shader_push(crtline, Pixelscreen.scale_breaking_shader)
    end
    if key == "2" then 
      Pixelscreen.shader_push(scanlines)
    end
    if key == "3" then 
      Pixelscreen.shader_push(crt, Pixelscreen.always_on_shaders)
    end
    if key == "4" then 
      Pixelscreen.shader_pop(Pixelscreen.scale_breaking_shader)
    end
    if key == "5" then 
      Pixelscreen.shader_pop()
    end
    if key == "6" then 
      Pixelscreen.shader_pop(Pixelscreen.always_on_shaders)
    end
    if key == "7" then 
      Pixelscreen.shader_clear_all()
      Pixelscreen.shader_clear_all(Pixelscreen.always_on_shaders)
      Pixelscreen.shader_clear_all(Pixelscreen.scale_breaking_shader)
    end
    if key == "8" then 
      Pixelscreen.shader_remove(crt, Pixelscreen.always_on_shaders)
    end
  end

  if current == 3 then 
    if key == "0" then 
      Pixelscreen.change_vsync(0)
    end
    if key == "1" then 
      Pixelscreen.change_vsync(1)
    end
    if key == "2" then 
      Pixelscreen.change_vsync(-1)
    end
  end
  if current == 4 then 
    if key == "1" then 
      Pixelscreen.capture_canvas()
    end
    if key == "2" then 
      Pixelscreen.capture_remove()
    end
  end

  if key == "x" then 
    Gamestate.switch(Debug_screen.menu)
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