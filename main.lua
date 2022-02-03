--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Runs after everything in main.lua have been completed.

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.load()

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Load Utilites - Heart of the Patchwork Library, a framework that extends LOVE with more features.

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Utilities = require("library.Quilt.Utilities")
Utilities.setup("library.Quilt.Utilities", {
  pixel_scale = { 
    no_global_changes = false,
    width = BASE_WIDTH or 320,
    height = BASE_HEIGHT or 180,
    --scale = 1,
  }
})

-- DEL
local palette = Utilities.color.palette.create("asset/texture/palette/vanilla-milkshake-8x.png", 8, {red = 4, blue = 5})
local a = 0
--/DEL
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Assets

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Art - Patchwork assumes a smaller game and pre-loads all art. 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Utilities.content_loader.textures("Texture", "asset/texture")

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Libraries

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * hump - Helper Utilities for Massive Progression - Matthias Richter - License MIT
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Gamestate = require("library.hump.gamestate")
Timer = require("library.hump.timer")
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * bump-niji - a Lua collision-detection library for axis-aligned rectangles - Enrique García Cota/ patch: shru - License MIT
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Bump = require("library.bump.bump-niji")
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * DEEP-slog - a tiny library for queuing and executing actions in sequence. - Nikoloz Otiashvili/ patch: SysL - License MIT
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Render = require("library.deep")
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Anim8 - Animation library for LÖVE - Enrique García Cota - License MIT
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Animation = require("library.anim8")
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Quilt - Game focused libraries - SysL (C. Hall)  - License MIT
--------------------------------------------------------------------------------------------------------------------------------------------------]]--

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Love Callbacks

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw - 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Utilities.pixel_scale.change_draw_after_shader(function() 
  love.graphics.draw(Texture.palette["vanilla-milkshake-8x"])
end)

function love.draw()
  Utilities.pixel_scale.start()
  love.graphics.setColor(0.2,0.2,0.2,1)
  love.graphics.background()
  love.graphics.resetColor()
  love.graphics.setColor(Utilities.color.blend(palette.name.blue, palette[12], (math.sin(a*10))))
  love.graphics.outlinePrintf({color = palette.name.blue, thick = true}, Utilities.number.cash_format(math.floor(math.sin(a) * 9999999999), {nocents = true}), 5, 100, 310, "center")
  love.graphics.setColor(Utilities.color.hex2color("FFFFFF"))
  Utilities.debug_tools.on_screen_debug_info({mouse_x = Utilities.pixel_scale.mouse.x, mouse_y = Utilities.pixel_scale.mouse.y})
  love.graphics.draw(Texture.palette["vanilla-milkshake-8x"])
  love.graphics.rectangle("fill", 0, 144-3, 1, 2)
  love.graphics.rectangle("fill", BASE_WIDTH-1, 144-3, 1, 2)
  love.graphics.rectangle("fill", BASE_WIDTH-1, 1, 1, 2)
  love.graphics.rectangle("fill", Utilities.pixel_scale.mouse.x, Utilities.pixel_scale.mouse.y, 1, 1)
  Utilities.pixel_scale.stop({})
  Utilities.pixel_scale.capture_draw()
end



--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update - 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.update(dt)
  a = a + dt
if dt > 1/30 then return end


Utilities.pixel_scale.update(dt)
end






--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Debug

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Utilities.debug_tools.print_globals()
--[[
for k,v in pairs(Utilities) do 

  if type(v) == "function" then
    print("Utilities." .. k .. "()")
  end
  if type(v) == "table" then
    for z,x in pairs(v) do 
      if type(x) == "function" then
        print("Utilities." .. k .. "." ..z .. "()")
      end
    end
  end
end



local files = Utilities.content_loader.get_file_list("", {keep = {".png"}})

print("--- Results")
for i=1, #files do 
  print(files[i][1], files[i][2], files[i][3])
end
--print(files)
]]--

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * PATCHWORK ENGINE - Version 0.1 - January 28, 2022

--------------------------------------------------------------------------------------------------------------------------------------------------]]--