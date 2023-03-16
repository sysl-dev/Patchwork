return {
  version = "1.9",
  luaversion = "5.1",
  tiledversion = "1.9.0",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 8,
  height = 8,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 2,
  nextobjectid = 1,
  properties = {
    ["get"] = {
      ["lock_x"] = true,
      ["lock_y"] = true
    }
  },
  tilesets = {
    {
      name = "open_rpg",
      firstgid = 1,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 60,
      image = "../texture/tileset/open_rpg.png",
      imagewidth = 960,
      imageheight = 768,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 2880,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 8,
      height = 8,
      id = 1,
      name = "Tile Layer 1",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        735, 148, 148, 148, 148, 148, 148, 735,
        735, 208, 208, 208, 208, 208, 208, 735,
        735, 268, 268, 268, 268, 268, 268, 735,
        735, 1708, 1708, 1708, 1708, 1708, 1708, 735,
        735, 1708, 1708, 1708, 1708, 1708, 1708, 735,
        735, 1708, 1708, 1708, 1708, 1708, 1708, 735,
        735, 1708, 1708, 1986, 1988, 1708, 1708, 735,
        735, 735, 735, 735, 735, 735, 735, 735
      }
    }
  }
}
