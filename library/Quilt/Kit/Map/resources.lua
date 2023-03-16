local m = {
  __NAME        = "Quilt-Kit-Map-Resources",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Throwing resources into it's own file.",
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


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup()
 
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  Resources 

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.movement = {
  move_test = {
    {"wait", 2},
    {"sprite", "witch"},
    {"wait", 0.1},
    {"face", 2},
    {"wait", 0.1},
    {-2,0},
    {2, 0},
    {"face", 5},
    {"sprite", "witch_brew"},
    {"force_animation", true},
   -- {"set", "facing_fixed", true}
  },
  run_around_the_square = {
    {2, 0},
    {0, 2},
    {-2, 0},
    {0, -2}
  },
}

return m