--- Needs: Remove from Examine, Remove from Filter
-- Needs, Clean Removal


local m = {
  __NAME        = "DEFT",
  __VERSION     = "1.0",
  __AUTHOR      = "C. Hall (Sysl)",
  __DESCRIPTION = "Data, Examine, Filter, Task - A different way of looking at composition.",
  __URL         = "http://github.sysl.dev/",
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2024 Chris / Systemlogoff

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
  __DEBUG = 3, -- Warning, Info, Noise 
}

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Library Debug Mode

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local function print_warning(...)
  if m.__DEBUG >= 1 then 
    print(m.__NAME .. "-WARNING:")
    print(...)
    print("")
  end
end

local function print_information(...)
  if m.__DEBUG >= 2 then 
    print(m.__NAME .. "-INFORMATION:")
    print(...)
    print("")
  end
end

local function print_noise(...)
  if m.__DEBUG >= 2 then 
    print(m.__NAME .. "-NOISE:")
    print(...)
    print("")
  end
end
  --[[----------------------------------------------------------------------------------------------------
        Create new DEFT system
  ----------------------------------------------------------------------------------------------------]]--


function m.new(bool_error_duplicate)
  --[[----------------------------------------------------------------------------------------------------
        Create new DEFT system
  ----------------------------------------------------------------------------------------------------]]--
  local DEFT = {}
  --[[----------------------------------------------------------------------------------------------------
        Storage within system
  ----------------------------------------------------------------------------------------------------]]--
  DEFT.examine = {}                               -- has filters
  -- DEFT.examine.name = {filter, filter, filter, filter}
  DEFT.filter = {}                                -- has tasks
  -- DEFT.filter.name = {filter_function = fun, tasks = {task, task, task task}}
  DEFT.task = {}                                  -- function calls
  -- DEFT.task.name = function(data, ...) end
  DEFT.register = {examine = {}, filter = {}}

  --[[----------------------------------------------------------------------------------------------------
        Create new Examine Data queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_new(string_name)
    -- Error if this is a duplicate value
    if bool_error_duplicate then
      assert(type(DEFT.examine[string_name]) == "nil", "This examine was defined!")
    end
    -- Create new empty examine queue
    DEFT.examine[string_name] = {}
    DEFT.register.examine[string_name] = {filter = {}}
  end

  --[[----------------------------------------------------------------------------------------------------
        Remove Examine Data queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_delete(string_name)
    -- Remove the examine queue
    DEFT.examine[string_name] = nil
    DEFT.register.examine[string_name] = nil
  end

  --[[----------------------------------------------------------------------------------------------------
        Run though the Examine Data Queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_run(string_name, data, string_sort_method, ...)
    local extra_data = {...}
    -- standard, reverse, ???
    string_sort_method = string_sort_method or "standard"

    local function process_data(data, data_selection, extra_data)
      -- Walk though each filter added to the examine queue
      for filter_current = 1, #DEFT.examine[string_name] do
        -- Select a filter
        local this_filter = DEFT.examine[string_name][filter_current]
        -- Check data selection with filter, if it passes then
        if this_filter.filter_function(data, data_selection, extra_data) then
          -- Run each task inside the filter
          for task = 1, #this_filter.tasks do
            this_filter.tasks[task](data, data_selection, extra_data)
          end
        end
      end
    end

    -- We can normally walk though the queue from 1 to end
    if string_sort_method == "standard" then
      for data_selection = 1, #data do
        process_data(data, data_selection, extra_data)
      end
    end

    -- However, if we are removing items it might be better to step backwards.
    if string_sort_method == "reverse" then
      for data_selection = #data, 1, -1 do
        process_data(data, data_selection, extra_data)
      end
    end
  end

  --[[----------------------------------------------------------------------------------------------------
        Add filter to Examine Data Queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_add_filter(string_examine_name, string_filter_name)
    assert(DEFT.register.examine[string_examine_name].filter[string_filter_name] == nil, string_filter_name .. " in examine queue!")
    local examine_queue = DEFT.examine[string_examine_name]
    examine_queue[#examine_queue + 1] = DEFT.filter[string_filter_name]
    -- Store the number of the filter to remove later.
    DEFT.register.examine[string_examine_name].filter[string_filter_name] = #examine_queue
    print_information(string_filter_name, string_examine_name,  DEFT.register.examine[string_examine_name].filter[string_filter_name])
  end

  --[[----------------------------------------------------------------------------------------------------
        Remove filter from Examine Data Queue
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.examine_delete_filter(string_examine_name, string_filter_name)
    local filter_number = DEFT.register.examine[string_examine_name].filter[string_filter_name]
    local examine_queue = DEFT.examine[string_examine_name]
    if filter_number then
      table.remove(examine_queue, filter_number)
      DEFT.register.examine[string_examine_name].filter[string_filter_name] = nil
    else
      print_warning("WARNING: " .. string_filter_name .. " does not exist in " .. string_examine_name)
    end
  end

  --[[----------------------------------------------------------------------------------------------------
        Create new Filter Function
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.filter_new(string_name, function_filter)
    -- Error if this is a duplicate value
    if bool_error_duplicate then
      assert(type(DEFT.filter[string_name]) == "nil", "filter_new has been defined!")
    end
    -- Create new filter function and task queue
    DEFT.filter[string_name] = { filter_function = function_filter, tasks = {} }
    DEFT.register.filter[string_name] = {task = {}}
  end

  --[[----------------------------------------------------------------------------------------------------
        Create new Filter Function
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.filter_delete(string_name)
    -- Remove the filter
    DEFT.filter[string_name] = { filter_function = nil, tasks = nil }
    DEFT.filter[string_name] = nil
    DEFT.register.filter[string_name] = {task = {}}
  end

  --[[----------------------------------------------------------------------------------------------------
        Add task to Filter 
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.filter_add_task(string_filter_name, string_task_name)
    assert(DEFT.register.filter[string_filter_name].task[string_task_name] == nil, string_filter_name .. " in filter queue!")
    local filter_tasks = DEFT.filter[string_filter_name].tasks
    filter_tasks[#filter_tasks + 1] = DEFT.task[string_task_name]
    DEFT.register.filter[string_filter_name].task[string_task_name] = #filter_tasks
  end

  --[[----------------------------------------------------------------------------------------------------
        Add task to Filter 
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.filter_delete_task(string_filter_name, string_task_name)
    local task_number = DEFT.register.filter[string_filter_name].task[string_task_name]
    local filter_tasks = DEFT.filter[string_filter_name].tasks
    if task_number then 
      table.remove(filter_tasks, task_number)
      DEFT.register.filter[string_filter_name].task[string_task_name] = nil
    else
      print_warning("WARNING: " .. string_task_name .. " does not exist in " .. string_filter_name)
    end
    
  end
  
  --[[----------------------------------------------------------------------------------------------------
        Create new Task Function
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.task_new(string_name, function_task)
    -- Error if this is a duplicate value
    if bool_error_duplicate then
      assert(type(DEFT.task[string_name]) == "nil", "This task has been defined!")
    end
    -- Create new filter function and task queue
    DEFT.task[string_name] = function_task
  end

  --[[----------------------------------------------------------------------------------------------------
        Create new Filter Function
  ----------------------------------------------------------------------------------------------------]]--
  function DEFT.task_delete(string_name)
    -- Remove the filter
    DEFT.task[string_name] = nil
  end

  --[[----------------------------------------------------------------------------------------------------
        Return new DEFT System
  ----------------------------------------------------------------------------------------------------]]--
  return DEFT
end

return m
