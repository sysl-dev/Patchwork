local m = {
  __NAME        = "Quilt-Slice9",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Image to Frame, Woo Hoo",
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
-- Table that holds the generated frames.
m.select = {}
m.image_table = nil

local print = print
local debugprint = print
local function print(...)
  if m.debug then
    debugprint(m.__NAME .. ": ", unpack({...}))
  end
end print(m.__DESCRIPTION)


local function stringSplitSingle(str,sep)
  local return_string={}
  local n=1
  for w in str:gmatch("([^"..sep.."]*)") do
      return_string[n] = return_string[n] or w -- only set once (so the blank after a string is ignored)
      if w=="" then
          n = n + 1
      end -- step forwards on a blank but not a string
  end
  return return_string
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup (if Required)
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(settings) end

-- Import after Graphics are Loaded
function m.import_graphics_table(settings)
  -- Set reasonable defaults if none are supplied.
  settings = settings or {}
  local import_texture_container = settings.import_texture_container
  assert(import_texture_container, "The table where the frames are stored is required. If you do not require slice9, do not load it.")
    local table_parts = stringSplitSingle(import_texture_container, ".")
    m.image_table = _G
    for i=1, #table_parts do 
      m.image_table = m.image_table[table_parts[i]]
    end
    --m.image_table = {}
    for i,v in pairs(m.image_table) do
        local temptable = {}
        temptable = stringSplitSingle(i,"_")
        if #temptable == 2 then
            temptable[2] = tonumber(temptable[2])
            m.create(
                temptable[1], 
                i,
                temptable[2],
                temptable[2],
                temptable[2],
                temptable[2],
                temptable[2],
                temptable[2]
            )
        elseif #temptable == 7 then
            m.create(
                temptable[1], 
                i, 
                tonumber(temptable[2]),
                tonumber(temptable[3]),
                tonumber(temptable[4]),
                tonumber(temptable[5]),
                tonumber(temptable[6]),
                tonumber(temptable[7])
            )
        else
            assert(false, "Error: Frame name does not match format. Name_Size, or Name_Size1_Size2_...Size_6")
        end
        end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Slice Frame
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.create(name, imagename, size, size2, size3, size4, size5, size6)
  local image_width = size + size2 + size3
  local image_height = size4 + size5 + size6
  m.select[name] = {
  ["image"] = imagename,
  ["sizes"] = {size,size2,size3,size4,size5,size6}, -- X Width 1, 2, 3 Row, Y same Col
  ["top_left"] =        love.graphics.newQuad(0,                 0,                   size, size4, image_width, image_height),
  ["top_middle"] =      love.graphics.newQuad(0 + size,          0,                   size2, size4, image_width, image_height),
  ["top_right"] =       love.graphics.newQuad(0 + size + size2,  0,                   size3, size4, image_width, image_height),
  ["middle_left"] =     love.graphics.newQuad(0,                 0 + size4,           size, size5, image_width, image_height),
  ["middle_middle"] =   love.graphics.newQuad(0 + size,          0 + size4,           size2, size5, image_width, image_height),
  ["middle_right"] =    love.graphics.newQuad(0 + size + size2,  0 + size4,           size3, size5, image_width, image_height),
  ["bottom_left"] =     love.graphics.newQuad(0,                 0 + size4 + size5,   size, size6, image_width, image_height),
  ["bottom_middle"] =   love.graphics.newQuad(0 + size,          0 + size4 + size5,   size2, size6, image_width, image_height),
  ["bottom_right"] =    love.graphics.newQuad(0 + size + size2,  0 + size4 + size5,   size3, size6, image_width, image_height),
  }
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw a frame with the middle stretched out.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw(name,x,y,w,h)
  x = math.floor(x)
  y = math.floor(y)
  w = math.floor(w)
  h = math.floor(h)
  local frame_library = m.image_table
  local frame_data = m.select[name]
  assert(frame_data, "Frame chosen must exist in the folder!")
  local frame_selected = frame_library[frame_data.image]
  local width_center = (w - frame_data.sizes[1] - frame_data.sizes[3]) / frame_data.sizes[2]
  local height_center = (h - frame_data.sizes[4] - frame_data.sizes[6]) / frame_data.sizes[5]
  local padding = {
      top = frame_data.sizes[4], 
      right = frame_data.sizes[3], 
      bottom = frame_data.sizes[6], 
      left = frame_data.sizes[1]
  }

  -- Middle - Top
  love.graphics.draw(frame_selected, frame_data["top_middle"], x + padding.left, y, 0, width_center, 1)
  -- Middle - Right
  love.graphics.draw(frame_selected, frame_data["middle_right"], x + w - padding.right, y + padding.top, 0, 1, height_center)
  -- Middle - Bottom
  love.graphics.draw(frame_selected, frame_data["bottom_middle"], x + padding.left, y + h - padding.bottom, 0, width_center, 1)
  -- Middle - Left
  love.graphics.draw(frame_selected, frame_data["middle_left"], x, y + padding.top, 0, 1, height_center)
  -- Corners
  love.graphics.draw(frame_selected, frame_data["top_left"], x, y)
  love.graphics.draw(frame_selected, frame_data["top_right"], x + w - padding.right, y)
  love.graphics.draw(frame_selected, frame_data["bottom_left"], x, y + h - frame_data.sizes[6])
  love.graphics.draw(frame_selected, frame_data["bottom_right"], x + w - padding.right, y + h - padding.bottom)
  -- Center 
  love.graphics.draw(frame_selected, frame_data["middle_middle"], x + padding.left, y + padding.top, 0, width_center, height_center)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw a frame with tiled.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.draw_tiled(name,x,y,w,h,config)
  x = math.floor(x)
  y = math.floor(y)
  w = math.floor(w)
  h = math.floor(h)
  local frame_library = m.image_table
  local frame_data = m.select[name]
  assert(frame_data, "Frame chosen must exist in library !")
  local frame_selected = frame_library[frame_data.image]
  local width_center = (w - frame_data.sizes[1] - frame_data.sizes[3]) / frame_data.sizes[2]
  local height_center = (h - frame_data.sizes[4] - frame_data.sizes[6]) / frame_data.sizes[5]
  local padding = {
      top = frame_data.sizes[4], 
      right = frame_data.sizes[3], 
      bottom = frame_data.sizes[6], 
      left = frame_data.sizes[1]
  }
  config = config or {}

  -- Overflow tiles by one
  config.overflow = config.overflow or 2

  -- Center 
  if config.tile_center then
      for tile_x = 1, math.floor(width_center + 0.5) do 
          for tile_y = 1, math.floor(height_center + 0.5) do 
              love.graphics.draw(
                  frame_selected, 
                  frame_data["middle_middle"], 
                  x + padding.left + frame_data.sizes[2] * (tile_x-1), 
                  y + padding.top + frame_data.sizes[5] * (tile_y-1)
              )
          end
      end
  else 
      love.graphics.draw(frame_selected, frame_data["middle_middle"], x + padding.left, y + padding.top, 0, width_center, height_center)
  end

  love.graphics.setScissor(x, y, w, h-padding.bottom)
  -- Middle - Left/Righ
  for tile_y = 1, math.floor(height_center + 0.5) + config.overflow do 
      love.graphics.draw(frame_selected, frame_data["middle_left"], x, y + padding.top + frame_data.sizes[5] * (tile_y-1))
      love.graphics.draw(frame_selected, frame_data["middle_right"], x + w - padding.right, y + padding.top + frame_data.sizes[5] * (tile_y-1))
  end

  love.graphics.setScissor(x, y, w-padding.right, h)
  -- Middle - Top/Bottom
  for tile_x = 1, math.floor(height_center + 0.5) + config.overflow do 
      love.graphics.draw(frame_selected, frame_data["top_middle"], x + padding.left + frame_data.sizes[2] * (tile_x-1), y)
      love.graphics.draw(frame_selected, frame_data["bottom_middle"], x + padding.left + frame_data.sizes[2] * (tile_x-1), y + h - padding.bottom)
  end
  love.graphics.setScissor()

  -- Corners
  love.graphics.draw(frame_selected, frame_data["top_left"], x, y)
  love.graphics.draw(frame_selected, frame_data["top_right"], x + w - padding.right, y)
  love.graphics.draw(frame_selected, frame_data["bottom_left"], x, y + h - frame_data.sizes[6])
  love.graphics.draw(frame_selected, frame_data["bottom_right"], x + w - padding.right, y + h - padding.bottom)
  -- End Drawing

end
--[[ End Frames ]]--------------------------------------------------------------

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m