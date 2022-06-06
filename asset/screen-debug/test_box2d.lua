local scene = {}
local debug_shapes = true
local debug_name = false

local function color(str)
  str = str or "FFFFFF"
  love.graphics.setColor(Utilities.color.hex2color(str))
end

-------------------------------------------------------------------------------------------------------------------

local Wblock = require("library.Quilt.Kit.wooden_blocks")
scene.object_pool = {}
scene.joint_pool = {}

Wblock.setup({
  -- We can pass x/y/sleep options if we are not passing a world.
  world_gravity_x = 0,
  world_gravity_y = 1000,
  world_allow_sleep = true,
  pixels_per_meter = 16,
  mouse = {Utilities.pixel_scale.mouse.get_x, Utilities.pixel_scale.mouse.get_y},
  maxdt = 1/15,
  pause = false,
  debug_colors = {
    shape = {0.9,0.9,0.9,1},
    joint = {1,0.2,0,1},
    name = {0,0.8,1,1},
    }
})


--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Test Items
--------------------------------------------------------------------------------------------------------------------------------------------------]]--


scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
  x = 0,
  y = BASE_HEIGHT - 10,
  w = BASE_WIDTH,
  h = 10,
  body_type = "static",
  img = "wall",
  __scale = true,
})
scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
  x = 0,
  y = -10,
  w = 10,
  h = BASE_HEIGHT,
  body_type = "static",
  img = "floor",
  __scale = true,
})
scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
  x = BASE_WIDTH - 10,
  y = 0,
  w = 10,
  h = BASE_HEIGHT,
  body_type = "static",
  img = "wall",
})


  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 150,
    y = 122,
    w = 64,
    h = 4,
    body_type = "dynamic",
    shape = "rectangle",
    __scale = true,
    name = "dave",
    img = "floor",
    density = 5,
  })

  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 150 + 32 - 4,
    y = 126,
    w = 8,
    h = 8,
    body_type = "static",
    shape = "triangle",
    __scale = true,
  })
  
  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 195,
    y = 0,
    w = 16,
    h = 16,
    body_type = "dynamic",
    shape = "heart",
    __scale = true,
    name = "star",
    density = 1,
  })

  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 160,
    y = -100,
    w = 16,
    h = 16,
    body_type = "dynamic",
    shape = "diamond",
    __scale = true,
    bullet = true,
    density = 20,
  })
  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 160,
    y = -100,
    w = 16,
    h = 16,
    body_type = "dynamic",
    shape = "spade",
    __scale = true,
    bullet = true,
    density = 20,
  })
  scene.object_pool[#scene.object_pool+1] = Wblock.create_simple_object({
    x = 160,
    y = -100,
    w = 16,
    h = 16,
    body_type = "dynamic",
    shape = "club",
    __scale = true,
    bullet = true,
    density = 20,
  })


-- Joints
scene.joint_pool[#scene.joint_pool + 1] = Wblock.create_joint({
  name = "see-saw",
  type = "revolute",
  collide_connected = false,
  body1 = scene.object_pool[5].body,
  body2 = scene.object_pool[5-1].body,
  x = scene.object_pool[5].settings.cx+0,
  y = scene.object_pool[5].settings.cy-4,
})


Wblock.add_rule("pre", "test", function (a, b, coll)

end)

Wblock.add_rule("post", "test", function (a, b, coll, normalimpulse, tangentimpulse)

end)

Wblock.add_rule("begin", "test", function (a, b, coll)

end)

Wblock.add_rule("end", "test", function (a, b, coll)

end)




