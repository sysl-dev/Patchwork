local m = {
  __NAME        = "Quilt-Pixel-Scale",
  __VERSION     = "4.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "A Pixel Perfect Screen Scaling Library for Love2D.",
  __URL         = "http://github.sysl.dev/",
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2022 Chris / Systemlogoff

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]],
  __LICENSE_TITLE = "MIT LICENSE"
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Debug Mode
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.debug = true
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Locals and Housekeeping
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local print = print
local debugprint = print
local function print(...)
  if m.debug then
    debugprint(m.__NAME .. ": ", unpack({...}))
  end
end print(m.__DESCRIPTION)

-- Lazy hack if these globals are defined.
local BASE_WIDTH = BASE_WIDTH or nil
local BASE_HEIGHT = BASE_HEIGHT or nil

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Defaults
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- You can set a BASE_HEIGHT/BASE_WIDTH in conf.lua for accurate scale in full screen systems
m.config = {
  base_width = BASE_WIDTH or love.graphics.getWidth(),
  base_height = BASE_HEIGHT or love.graphics.getHeight(),
  window_width = love.graphics.getWidth(),
  window_height = love.graphics.getHeight(),
  offsetx = 0,
  offsety = 0,
  max_scale = 1,
  max_window_scale = 1,
  current_scale = 1,
  allow_window_resize = false,
  pixel_perfect_fullscreen = true,
  dirty_draw = true, -- People have bad monitors, dirty draw avoids blank frames.
  vsync = 1,
  monitor = 1,
  size_details = {}
}

-- If we're on mobile we want to set the biggest size possible later.
if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' or love.system.getOS() == 'Web' then
  m.config.mobile = true
end

-- It's easier if we have the calculation of the pixel position of the mouse.
m.mouse = {
  x = 0,
  y = 0,
}

-- Shader Effects
-- Scale Breaking Filters, apples after scaling.
m.scale_breaking_shader = {}

-- Always on, apples after the shader pool
m.always_on_shaders = {}

-- Full screen impacting shaders
m.shader_pool = {}

