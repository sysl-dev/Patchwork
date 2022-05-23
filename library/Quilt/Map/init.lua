local m = {
  __NAME        = "Quilt-Map",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Map features - Parent Loader",
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

-- We load all items in this order.
m.sub_modules_list = {

}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(path, settings)
  -- Set reasonable defaults if none are supplied.
  path = path or ""
  settings = settings or {}

  -- We load all items in this order.
  local sub_modules = m.sub_modules_list

  -- Load the items as subtables to Utilities 
  for i=1, #sub_modules do 
    -- Yell
    print("Loaded:",sub_modules[i])
    -- Load the items
    m[sub_modules[i]] = require(path .. "." .. sub_modules[i])
    -- Apply settings
    m[sub_modules[i]].setup(settings[sub_modules[i]])
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m