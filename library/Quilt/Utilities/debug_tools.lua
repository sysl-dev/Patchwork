local m = {
  __NAME = "QU-Debug-Tools",
  __VERSION = "1.0",
  __AUTHOR = "C. Hall (Sysl)",
  __DESCRIPTION = "Tools used to debug my terrible code.",
  __URL = "http://github.sysl.dev/",
  __LICENSE = [[
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
  __LICENSE_TITLE = "MIT LICENSE",
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Library Debug Mode
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
m.debug = true
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Locals and Housekeeping
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
local print = print
local debugprint = print
local function print(...)
  if m.debug then
    debugprint(m.__NAME .. ": ", unpack({
      ...,
    }))
  end
end
print(m.__DESCRIPTION)

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Global Settings to Load
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
m.functions_list = {
  "print_globals",
  "on_screen_debug_info",
}


function m.dump_table(atable) 
  if type(atable) == 'table' then
     local s = '{ '
     for k,v in pairs(atable) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. m.dump_table(v) .. ','
     end
     return s .. '} '
  else
     return tostring(atable)
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Store into a table for easy on/off
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
m.functions_code = {
  -- Print a list of all things in the global namespace
  ["print_globals"] = function()
    local known_globals = {
      "_G",
      "_VERSION",
      "arg",
      "bit",
      "coroutine",
      "debug",
      "io",
      "jit",
      "love",
      "math",
      "module",
      "os",
      "package",
      "require",
      "string",
      "table",
    }
    function m.print_globals()
      -- Create to sort later
      local global_list_table = {}

      -- Step though the global namespace items, ignore built in functions
      for name_of_global, value_of_global in pairs(_G) do
        if not string.match(tostring(value_of_global), "builtin#") then
          global_list_table[name_of_global] = #global_list_table + 1
        end
      end

      -- Look at everything and sort it
      local global_list_sorted_table = {}
      for n in pairs(global_list_table) do table.insert(global_list_sorted_table, n) end
      table.sort(global_list_sorted_table)

      -- Print the final list, removing any default globals.
      print("---- Globals ----")
      for _, n in ipairs(global_list_sorted_table) do
        for i = 1, #known_globals do if n == known_globals[i] then n = nil end end
        if n then print("GLOBAL-ITEM: " .. n) end
      end
      print("---- Globals ----")
    end
    print("print_globals: enabled")
  end,

  ["on_screen_debug_info"] = function()
    function m.on_screen_debug_info(settings)
      settings = settings or {}
      local x = settings.x or 5
      local y = settings.y or 5
      local mx = tostring(settings.mouse_x or love.mouse.getX())
      local my = tostring(settings.mouse_y or love.mouse.getY())
      local fps = tostring(love.timer.getFPS())
      local draw_calls = tostring(love.graphics.getStats().drawcalls)
      local batch_calls = tostring(love.graphics.getStats().drawcallsbatched)
      local canvas_switches = tostring(love.graphics.getStats().canvasswitches)
      local texture_memory = tostring(love.graphics.getStats().texturememory / 1024 / 1024)
      local infostring = "FPS: " .. fps .. " Draw Calls: " .. draw_calls .. " Batched Calls: " .. batch_calls
      local moreinfo = " texturememory: " .. texture_memory .. "MB canvasswitches: " .. canvas_switches
      local extraline = tostring("Mouse X: " .. mx .. " Mouse Y: " .. my)
      local string_length = (love.graphics.getWidth()) - 10
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x, y - 1, string_length)
      love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x, y + 1, string_length)
      love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x - 1, y, string_length)
      love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x + 1, y, string_length)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.printf(infostring .. moreinfo .. "\n" .. extraline, x, y, string_length)
    end
  end,

}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Tinker with global settings
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.setup(settings)

  -- Set reasonable defaults if none are supplied 
  settings = settings or {}

  -- If required, only apply certain items
  local functions_to_apply = settings.apply or m.functions_list

  -- If required, remove items from being applied.
  if settings.remove then
    for x = 1, #settings.remove do
      for i = 1, #functions_to_apply do
        if functions_to_apply[i] == settings.remove[x] then table.remove(functions_to_apply, i) end
      end
    end
  end

  -- Apply settings
  for i = 1, #functions_to_apply do m.functions_code[functions_to_apply[i]]() end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
return m