-- Captured Screens
m.screen_capture = {}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Functions / Standard

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup (if Required)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(settings)
  -- Set reasonable defaults if none are supplied.
  settings = settings or {}
  
  -- Get the default width and height
  m.config.base_width = settings.base_width or m.config.base_width
  m.config.base_height = settings.base_height or m.config.base_height
  print("Width/Height " .. m.config.base_width .. "/" .. m.config.base_height)

  -- Apply pixel friendly scaling changes if not disabled
  if not settings.no_global_changes then 
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    love.graphics.setLineStyle("rough")
    print("Global Changes Applied")
  end

  -- Create Resources
  m.buffer1 = love.graphics.newCanvas(m.config.base_width, m.config.base_height)
  m.buffer2 = love.graphics.newCanvas(m.config.base_width, m.config.base_height)

  -- Gather information about the monitor and save it.
  local mwidth, mheight = love.window.getDesktopDimensions(m.config.monitor)
  m.config.monitor_width = mwidth
  m.config.monitor_height = mheight

  -- Caculate the Max Scale
  local float_width = m.config.monitor_width / m.config.base_width
  local float_height = m.config.monitor_height / m.config.base_height
  local safe_zone_padding = 150

  if float_height < float_width then 
    m.config.max_scale = m.config.monitor_height / m.config.base_height
    m.config.max_window_scale = math.floor((m.config.monitor_height - safe_zone_padding) / m.config.base_height)
  else 
    m.config.max_scale = m.config.monitor_width / m.config.base_width
    m.config.max_window_scale = math.floor((m.config.monitor_width - safe_zone_padding) / m.config.base_width)
  end

  print("Window Scale/Full Screen Scale", m.config.max_window_scale, m.config.max_scale)

  -- Create a list of sizes
  for i=1, math.floor(m.config.max_scale) do 
    local c = m.config
    m.config.size_details[i] = tostring(c.base_width * i) .. "x" .. tostring(c.base_height * i) .. " (" .. i .. "x)"
    if i == math.floor(m.config.max_scale) then
      m.config.size_details[i] = tostring(c.base_width * m.config.max_scale) .. "x" .. tostring(c.base_height * m.config.max_scale) .. " (Fullscreen)"
      if m.config.pixel_perfect_fullscreen then 
        m.config.size_details[i] = tostring(c.base_width * math.floor(m.config.max_scale)) .. "x" .. tostring(c.base_height * math.floor(m.config.max_scale)) .. " (Fullscreen)"
      end
    end
    print(m.config.size_details[i])
  end

  -- Set the window size after calculation
  m.config.current_scale = settings.scale or m.config.max_window_scale
  if m.config.mobile then m.config.current_scale = m.config.max_scale end
  m.resize_window(m.config.current_scale)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Capture drawing in this canvas.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.start(settings)
  love.graphics.setCanvas({m.buffer1, stencil = true})
  if not m.config.dirty_draw then love.graphics.clear() end
  love.graphics.setColor(1,1,1,1)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw captured drawings and apply shaders.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.stop(settings)
  -- gather adjustments
  settings = settings or {}
  local c = m.config
  local x = (settings.x or 0) + c.offsetx + (c.base_width/2 * c.current_scale)
  local y = (settings.y or 0) + c.offsety + (c.base_height/2 * c.current_scale)
  local r = settings.r or 0
  local sx = (settings.sx or 0) + c.current_scale
  local sy = (settings.sy or 0) + c.current_scale
  local ox = (settings.ox or 0) + c.base_width/2
  local oy = (settings.oy or 0) + c.base_height/2
  local kx = (settings.kx or 0)
  local ky = (settings.ky or 0)

  -- Shader Pool Shaders
  for i=1, #m.shader_pool do
    love.graphics.setCanvas({m.buffer2, stencil = true})
    love.graphics.setShader(m.shader_pool[i])
    love.graphics.draw(m.buffer1)
    love.graphics.setShader()
    love.graphics.setCanvas({m.buffer1, stencil = true})
    love.graphics.draw(m.buffer2)
  end  

  -- Always on Shaders
  for i=1, #m.always_on_shaders do
    love.graphics.setCanvas({m.buffer2, stencil = true})
    love.graphics.setShader(m.always_on_shaders[i])
    love.graphics.draw(m.buffer1)
    love.graphics.setShader()
    love.graphics.setCanvas({m.buffer1, stencil = true})
    love.graphics.draw(m.buffer2)
  end  

  -- Will draw after shaders are done, treat like a callback.
  m.draw_after_shader()

  love.graphics.setCanvas()
  -- Draw the final compiled visual
  if m.scale_breaking_shader[1] then 
    love.graphics.setShader(m.scale_breaking_shader[1])
  end
  love.graphics.draw(m.buffer1, x, y, r, sx, sy, ox, oy, kx, ky)
  if m.scale_breaking_shader[1] then 
    love.graphics.setShader()
  end
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update the width/height/offset/mouse
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.update(dt)
  local c = m.config

  -- Calculate the current window size
  c.window_width = love.graphics.getWidth()
  c.window_height = love.graphics.getHeight()

  -- Calculate the offset if the screen is smaller than the window.
  c.offsetx = math.floor(((c.window_width - c.base_width * c.current_scale))/2)
  c.offsety = math.floor(((c.window_height - c.base_height * c.current_scale))/2)
  c.offsetx = math.max(c.offsetx, 0)
  c.offsety = math.max(c.offsety, 0)

  -- Mouse Updates
  m.mouse.x = math.floor((love.mouse.getX() - c.offsetx)/c.current_scale)
  m.mouse.y = math.floor((love.mouse.getY() - c.offsety)/c.current_scale)

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Resize the window
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.resize_window(scale, force)
  local c = m.config
  m.config.current_scale = math.max(1, math.min(m.config.max_window_scale, scale))
  if force then m.config.current_scale = scale end
  love.window.setMode(
    c.base_width * c.current_scale,
    c.base_height * c.current_scale,
    {
      fullscreen = false, 
      resizable = m.config.allow_window_resize, 
      highdpi = false,
      usedpiscale = false,
      minwidth = m.config.base_width,
      minheight = m.config.base_height,
      centered = true,
      vsync = m.config.vsync,
      display = m.config.monitor,
    }
    )
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Go back and forward from fullscreen
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.resize_fullscreen(force)
  if love.window.getFullscreen() == false or force then
    local full_scale = m.config.max_scale
    if m.config.pixel_perfect_fullscreen then 
      full_scale = math.floor(m.config.max_scale)
    end
    m.resize_window(full_scale, true)
    love.window.setFullscreen(true, "desktop")
  else
    m.resize_window(math.floor(m.config.max_window_scale))
    love.window.setFullscreen(false)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Go back and forward from fullscreen
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.resize_scale_fullscreen()
  m.config.pixel_perfect_fullscreen = not m.config.pixel_perfect_fullscreen 
  if love.window.getFullscreen() == true then
    local full_scale = m.config.max_scale
    if m.config.pixel_perfect_fullscreen then 
      full_scale = math.floor(m.config.max_scale)
    end
    m.config.current_scale = full_scale
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Resize the window larger
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.resize_larger()
  m.resize_window(m.config.current_scale + 1)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Resize the window smaller
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.resize_smaller()
  m.resize_window(m.config.current_scale - 1)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Change Vsync
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.change_vsync(num)
  num = math.floor(num)
  num = math.min(1, math.max(num, -1))
  print(num)
  m.config.vsync = num
  if love.window.getFullscreen() == false then
    m.resize_window(m.config.current_scale)
  else
    m.resize_fullscreen(true)
  end
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Functions / Shaders

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Drawn after shaders render, can be used as a callback or with the change draw after shader function.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw_after_shader()

