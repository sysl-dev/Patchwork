local selected_size = "hd_gb"

local size_type = {
  -- Modern Pixel
  hd_pixel = {w = 320, h = 180},
  hd_pixel_2x = {w = 640, h = 360},
  hd_gb = {w = 256, h = 144},
  
  -- Classic Sizes / Game Jam reference 
  gb = {w = 160, h = 144},
  gba = {w = 240, h = 160},
  ds = {w = 256, h = 192},
  tds = {w = 400, h = 240},
  nes = {w = 256, h = 240},
  snes = {w = 256, h = 224},
  nsf = {w = 320, h = 240},
  gc = {w = 640, h = 480},
  
  -- Standard Sizes
  size480 = {w = 720, h = 480},
  size720 = {w = 1280, h = 720},
  size1080 = {w = 1920, h = 1080},
}

local size = {
  w = size_type[selected_size].w,
  h = size_type[selected_size].h,
  }

-- There is no nice way to extract these, make them global.
BASE_WIDTH = size.w
BASE_HEIGHT = size.h
BASE_WIDTH_AND_HEIGHT = {BASE_WIDTH, BASE_HEIGHT}


function love.conf(t)
  t.identity = "Patchwork Engine"           -- The name of the save directory (string)
  t.appendidentity = false                  -- Search files in source directory before save directory (boolean)
  t.version = "11.4"                        -- The LÖVE version this game was made for (string)
  t.console = true                          -- Attach a console (boolean, Windows only)
  t.accelerometerjoystick = true            -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
  t.externalstorage = false                 -- True to save files (and read from the save directory) in external storage on Android (boolean) 
  t.gammacorrect = false                    -- Enable gamma-correct rendering, when supported by the system (boolean)

  t.audio.mic = false                       -- Request and use microphone capabilities in Android (boolean)
  t.audio.mixwithsystem = false             -- Keep background music playing when opening LOVE (boolean, iOS and Android only)

  t.window.title = "Patchwork Engine"       -- The window title (string)
  t.window.icon = nil                       -- Filepath to an image to use as the window's icon (string)
  t.window.width = size.w                   -- The window width (number)
  t.window.height = size.h                  -- The window height (number)
  t.window.borderless = false               -- Remove all border visuals from the window (boolean)
  t.window.resizable = false                -- Let the window be user-resizable (boolean)
  t.window.minwidth = size.w                -- Minimum window width if the window is resizable (number)
  t.window.minheight = size.h               -- Minimum window height if the window is resizable (number)
  t.window.fullscreen = false               -- Enable fullscreen (boolean)
  t.window.fullscreentype = "desktop"       -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
  t.window.vsync = 1                        -- Vertical sync mode (number)
  t.window.msaa = 0                         -- The number of samples to use with multi-sampled antialiasing (number)
  t.window.depth = nil                      -- The number of bits per sample in the depth buffer
  t.window.stencil = nil                    -- The number of bits per sample in the stencil buffer
  t.window.display = 1                      -- Index of the monitor to show the window in (number)
  t.window.highdpi = false                  -- Enable high-dpi mode for the window on a Retina display (boolean)
  t.window.usedpiscale = false              -- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
  t.window.x = nil                          -- The x-coordinate of the window's position in the specified display (number)
  t.window.y = nil                          -- The y-coordinate of the window's position in the specified display (number)

  t.modules.audio = true                    -- Enable the audio module (boolean)
  t.modules.data = true                     -- Enable the data module (boolean)
  t.modules.event = true                    -- Enable the event module (boolean)
  t.modules.font = true                     -- Enable the font module (boolean)
  t.modules.graphics = true                 -- Enable the graphics module (boolean)
  t.modules.image = true                    -- Enable the image module (boolean)
  t.modules.joystick = true                 -- Enable the joystick module (boolean)
  t.modules.keyboard = true                 -- Enable the keyboard module (boolean)
  t.modules.math = true                     -- Enable the math module (boolean)
  t.modules.mouse = true                    -- Enable the mouse module (boolean)
  t.modules.physics = true                  -- Enable the physics module (boolean)
  t.modules.sound = true                    -- Enable the sound module (boolean)
  t.modules.system = true                   -- Enable the system module (boolean)
  t.modules.thread = true                   -- Enable the thread module (boolean)
  t.modules.timer = true                    -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
  t.modules.touch = true                    -- Enable the touch module (boolean)
  t.modules.video = true                    -- Enable the video module (boolean)
  t.modules.window = true                   -- Enable the window module (boolean)
end
