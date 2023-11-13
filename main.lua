-- Some third party 3d library

-- a pathfinding library

-- some ui helpers 

--[[
Ok so like, a UI object is like it's own thing, it has a width/height and other parts 

So, like, it could be as simple as:
Volume < Number > 
Label button value button 
Or 
Music Track:
< Green Sky > 
Label 
Button Value Button

These things should give value by returning: Can the cursor select it? Does it have any sub-selections for the cursor?

A list of OI objects then can see if the user presses up/down or left/right what should happen.
Then the UI could also respond to mouse clicks if they are existing.
]]--


--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Logic to Load Save Values

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Import the default save values 
require('data')

-- Check if save files exist and process them. If the player loads later we can replace them 
-- TODO 

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Runs after everything in main.lua have been completed.

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(Debug_screen.ui_test)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Load Help - Heart of the Patchwork Library, a framework that extends LOVE with more features.

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Help = require("library.Quilt.Help")
Help.slice9 = require("library.Quilt.Help.Slice9")

Pixelscreen = require("library.Quilt.Pixel-Perfect")
Pixelscreen.setup({
  vsync = GAME_CONFIG.video.vsync,
  scale = GAME_CONFIG.video.scale,
})

Camera = require("library.Quilt.Camera")
Camera.setup()

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Assets

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Fonts - Load all fonts used in this project.
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Font = {
  golden_apple = love.graphics.newFont("asset/font/golden_apple/golden_apple.fnt",
      "asset/font/golden_apple/golden_apple.png"),
  earth_illusion = love.graphics.newFont("asset/font/earth_illusion/earth_illusion.fnt",
      "asset/font/earth_illusion/earth_illusion.png"),
  ack_recall = love.graphics.newFont("asset/font/ack_recall/AckRecall.ttf", 16, "mono"),
  royal_fibre = love.graphics.newFont("asset/font/royal_fibre/RoyalFibre.ttf", 16, "mono"),
  cardboard_crown = love.graphics.newFont("asset/font/cardboard_crown/CardboardCrown.ttf", 32, "mono"),
  menu_card = love.graphics.newFont("asset/font/menu_card/MenuCard.ttf", 8, "mono"),
  nudge_orb = love.graphics.newFont("asset/font/nudge_orb/Nudge Orb.ttf", 8, "mono"),
  mini_card = love.graphics.newFont("asset/font/mini_card/MiniCard.ttf", 8, "mono"),
}

-- Fix Line Heights
Font.cardboard_crown:setLineHeight(0.6)
Font.menu_card:setLineHeight(1.2)

Font.default = Font.mini_card
love.graphics.setFont(Font.default)
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Art - Patchwork assumes a smaller game and pre-loads all art. 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Help.load.texture("Texture", "asset/texture")
Help.slice9.import_graphics_table({
  import_texture_container = "Texture.system.slice9"
})


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Pixel Shaders - Pre-load all pixel shaders 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Help.load.flat_shader("Shader", "asset/shader")
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
Draw_order = require("library.deep")
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Anim8 - Animation library for LÖVE - Enrique García Cota - License MIT
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Animation = require("library.anim8")
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Baton - Game Keyboard/Gamepad Controller - 	Andrew Minnich 	MIT License
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Baton = require("library.baton")
Controller = require("library.Quilt.Controller")
Controller.get_all_joysticks()
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Quilt - Game focused libraries - SysL (C. Hall)  - License MIT
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
local map_settings = {
  tileset_table = Texture.tileset,
  map_folder_path = "asset/map",
  starting_map = "AAAA_debug0000",
  starting_x = 18,
  starting_y = 32,
  starting_facing = 4,
  player_width = 16,
  player_height = 16,
  actor_collision_image = Texture.system.icons.debug_icons,
  actor_collision_image_size = 8,
}

Map = require("library.Quilt.Map")
Map.setup("library.Quilt.Map", map_settings)

Gui = require("library.Quilt.PJs.init")
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Love Callbacks

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw - 
--------------------------------------------------------------------------------------------------------------------------------------------------]]-- `
function love.draw()
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update - 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.update(dt)
  if dt > 1 / 12 then return end
  Pixelscreen.update(dt)
  Timer.update(dt)
end
--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Resize - 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function love.resize(w, h)
  Pixelscreen.resize_love2d_window(w, h, true)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Debug

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
Help.load.flat_lua("Debug_screen", "asset/room-debug")
-- Utilities.load.flat_lua("screen", "asset/screen")
Help.debug_tools.print_globals()



print(Help.number.format_current_time())
--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * PATCHWORK ENGINE - Version 0.1 - January 28, 2022

--------------------------------------------------------------------------------------------------------------------------------------------------]]--

