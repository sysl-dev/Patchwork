
local room = {}
local timer = 0
local testing_room_name = {
}

local testing_room_desc = {
}

for k,v in pairs(Room_debug) do 
  testing_room_name[#testing_room_name+1] = k
  testing_room_desc[#testing_room_desc+1] = Room_debug[k].__desc
end

local currently_selected_room = 1

local function scale_up()
  currently_selected_room = currently_selected_room + 1
end

local function scale_down()
  currently_selected_room = currently_selected_room - 1
end


function room:update(dt)
  timer = timer + dt
end

function room:draw(dt)
  local capture_font = love.graphics.getFont()
  love.graphics.setFont(Font.cardboard_crown)
  Pixelscreen.start()
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("fill", 0, 0, 500, 500)
  Pixelscreen.stop()
  love.graphics.setColor(1,1,1,1)
  for i=1, #testing_room_name do 
    love.graphics.print(testing_room_name[i] .. ": " .. testing_room_desc[i], 32, (i +1) * 32)
  end
  love.graphics.print("➡", 6 + math.sin(timer * 8) * 3, 2 + (currently_selected_room + 1 ) * 32)
  if love.keyboard.isDown("`") then
    Help.debug_tools.on_screen_debug_info()
  end
  love.graphics.setFont(capture_font)
end


function room:keypressed(key, scan, isrepeat)
  if key == "return" then 
    Gamestate.push(Room_debug[testing_room_name[currently_selected_room]])
  end
  if key == "up" then 
    scale_down()
  end
  if key == "down" then 
    scale_up()
  end
  if currently_selected_room > #testing_room_name then currently_selected_room = 1 end
  if currently_selected_room <= 0 then currently_selected_room = #testing_room_name end
end

return room