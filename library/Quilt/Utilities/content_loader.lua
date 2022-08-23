local m = {
  __NAME = "Quilt-Utilities",
  __VERSION = "1.0",
  __AUTHOR = "C. Hall (Sysl)",
  __DESCRIPTION = "One off code functions - parent loader",
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
local function print(...) if m.debug then debugprint(m.__NAME .. ": ", unpack({...})) end end
print(m.__DESCRIPTION)

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Reused split by string function
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
local function split_string_by(str, sep)
  local return_string = {}
  local count_up_string = 1
  for word in str:gmatch("([^" .. sep .. "]*)") do
    return_string[count_up_string] = return_string[count_up_string] or word -- only set once (ignore blank after a string)
    -- step forwards only on a blank but not a string
    if word == "" then count_up_string = count_up_string + 1 end
  end
  return return_string
end

local function table_to_global_assignment(ordered_table, value)
  -- Walk down the path parts and create the tables as required
  local global_start = _G
  for walk_down_table = 1, #ordered_table do
    if walk_down_table ~= #ordered_table then
      global_start[ordered_table[walk_down_table]] = global_start[ordered_table[walk_down_table]] or {}
      global_start = global_start[ordered_table[walk_down_table]]
    else
      global_start[ordered_table[walk_down_table]] = value
    end
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Setup - Stub
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.setup(settings)
  -- Set reasonable defaults if none are supplied.
  settings = settings or {}
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Get all items in a folder, rewrite of:
  * https://love2d.org/wiki/love.filesystem.getDirectoryItems#Recursively_find_and_display_all_files_and_folders_in_a_folder_and_its_subfolders.
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.get_file_list(folder, settings)
  settings = settings or {}

  local final_file_list = {}
  local filesTable = love.filesystem.getDirectoryItems(folder)
  for i = 1, #filesTable do
    local file = folder .. "/" .. filesTable[i]
    local info = love.filesystem.getInfo(file)
    if info.type == "file" then
      final_file_list[#final_file_list + 1] = {file, "file", file:match("^.+(%..+)$")}
      if final_file_list[#final_file_list][3]:find("/") then final_file_list[#final_file_list][3] = false end
    elseif info.type == "directory" then
      final_file_list[#final_file_list + 1] = {file, "directory", false}
      local table = m.get_file_list(file)
      for dir_table = 1, #table do final_file_list[#final_file_list + 1] = table[dir_table] end
    end
  end

  -- This could likely be wrote so it only have to loop through once to check
  -- the conditions. TODO: Consider fixing this // Priority: Low 

  -- Keep only files
  if settings.file_only then
    for i = #final_file_list, 1, -1 do
      if final_file_list[i][2] == "directory" then table.remove(final_file_list, i) end
    end
  end

  -- Keep only the file types in the sent table
  if settings.keep then
    for i = #final_file_list, 1, -1 do
      local keepfile = false
      for keep = 1, #settings.keep do
        local keeptest = final_file_list[i][3] == settings.keep[keep]
        keepfile = keepfile or keeptest
      end
      if not keepfile then table.remove(final_file_list, i) end
    end
  end

  -- Remove the file types in the sent table
  if settings.remove then
    for i = #final_file_list, 1, -1 do
      local remove = false
      for keep = 1, #settings.remove do
        local remove_test = final_file_list[i][3] == settings.remove[keep]
        remove = remove or remove_test
      end
      if remove then table.remove(final_file_list, i) end
    end
  end

  -- Remove no extension
  if settings.has_file_extension then
    for i = #final_file_list, 1, -1 do if final_file_list[i][3] == false then table.remove(final_file_list, i) end end
  end

  return final_file_list
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Image Loader
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.texture(name_of_global_table, path)

  -- Create the global table to hold the image assets if not made.
  if not _G[name_of_global_table] then _G[name_of_global_table] = {} end

  -- Grab only the image files
  local image_list = m.get_file_list(path, {
    keep = {".png", ".jpg", ".gif", ".bmp"},
  })

  -- For each file
  for i = 1, #image_list do
    -- Remove the path prefix and change all / into .
    local string_without_start_of_path = image_list[i][1]:gsub(path .. "/", "")
    string_without_start_of_path = string_without_start_of_path:gsub("/", ".")

    -- Split into a table of path parts, add the global table start, remove the file extension
    local folder_bits = split_string_by(string_without_start_of_path, ".")
    table.insert(folder_bits, 1, name_of_global_table)
    table.remove(folder_bits, #folder_bits)

    table_to_global_assignment(folder_bits, love.graphics.newImage(image_list[i][1]))
  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Lua Loader
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.flat_lua(name_of_global_table, path)

  -- Create the global table to hold the image assets if not made.
  if not _G[name_of_global_table] then _G[name_of_global_table] = {} end

  -- Grab only the lua files
  local lua_list = m.get_file_list(path, {
    keep = {".lua"},
  })

  -- For each file
  for i = 1, #lua_list do

    -- Split into a table of path parts, add the global table start, remove the file extension
    local folder_bits = split_string_by(lua_list[i][1], "/")

    -- Remove Extension
    folder_bits[#folder_bits] = folder_bits[#folder_bits]:sub(1, -5)

    -- Flat require the folder, don't worry about levels
    -- TABLE[LAST TABLE NAME] = Require 
    _G[name_of_global_table][folder_bits[#folder_bits]] = require(table.concat(folder_bits, "."))

  end
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Shader Loader
--------------------------------------------------------------------------------------------------------------------------------------------------]] --
function m.flat_shader(name_of_global_table, path)

  -- Create the global table to hold the image assets if not made.
  if not _G[name_of_global_table] then _G[name_of_global_table] = {} end

  -- Grab only the lua files
  local lua_list = m.get_file_list(path, {
    keep = {".glsl"},
  })

  -- For each file
  for i = 1, #lua_list do

    -- Split into a table of path parts, add the global table start, remove the file extension
    local folder_bits = split_string_by(lua_list[i][1], "/")

    -- Flat require the folder, don't worry about levels
    -- TABLE[LAST TABLE NAME] = Require 
    _G[name_of_global_table][folder_bits[#folder_bits]] = love.graphics.newShader(table.concat(folder_bits, "/"))

    -- Yell at me if shaders are not valid.
    -- Allow this yell even if debug is turned off.
    local pass, message = love.graphics.validateShader(true, table.concat(folder_bits, "/"))
    if not pass then debugprint("WARNING: \n", table.concat(folder_bits, "/"), "\n", pass, message) end

  end
end

return m
