local m = {
  __NAME = "QU-Numbers",
  __VERSION = "1.0",
  __AUTHOR = "C. Hall (Sysl)",
  __DESCRIPTION = "Let's format some numbers.",
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
  * Setup
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.setup(settings) end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Functions
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
-- Format to match a digital clock view. 
function m.clock_format(time_seconds, settings)
  -- Checking User Input
  assert(type(time_seconds) == "number", "Time sent to clock format must be a number.")
  settings = settings or {}
  assert(type(settings) == "table", "Settings must be a table if set.")

  -- Lazy hack for negitive numbers
  local unit = ""
  if time_seconds < 0 then unit = "-" end
  time_seconds = math.abs(time_seconds)

  local hour = string.format("%02.f", math.floor(time_seconds / 3600))
  local minute = string.format("%02.f", math.floor(time_seconds / 60 - (hour * 60)))
  local second = string.format("%02.f", math.floor(time_seconds - hour * 3600 - minute * 60))

  local final_result = unit .. hour .. ":" .. minute .. ":" .. second
  if settings.hour_minute then final_result = unit .. hour .. ":" .. minute end
  if settings.minute_second then final_result = unit .. minute .. ":" .. second end
  if settings.second then final_result = unit .. second end
  return final_result
end

-- Format to match a cash view. (1,000,000.00) 
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

-- Return the nearest multiple with no remainder (1-7,8 - 0, 8-15,8 - 8, etc)
function m.tile_scale(num, base) 
  return math.floor(num / base) * base 
end

-- Format OS Time with some lazy commands 
function m.format_ostime()
  --[[
    %a	abbreviated weekday name (e.g., Wed)
    %A	full weekday name (e.g., Wednesday)
    %b	abbreviated month name (e.g., Sep)
    %B	full month name (e.g., September)
    %c	date and time (e.g., 09/16/98 23:48:10)
    %d	day of the month (16) [01-31]
    %H	hour, using a 24-hour clock (23) [00-23]
    %I	hour, using a 12-hour clock (11) [01-12]
    %M	minute (48) [00-59]
    %m	month (09) [01-12]
    %p	either "am" or "pm" (pm)
    %S	second (10) [00-61]
    %w	weekday (3) [0-6 = Sunday-Saturday]
    %x	date (e.g., 09/16/98)
    %X	time (e.g., 23:48:10)
    %Y	full year (1998)
    %y	two-digit year (98) [00-99]
    %%	the character `%´
    ]]--
  local current_time = os.time()
  local default_format = os.date("%A", current_time) -- Wednesday
  local date_format = os.date("%x", current_time) -- "01/14/22"
  local time_format = os.date("%X", current_time) -- "22:03:09"
  local time_format_12h = os.date("%I:%M:%S %p", current_time) -- 07:30:41 PM
  return default_format, date_format, time_format_12h, time_format
end


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * End of File
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
return m
