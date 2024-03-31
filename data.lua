--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Default Save Tables

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Save Information
GAME_SAVE = {

}

--- Config 
GAME_CONFIG = {
  video = {
    vsync = 0,
    scale = nil,
  },
  audio = {
    volume = {
      music = 1,
      sfx = 1,
      vfx = 1,
      all = 1,
    },
  },
  system = {
    save_history = false, -- TODO: Keep archive of saves in folder
    button_icons = "default", -- default to msXinput
    mods = false,
  }
}