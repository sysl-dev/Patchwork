--[[--------------------------------------------------------------------------------------------------------------------------------------------------

  * Default Save Tables

--------------------------------------------------------------------------------------------------------------------------------------------------]]--
-- Save Information
GAME_SAVE = {
  -- Map Information 
  map = {
    last_event = nil,
  },
  -- Player Information
  player = {
    x = 0,
    y = 0,
    map = 0,
  },
  -- Event Flags
  flag = {
    -- ACTORS can create flags for the map they are on here
    actor = {

    },
    -- MAPS can use this for their own flags (map load events / run on enter events)
    map = {

    },
  },
  -- Players will need to hold items somehow
  inventory = {
    default = {

    },
  },
  -- Knowing what the user is holding/wearing will need to happen 
  equipment = {
    player = {
      
    },
  }
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
  }
}