--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Update
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:update(dt)
  Utilities.pixel_scale.update(dt)
  Wblock.update(dt, scene.object_pool, scene.joint_pool)
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * Draw
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:draw()
  Utilities.pixel_scale.start()
  -- Lazy Background 
  color("0f0f0f")
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  color()

  -- Draw with draw functions on Wooden Block Bodies
  Wblock.draw(scene.object_pool, {image_table = Texture.zzzzz_test.kit_wooden_block})

  -- Draw Debug
  if debug_shapes then 
    Wblock.debug_draw_pool(scene.object_pool, scene.joint_pool, debug_name)
  end

  -- Drag Debug Mouse Pos
  color("00FFFF")
  love.graphics.rectangle("fill", Utilities.pixel_scale.mouse.x, Utilities.pixel_scale.mouse.y, 1, 1)
  color()

  Utilities.pixel_scale.stop()
  -- Small Text - Debug Data 
  Utilities.debug_tools.on_screen_debug_info()
end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
function scene:keypressed( key, scancode, isrepeat )
  if key == "`" then 
    debug_shapes = not debug_shapes
  end
  if key == "0" then 
    Wblock.remove_all_from_pool(scene.object_pool)
  end
  if key == "1" then 
    Wblock.print_world_items(scene.object_pool, scene.joint_pool)
  end
  if key == "2" then 

  end
  if key == "3" then 

  end
  if key == "4" then 

  end
  if key == "5" then 

  end
  if key == "6" then 

  end
  if key == "7" then 

  end
  if key == "8" then 

  end
  if key == "9" then 

  end
  if key == "space" then 
    Wblock.pause = not Wblock.pause
  end
end

local mousecount = 0
function scene:mousepressed(x,y,button)
  if button == 1 then 
    local created = Wblock.create_mouse_joint({
      joint_pool = scene.joint_pool,
      more_than_one_mouse_joint = true,
      name = "mouse" .. tostring(mousecount)
    })
    if created then mousecount = mousecount + 1 end
  end
  if button == 2 then 
    local removed, removed_count = Wblock.remove_mouse_joint({
      joint_pool = scene.joint_pool,
      name = "mouse" .. tostring(mousecount - 1),
      remove_one = false,
    })
    if removed then mousecount = mousecount - removed_count end
  end

  print(mousecount)

end

--[[--------------------------------------------------------------------------------------------------------------------------------------------------
  * 
--------------------------------------------------------------------------------------------------------------------------------------------------]]--
return scene

--[[
  Box2D Notes 
static
    Static bodies do not move.
dynamic
    Dynamic bodies collide with all bodies.
kinematic
    Kinematic bodies only collide with dynamic bodies.

WBox.add_rule("begin", "fun", function (a, b, coll)
  print("begin", a, b, coll)
end)

WBox.add_rule("end", "fun", function (a, b, coll) -- don't add remove rules here
  print("end", a, b, coll)
end)

WBox.add_rule("pre", "fun", function (a, b, coll)
  print("pre", a, b, coll)
end)

WBox.add_rule("post", "fun", function (a, b, coll, normalimpulse, tangentimpulse)
  print("post", a, b, coll, normalimpulse, tangentimpulse)
end)

WBox.remove_rule("begin", "fun")
WBox.remove_rule("end", "fun")
WBox.remove_rule("pre", "fun")
WBox.remove_rule("post", "fun")


WBox.add_rule("post", "test", function (a, b, coll, normalimpulse, tangentimpulse)
  WBox.add_pre_update("bounce", function ()
    if a:getUserData().settings.body_type == "dynamic" and normalimpulse > 25 then
     a:getUserData().remove = true  
    end 
  end)
end)


Counting Attachments with the Mouse 

local mousecount = 0
function scene:mousepressed(x,y,button)
  if button == 1 then 
    local created = Wblock.create_mouse_joint({
      joint_pool = scene.joint_pool,
      more_than_one_mouse_joint = true,
      name = "mouse" .. tostring(mousecount)
    })
    if created then mousecount = mousecount + 1 end
  end
  if button == 2 then 
    local removed, removed_count = Wblock.remove_mouse_joint({
      joint_pool = scene.joint_pool,
      name = "mouse" .. tostring(mousecount - 1),
      remove_one = false,
    })
    if removed then mousecount = mousecount - removed_count end
  end

  print(mousecount)

end

]]--