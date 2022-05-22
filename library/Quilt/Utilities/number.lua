local m = {
  __NAME        = "QU-Numbers",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Let's format some numbers.",
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
  "clock_format",
  "cash_format",
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Store into a table for easy on/off
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
m.functions_code = {
  -- Format to match a digital clock view. 
  clock_format = function()
    function m.clock_format(time_seconds, settings)
      -- Checking User Input
      assert(type(time_seconds) == "number", "Time sent to clock format must be a number.")
      settings = settings or {}
      assert(type(settings) == "table", "Settings must be a table if set.")

      -- Lazy hack for negitive numbers
      local unit = ""
      if time_seconds < 0 then unit = "-" end
      time_seconds = math.abs(time_seconds)

      local hour = string.format("%02.f", math.floor(time_seconds/3600))
      local minute = string.format("%02.f", math.floor(time_seconds/60 - (hour * 60)))
      local second = string.format("%02.f", math.floor(time_seconds - hour * 3600 - minute * 60))

      local final_result = unit .. hour .. ":" .. minute .. ":" .. second
      if settings.hour_minute then final_result = unit .. hour .. ":" .. minute end
      if settings.minute_second then final_result = unit .. minute .. ":" .. second end
      if settings.second then final_result = unit .. second end
      return final_result

    end
    print("clock_format: enabled")
  end,

  -- Format to match a cash view. (1,000,000.00) 
  cash_format = function()
    function m.cash_format(money_value, settings)
      -- Checking User Input
      assert(type(money_value) == "number", "Time sent to cash format must be a number.")
      settings = settings or {}
      assert(type(settings) == "table", "Settings must be a table if set.")

      -- Round to two places
      local final_result = string.format("%.2f", money_value) 
      -- Reverse, add commas in groups of three.
      -- This way we get it starting from the end without more work.
      -- (Capture), (Return Capture)(Add Comma)
      final_result = final_result:reverse():gsub("(%d%d%d)", "%1,")
      -- Return the string to normal and return it
      final_result = final_result:reverse()
      -- If we are removing cents, remove the end.
      if settings.no_cents then final_result = final_result:sub(1, -4) end
      return final_result

    end
    print("clock_format: enabled")
  end,


}
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Tinker with global settings
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function m.setup(settings)

  -- Set reasonable defaults if none are supplied 
  settings = settings or {}

  -- If required, only apply certain items
  local functions_to_apply = settings.apply or m.functions_list

  -- If required, remove items from being applied.
  if settings.remove then 
    for x=1, #settings.remove do
      for i=1, #functions_to_apply do
        if functions_to_apply[i] == settings.remove[x] then
          table.remove(functions_to_apply,i)
        end
      end
    end
  end

  -- Apply settings
  for i=1, #functions_to_apply do
    m.functions_code[functions_to_apply[i]]()
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return m