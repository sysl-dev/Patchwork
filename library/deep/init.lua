local deep = {
  _VERSION = "deep v2.0.3",
  _DESCRIPTION = "Queue and execute actions in sequence (can add Z axis to 2D graphics frameworks)",
  _URL = "https://github.com/Nikaoto/deep",
  _LICENSE = [[
  Copyright (c) 2017 Nikoloz Otiashvili

  Modifed by C Hall / SYSL to fix the queue and add a force value.

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
  ]]
}

local execQueue = {}
local storeQueue = {}
local maxIndex = 1
local forceOnTopValue = -1

-- for compatibility with Lua 5.1/5.2
local unpack = rawget(table, "unpack") or unpack

function deep.queue(i, draw_function_deep, ...)

  if type(i) ~= "number" then
    error("Error: deep.queue(): passed index is not a number" .. i)
    return nil
  end

  if type(draw_function_deep) ~= "function" then
    error("Error: deep.queue(): passed action is not a function" .. tostring(draw_function_deep))
    return nil
  end

  local arg = { ... }
  if i == forceOnTopValue then 
    storeQueue[#storeQueue +1] = {draw_function_deep}
  else
    if i < 1 then i = 1 end
    if i > maxIndex then maxIndex = i end
    if arg and #arg > 0 then
        local t = function() return draw_function_deep(unpack(arg)) end

        if execQueue[i] == nil then
        execQueue[i] = { t }
        else
        table.insert(execQueue[i], t)
        end
    else
        if execQueue[i] == nil then
        execQueue[i] = { draw_function_deep }
        else
        table.insert(execQueue[i], draw_function_deep)
        end
    end
    end
end

function deep.execute()
    for i = 1, #storeQueue do 
            execQueue[maxIndex +1] = storeQueue[i]
            maxIndex = maxIndex +1
    end
  for i = 1, maxIndex do
    if execQueue[i] then
      for _, draw_function_deep in pairs(execQueue[i]) do
        draw_function_deep()
      end
    end
  end

  execQueue = {}
  storeQueue = {}
  maxIndex = 1
end

return deep
