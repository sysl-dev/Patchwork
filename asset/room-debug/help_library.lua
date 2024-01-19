
local room = { __name = "help_library", __desc = "Test of all helper library commands" }
local timer = 0
local current_page = 1
local test_palette = Help.color.create_palette_table("asset/texture/system/palette/vanilla-milkshake-8x.png", 8, {red = 4, blue = 5, green = 9 })

local pages = {}
pages[#pages+1] = {}
pages[#pages].draw = function() 
  love.graphics.printf("Help Library Test Pages.\nNavigate with Left/Right.", 0, 0, __BASE_WIDTH__, "center")
end 
pages[#pages].update = function(dt) 

end
pages[#pages].keypressed = function(key) 

end

pages[#pages+1] = {}
pages[#pages].draw = function() 
  love.graphics.printf("Override Check:", 0, 0, __BASE_WIDTH__, "center")
  love.graphics.printf(string.format("Default filter Mode: %s, %s, %s", love.graphics.getDefaultFilter()), 0, 16, __BASE_WIDTH__, "left")
  love.graphics.printf(string.format("unpack: %s\ntable.unpack: %s", unpack, table.unpack ), 0, 32, __BASE_WIDTH__, "left")
  love.graphics.printf(string.format("string.gfind: %s\nstring.gmatch: %s", string.gfind, string.gmatch ), 0, 64, __BASE_WIDTH__, "left")
end 

pages[#pages+1] = {}
pages[#pages].draw = function() 
love.graphics.print(string.format([[White #FFFFFF -> %s
Black #000000 -> %s
Alpha 1111, 0.5 -> %s
Blend White/Black -> %s
RGB -> HSL (1,0,0,1):  %s
HSL back RGB:  %s

Palette Test:
]],
  table.concat(Help.color.read_hex("#ffffff"),", "),
  table.concat(Help.color.read_hex("#000000"),", "),
  table.concat(Help.color.alpha(Help.color.read_hex("#ffffff"),0.5),", "),
  table.concat(Help.color.blend({1,1,1,1}, {0,0,0,1}, 0.5),", "),
  table.concat(Help.color.convert_rgb_hsl({1,0,0,1}),", "),
  table.concat(Help.color.convert_hsl_rgb({0,1,0.5,1}),", ")
 )
)

for i=1, #test_palette do 
  love.graphics.setColor(test_palette[i])
  love.graphics.rectangle("fill", 9 * i, __BASE_HEIGHT__-8, 8, 8)
  Help.color.reset()
end
love.graphics.setColor(test_palette.get.red)
love.graphics.rectangle("fill", 9 * (#test_palette + 2), __BASE_HEIGHT__-8, 8, 8)
Help.color.reset()
love.graphics.setColor(test_palette.get.green)
love.graphics.rectangle("fill", 9 * (#test_palette + 3), __BASE_HEIGHT__-8, 8, 8)
Help.color.reset()
love.graphics.setColor(test_palette.get.blue)
love.graphics.rectangle("fill", 9 * (#test_palette + 4), __BASE_HEIGHT__-8, 8, 8)
Help.color.reset()
end 


pages[#pages+1] = {}
pages[#pages].draw = function() 
  local is_it_over = Help.mouse.over(0, 0, 100, 100, Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y(), 1, 1)
  love.graphics.print("Mouse Over 100x100: " .. tostring(is_it_over))
  love.graphics.rectangle("fill",Pixelscreen.mouse.get_x(), Pixelscreen.mouse.get_y(), 1,1)
  love.graphics.rectangle("line",0,0,100,100)
end 


pages[#pages+1] = {}
pages[#pages].draw = function() 
  love.graphics.print(string.format([[Timer (Default) -> %s
Timer (hour_minute) -> %s
Timer (minute_second) -> %s
Timer (second) -> %s
Cash: 13379 -> %s
Cash Cents: 13379.05 -> %s
Set values on 8x8 grid 1, 9, 43, 123 | %s, %s, %s, %s
Time: %s, %s
%s, %s
  ]],
  Help.number.format_timer(timer),
  Help.number.format_timer(timer, "hour_minute"),
  Help.number.format_timer(timer, "minute_second"),
  Help.number.format_timer(timer, "second"),
  Help.number.format_cash("13379"),
  Help.number.format_cash("13379.05", true),
  Help.number.fix_grid(1, 8),
  Help.number.fix_grid(9, 8),
  Help.number.fix_grid(43, 8),
  Help.number.fix_grid(123, 8),
  Help.number.format_current_time()
  )
  )
end 

pages[#pages+1] = {}
pages[#pages].draw = function() 
  Help.text.print_outline({color2 = test_palette.get.red, color1 = test_palette[7]}, "Wow, look at the outline.")
  Help.text.printf_outline({color2 = test_palette.get.blue, color1 = test_palette[9], thick = true}, "Wow, look at the outline contained in a box...", 0, 32, 80, "center")
end 

pages[#pages+1] = {}
pages[#pages].draw = function() 
  Help.text.print_outline({color2 = test_palette.get.red, color1 = test_palette[7]}, "Press P/L to dump table.")
  if love.keyboard.isDown("p") then 
    print(Help.table.dump(test_palette))
  end
  if love.keyboard.isDown("l") then 
    print(Help.table.dump_clean(test_palette))
  end
end 

Help.art.repeating_background.new("test", Texture.system.background.pattern_square)
Help.art.repeating_background.delete("test")
Help.art.repeating_background.new("___test", Texture.system.background.pattern_square)
Help.art.repeating_background.new("___mirror", Texture.system.background.pattern_mirror, "mirroredrepeat")

pages[#pages+1] = {}
pages[#pages].draw = function() 
   Help.art.repeating_background.draw("___test", 0, 0)
   Help.text.print_outline({color2 = test_palette.get.red, color1 = test_palette[7], thick = true}, "Repeating Background.")
end 

pages[#pages+1] = {}
pages[#pages].draw = function() 
   Help.art.repeating_background.draw("___mirror", 0 - math.floor(timer*60) %(Texture.system.background.pattern_mirror:getWidth()*2), 0 - math.floor(timer*60) %(Texture.system.background.pattern_mirror:getHeight()*2))
   Help.text.print_outline({color2 = test_palette.get.red, color1 = test_palette[7], thick = true}, "Repeating Background.")
end 

pages[#pages+1] = {}
pages[#pages].draw = function() 
   Help.art.repeating_background.draw("___test", 0 - math.abs(timer*20) %(Texture.system.background.pattern_mirror:getWidth()*2), 0 - math.abs(timer*20) %(Texture.system.background.pattern_mirror:getHeight()*2))
   Help.text.print_outline({color2 = test_palette.get.red, color1 = test_palette[7], thick = true}, "Repeating Background.")
end 

local tp = {0,1,0,1}
local tp2 = {1,0,1,1}
pages[#pages+1] = {}
pages[#pages].draw = function() 
  Help.art.draw_rectangle_gradient(10, 10, 24, 24, test_palette[2], test_palette[3], "x")
  Help.art.draw_rectangle_gradient(10+25, 10, 24, 24, test_palette[1], test_palette[16], "y")
  Help.art.draw_rectangle_gradient(10+25*2, 10, 24, 24, test_palette[5], test_palette[14], "xy")
  Help.art.draw_rectangle_gradient(10+25*3, 10, 24, 24, tp, tp2, "c")
  Help.art.draw_rectangle_gradient(10+25*4, 10, 24, 24, tp, tp2, "c", 16)
  Help.art.draw_rectangle_gradient(10+25*5, 10, 24, 24, tp, tp2, "c", 32)
  Help.art.draw_rectangle_gradient(10+25*6, 10, 24, 24, test_palette[1], test_palette[16], "y", 8)
  Help.art.draw_rectangle_gradient(10+25*7, 10, 24, 24, test_palette[1], test_palette[16], "y", 32)
  Help.art.draw_disk(25, 10 + 25, 25, 95, 5)
  Help.art.draw_disk_gradient(76, 10 + 25, 25, math.sin(timer), -90, {1,0,0,1}, {0,0,1,1}, 10, "c")
  Help.art.draw_rectangle_gradient(10, 100, 24, 24 +  math.sin(timer) * 10, test_palette[2], test_palette[3], "x")
  Help.art.draw_rectangle_gradient(10+25, 100, 24, 24 +  math.sin(timer) * 10, test_palette[1], test_palette[16], "y")
  Help.art.draw_rectangle_gradient(10+25*2, 100, 24, 24 +  math.sin(timer) * 10, test_palette[5], test_palette[14], "xy")
  Help.art.draw_rectangle_gradient(10+25*3, 100, 24, 24 +  math.sin(timer) * 10, test_palette[4], test_palette[9], "c")
end 

pages[#pages+1] = {}
pages[#pages].draw = function() 
  Help.art.slice9.draw("pattern", 5, 5, 50, 50)
  Help.art.slice9.draw_tiled("pattern", 5 + 51 * 1, 5, 50, 50)
  Help.art.slice9.draw_tiled("pattern", 5 + 51 * 2, 5, 48, 48, {tile_center = true})
end 
pages[#pages+1] = {}
pages[#pages].draw = function() 
  Help.art.slice9.draw("pattern", 5, 5, 5 +  math.sin(timer) * 100, 50)
  Help.art.slice9.draw_tiled("pattern", 5 + 75 * 1, 5, 50 +  math.sin(timer) * 10, 50)
  local w = Help.number.fix_grid(50 +  math.sin(timer) * 100, 8)
  local h = Help.number.fix_grid(50 +  math.sin(timer) * 0, 8)
  Help.art.slice9.draw_tiled("pattern", 5 + 75 * 2, 5, w, h, {tile_center = true})
end 
pages[#pages+1] = {}
pages[#pages].draw = function() 
  Help.art.slice9.draw("pattern", 5, 5, 50, 50 +  math.sin(timer) * 100)
  Help.art.slice9.draw_tiled("pattern", 5 + 75 * 1, 5, 50, 50 +  math.sin(timer) * 100)
  local w = Help.number.fix_grid(50 +  math.sin(timer) * 0, 8)
  local h = Help.number.fix_grid(50 +  math.sin(timer) * 100, 8)
  Help.art.slice9.draw_tiled("pattern", 5 + 75 * 2, 5, w, h, {tile_center = true})
end 
pages[#pages+1] = {}
pages[#pages].draw = function() 
  Help.art.slice9.draw("pattern", 5, 5, 50 +  math.sin(timer) * 100, 50 +  math.sin(timer) * 100)
  Help.art.slice9.draw_tiled("pattern", 5 + 75 * 1, 5, 50 + math.sin(timer) * 100, 50 +  math.sin(timer) * 100)
  local w = Help.number.fix_grid(50 +  math.sin(timer) * 100, 8)
  local h = Help.number.fix_grid(50 +  math.sin(timer) * 100, 8)
  Help.art.slice9.draw_tiled("pattern", 5 + 75 * 2, 5, w, h, {tile_center = true})
end 

function room:update(dt)
  timer = timer + dt
  if pages[current_page].update then
    pages[current_page].update()
  end
end

function room:draw(dt)
  Pixelscreen.start()
  Help.color.set("#000000")
  Help.art.fill_background()
  Help.color.reset()
  local capture_font = love.graphics.getFont()
  love.graphics.setFont(Font.golden_apple)
  pages[current_page].draw()
  love.graphics.setFont(capture_font)
  Pixelscreen.stop()
end



function room:keypressed(key, scan, isrepeat)
  if key =="escape" then 
  Gamestate.pop()
  end

  if key == "left" then 
    current_page = current_page - 1
  end
  if key == "right" then 
    current_page = current_page + 1
  end
  if current_page > #pages then current_page = 1 end
  if current_page <= 0 then current_page = #pages end
  if pages[current_page].keypressed then
    pages[current_page].keypressed()
  end
end

return room