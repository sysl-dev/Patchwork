local m = {
  __NAME = "Quilt-Mouse",
  __VERSION = "4.0",
  __AUTHOR = "C. Hall (Sysl)",
  __DESCRIPTION = "Graphical Cursor and Mouse Function",
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
m.debug = false
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
  * Setup (if Required)
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.setup(settings)
  -- Set reasonable defaults if none are supplied.
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup (if Required)
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.over(local_x, local_y, local_width, local_height, mouse_x, mouse_y, mouse_width, mouse_height)
  mouse_width = mouse_width or 1
  mouse_height = mouse_height or 1
  return local_x < mouse_x + mouse_width and 
          mouse_x < local_x + local_width and 
          local_y < mouse_y + mouse_height and
          mouse_y < local_y + local_height
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
return m
