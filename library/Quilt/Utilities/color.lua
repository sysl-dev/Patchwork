local m = {
  __NAME        = "QU-Color",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Color Utility Functions",
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
m.debug = false
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

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Global Settings to Load
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.functions_list = {
  "hex2color",
  "palette",
  "alpha",
  "blend",
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Store into a table for easy on/off
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.functions_code = {
  -- Converts a hex-color into a LOVE supported color table.  
  hex2color = function()
    function m.hex2color(color_string)
      color_string = color_string:gsub("#", "")
      local r = tonumber(color_string:sub(1,2),16)
      local g = tonumber(color_string:sub(3,4),16)
      local b = tonumber(color_string:sub(5,6),16)
      local a = tonumber(color_string:sub(7,8),16)
      if r == nil or g == nil or b == nil then return end
      a = a or 255
      r, g, b, a = love.math.colorFromBytes(r, g, b, a)
      return {r,g,b,a}
    end
    print("hex2color: enabled")
  end,

  -- Returns a table containing a palette from an image, created left to right, top to bottom.  
  palette = function ()
    m.palette = {}
    function m.palette.create(path_to_image, square_size, named_colors)
      -- Data Check
      assert(type(path_to_image) == "string", "This must be the path to the image, not a love userdata image.")
      assert(type(square_size) == "number", "You must define the size of your colored squares in the palette image.")
      named_colors = named_colors or {}
      assert(type(named_colors) == "table", "named_colors must be a table if defined")

      -- Set up locals
      local image = love.image.newImageData(path_to_image)
      local r, g, b, a = 0,0,0,0
      local i = 1
      local palette_table = {}

      -- Set up named color table
      palette_table.name = {}

      -- Process Image
      for y = 0, image:getHeight()-1, square_size do
        for x = 0, image:getWidth()-1, square_size do
          r, g, b, a = image:getPixel( x, y )
          palette_table[i] = {r, g, b, a}
          i = i + 1
        end
      end

      -- Assign Named Colors
      for k,v in pairs(named_colors) do
        palette_table.name[k] = palette_table[v]
      end

      -- Return the final table
      return palette_table
    end

    print("palette: enabled")
  end,

  -- Forces a color to apply alpha
  alpha = function()
    function m.alpha(color, value)
      assert(type(color) == "table", "Color must be in the format {r, g, b, a}.")
      assert(type(value) == "number", "Alpha value must be a number")
      return {color[1], color[2], color[3], value}
    end
    print("alpha: enabled")
  end,

  -- Blend two colors
  blend = function()
    local function lerp(a, b, c)
      return a + (b - a) * c;
    end

    function m.blend(color1, color2, scale)
      assert(type(color1) == "table", "First color must be in the format {r, g, b, a}.")
      assert(type(color2) == "table", "Second color must be in the format {r, g, b, a}.")
      scale = math.min(1, scale)
      scale = math.max(0, scale)
      return {
        lerp(color1[1], color2[1], scale),
        lerp(color1[2], color2[2], scale),
        lerp(color1[3], color2[3], scale),
        lerp(color1[4], color2[4], scale),
      }
    end
    print("blend: enabled")
  end,

}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Tinker with global settings
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(settings)

  -- Set reasonable defaults if none are supplied 
  settings = settings or {}

  -- If required, only apply certain items
  local load_only = settings.load_only or m.functions_list

  -- If required, remove items from being applied.
  if settings.remove then 
    for x=1, #settings.remove do
      for i=1, #load_only do
        if load_only[i] == settings.remove[x] then
          table.remove(load_only,i)
        end
      end
    end
  end

  -- Apply settings
  for i=1, #load_only do
    m.functions_code[load_only[i]]()
  end
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * RGB -> HSL # Some code from https://github.com/Wavalab/rgb-hsl-rgb/issues/1
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.rgb2hsl(r,g,b,a)
  -- We can take a table or values
  if type(r) == "table" then 
    a = r[4]; b = r[3]; g = r[2]; r = r[1]
  end
  -- We pass alpha along
  a = a or 1
  -- Get the highest/lowest RGB value
  local max, min = math.max(r,g,b), math.min(r,g,b)

  -- Set the base HSL
  local temphsl = (max + min)/2
  local h,s,l = temphsl, temphsl, temphsl
  -- Achromatic if max = min (Final will be Black-to-White)
  if max == min then 
    h = 0
    s = 0
  else -- This has a hue of some sort
    local diff = max - min
    if l > 0.5 then 
      s = diff / (2 - max - min)
    else
      s = diff / (max + min)
    end
    -- color size check 
    if max == r then 
      h = (g - b) / diff 
      if g < b then h = h + 6 end
    elseif max == g then 
      h = (b - r) / diff + 2
    elseif max == b then 
      h = (r - g) / diff + 4
    end
    -- h is 0-100 (0.0-1.0)
    h = h / 6 
  end

  return {h,s,l,a}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * HSL -> RGB # Some code from https://github.com/Wavalab/rgb-hsl-rgb/issues/1
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.hsl2rgb(h,s,l,a)
  local r,g,b
 -- We can take a table or values
 if type(h) == "table" then 
  a = h[4]; l = h[3]; s = h[2]; h = h[1]
end
  -- We pass alpha along
  a = a or 1

  if s == 0 then 
    r = l; g = l; b = l; -- Color will be white-black
  else 
    local function convert(p,q,t)
      if t < 0 then t = t + 1 end
      if t > 1 then t = t - 1 end
      if t < 1/6 then return p + (q - p) * 6 * t end
      if t < 1/2 then return q end
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
      return p
    end
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = convert(p, q, h + 1/3)
    g = convert(p, q, h);
    b = convert(p, q, h - 1/3)
  end

  return {r,g,b,a}
end

debugprint(unpack(m.rgb2hsl(1,0,0,1)))
debugprint(unpack(m.rgb2hsl(0,1,0,1)))
debugprint(unpack(m.hsl2rgb(m.rgb2hsl(1,0,0,1))))
debugprint(unpack(m.hsl2rgb(m.rgb2hsl(0,1,0,1))))


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m