local m = {
  __NAME        = "Quilt-Utilities",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "One off code functions - parent loader",
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


m.utilities_list = {
  "global_defaults",
  "love_patch",
  "color",
}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(path, settings)
  -- Set reasonable defaults if none are supplied.
  path = path or ""
  settings = settings or {}

  -- Check to see if we are only loading some of the items
  local utilities_to_load = settings.load_only or m.utilities_list

  -- If required, remove items from being applied.
  if settings.remove then 
    for x=1, #settings.remove do
      for i=1, #utilities_to_load do
        if utilities_to_load[i] == settings.remove[x] then
          table.remove(utilities_to_load,i)
        end
      end
    end
  end

  -- Load the items as subtables to Utilities 
  for i=1, #utilities_to_load do 
    -- Load the items
    m[utilities_to_load[i]] = require(path .. "." .. utilities_to_load[i])
    -- Apply settings
    m[utilities_to_load[i]].setup(settings[utilities_to_load[i]])
  end
end

return m