end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update Draw After Shader with a new function
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.change_draw_after_shader(fun)
m.draw_after_shader = fun
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Apply a shader to the whole canvas
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.push_shader(love_shader, pool)
  pool = pool or m.shader_pool
  pool[#pool+1] = love_shader
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Remove the last added shader
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.pop_shader(pool)
  pool = pool or m.shader_pool
  pool[#pool] = nil
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Clear All Shaders
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.clear_all_shader(pool)
  pool = pool or m.shader_pool
  for i=#pool, 1, -1 do 
    pool[i] = nil
  end
end
  
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Remove all of a certain kind of shader from the pool.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.remove_shader(love_shader, pool)
  pool = pool or m.shader_pool
  for i=#pool, 1, -1 do 
    if pool[i] == love_shader then
      table.remove(pool, i)
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Count all shaders
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.count_shader(pool)
  pool = pool or m.shader_pool
  return #pool
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Functions / Screenshot

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Capture a screenshot, store it as a love graphic
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.capture_canvas(name)
name = name or "default"
  local capture = m.buffer1:newImageData(1, 1, 0, 0, m.config.base_width, m.config.base_height)
  m.screen_capture[name] = love.graphics.newImage(capture)
  return capture
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Erase all captures
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.capture_flush()
  for k,_ in pairs(m.screen_capture) do 
    k = nil
  end
  m.screen_capture = {}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Erase a captures
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.capture_remove(name)
  name = name or "default"
  m.screen_capture[name] = nil
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Check to see if the screenshot exists
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.capture_check(name)
  name = name or "default"
  if  m.screen_capture[name] ~= nil then return true else return false end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw screenshot if it exists
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.capture_draw(name, ...)
  name = name or "default"
  if m.capture_check(name) then
    love.graphics.draw(m.screen_capture[name], unpack({...}))
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m