local m = {
  __NAME        = "QU-Global-Defaults",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Changes global LOVE variables",
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
m.global_settings_list = {
  "nearest_filter",
  "line_rough",
  "faster_print",
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Store into a table for easy on/off
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.global_settings_functions = {
  nearest_filter = function()
    -- Forces Love to scale everything per pixel
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    print("nearest_filter: ON")
  end,

  line_rough = function()
    -- Forces lines style to be aligned to the grid
    love.graphics.setLineStyle("rough")
    print("line_rough: ON")
  end,

  faster_print = function()
    -- Make print commands not halt execution as much
    io.output():setvbuf("no")
    print("faster_print: ON")
  end,

  table_unpack = function()
    -- Hack if a library uses table.unpack
    table.unpack = unpack
    print("table_unpack: ON")
  end,

  gfind_fix = function()
    -- Hack if a library uses string.gfind
    string.gfind = string.gmatch
    print("gfind_fix: ON")
  end,
}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Tinker with global settings
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(settings)

  -- Set reasonable defaults if none are supplied 
  settings = settings or {}

  -- If required, only apply certain items
  local global_settings_to_apply = settings.apply or m.global_settings_list

  -- If required, remove items from being applied.
  if settings.remove then 
    for x=1, #settings.remove do
      for i=1, #global_settings_to_apply do
        if global_settings_to_apply[i] == settings.remove[x] then
          table.remove(global_settings_to_apply,i)
        end
      end
    end
  end

  -- Apply settings
  for i=1, #global_settings_to_apply do
    m.global_settings_functions[global_settings_to_apply[i]]()
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m