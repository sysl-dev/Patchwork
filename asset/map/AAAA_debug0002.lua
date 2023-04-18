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
  nextlayerid = 6,
  nextobjectid = 9,
  backgroundcolor = { 25, 20, 25 },
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
      properties = {
        ["render_as"] = "background"
      },
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
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 8,
      height = 8,
      id = 3,
      name = "Tile Layer 2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["render_as"] = "background"
      },
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 335, 336, 0,
        0, 0, 0, 0, 0, 395, 396, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 8,
      height = 8,
      id = 4,
      name = "Tile Layer 3",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["render_as"] = "background"
      },
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 214, 0, 0, 222, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 334, 0, 0,
        0, 0, 0, 0, 0, 0, 340, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "Object Layer 1",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["object_type"] = "sprite"
      },
      objects = {
        {
          id = 1,
          name = "WarpTest",
          class = "sprite",
          shape = "rectangle",
          x = 48,
          y = 106.5,
          width = 32,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {
            ["warp_effect"] = "web",
            ["warp_effect_speed"] = 1,
            ["warp_facing"] = 0,
            ["warp_map"] = "AAAA_debug0000",
            ["warp_x"] = 274,
            ["warp_y"] = 96
          }
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 5,
      name = "Object Layer 2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["object_type"] = "collision"
      },
      objects = {
        {
          id = 2,
          name = "",
          class = "",
          shape = "rectangle",
          x = 16,
          y = 0,
          width = 96,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          class = "",
          shape = "rectangle",
          x = 112,
          y = 0,
          width = 16,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "",
          class = "",
          shape = "rectangle",
          x = 80,
          y = 112,
          width = 32,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 5,
          name = "",
          class = "",
          shape = "rectangle",
          x = 16,
          y = 112,
          width = 32,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "",
          class = "",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 16,
          height = 128,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "",
          class = "",
          shape = "rectangle",
          x = 80,
          y = 48,
          width = 16,
          height = 8,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "",
          class = "",
          shape = "rectangle",
          x = 96,
          y = 48,
          width = 16,
          height = 8,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
